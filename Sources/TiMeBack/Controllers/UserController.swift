//
//  File.swift
//  TiMeBack
//
//  Created by Sebastien Besse on 26/09/2025.
//

import Vapor
import Fluent
import FluentSQL
import JWTKit

struct ImageUploadResponse: Content {
    let imageURL: String
}

struct UserController: RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        
        // Liste tous les utilisateurs utilisateurs.post(use: create)
        users.get(use: getAll)
        
        // Crée un nouvel utilisateur utilisateurs.post("login", use: login)
        users.post(use: create)
        users.post("upload", use: uploadImage)
        
        // Route pour la connexion
        users.post("login", use: login)
        
        // Créer un groupe de routes qui nécessitent le middleware JWT
        let protectedRoutes = users.grouped(JWTMiddleware())
        // Accès aux informations de profil
        protectedRoutes.get("profile", use: profile)
        protectedRoutes.get("pages", use: pageByUserId)
        protectedRoutes.get("notes", use: noteByUserId)
        protectedRoutes.get("average", use: averageMotivationByUserId)
        protectedRoutes.get("emotionStats", use: getEmotionStats)
        protectedRoutes.put("update", use: updateUser)
        protectedRoutes.patch("streak", use: patchUserStreak)
        protectedRoutes.patch("challenge", use: patchUserChallenge)
        protectedRoutes.delete("delete", use: deleteUser)
        users.group(":utilisateurID") { user in
            user.get(use: getUtilisateurByID)
        }
        
        
        @Sendable
        func login(req: Request) async throws -> String {
            // Décoder les données utilisateur à partir de la requête
            let userData = try req.content.decode (LoginRequest.self)
            // Rechercher l'utilisateur par email
            
            guard userData.email != nil || userData.username != nil else {
                throw Abort(.badRequest, reason: "Veuillez renseigner un email ou un nom d'utilisateur.")
            }
            
            let user: User?
            if let email = userData.email {
                user = try await User.query(on: req.db)
                    .filter(\.$email == email)
                    .first()
            } else if let username = userData.username {
                user = try await User.query(on: req.db)
                    .filter(\.$userName == username)
                    .first()
            } else {
                // Par sécurité — ne devrait jamais arriver à cause du guard
                throw Abort(.badRequest, reason: "Aucun identifiant fourni.")
            }
            
            guard let user = user else {
                throw Abort(.unauthorized, reason: "Identifiant incorrect (utilisateur non trouvé).")
            }
            //            guard let user = try await User.query(on: req.db)
            //                .filter(\.$email == userData.email ?? "")
            //                .first() else {
            //                throw Abort(.unauthorized, reason: "L'utilisateur n'existe pas. ")
            //            }
            // Vérification du mot de passe
            guard try Bcrypt.verify(userData.password, created: user.password) else {
                throw Abort(.unauthorized, reason: "Mot de passe incorrect.")
            }
            // Génération du token JWT
            let payload = UserPayload(id: user.id!)
            let signer = JWTSigner.hs256(key: "clé_secrète_Zak007") // Clé secrète sécurisée
            let token = try signer.sign(payload) // Signer le payload pour générer le token return token // Retourner le token au client
            return token // Retourner le token au client
        }
        
        @Sendable
        func profile(req: Request) async throws -> UserDTO {
            // Essaye d'extraire le payload JWT de la requête
            let payload = try req.auth.require(UserPayload.self)
            // Recherche l'utilisateur dans la base de données en utilisant l'ID extrait du payload
            guard let user = try await User.find(payload.id, on: req.db) else {
                throw Abort (.notFound)
            }
            // Convertit l'utilisateur en DTO pour ne retourner que les informations nécessaires return utilisateur.toDTO()
            return user.toDTO()
        }
        
        
        
        @Sendable
        // Création d’un nouvel utilisateur
        func create(_ req: Request) async throws -> UserPublicDTO {
            let dto = try req.content.decode(CreateUserDTO.self)
            let user = User(
                userName: dto.userName,
                firstName: dto.firstName,
                lastName: dto.lastName,
                email: dto.email,
                password: dto.password,
                role: User.Role.user,
                imageProfil: dto.imageProfil ?? ""
            )
            user.password = try Bcrypt.hash(user.password)
            try await user.create(on: req.db)
            return try UserPublicDTO(from: user)
        }
        
        //        @Sendable
        //        func create(req: Request) async throws -> UserDTO {
        //            let user = try req.content.decode (User.self)
        //            user.password = try Bcrypt.hash(user.password) // Hachage du mot de passe
        //            try await user.save(on: req.db)
        //            return user.toDTO()
        //        }
        
        @Sendable
        // Upload l’image du profil
        func uploadImage(_ req: Request) async throws -> ImageUploadResponse {
            struct UploadData: Content { var file: File }
            
            let upload = try req.content.decode(UploadData.self)
            let filename = UUID().uuidString + ".jpg"
            
            let uploadsDir = req.application.directory.publicDirectory + "uploads/"
            try FileManager.default.createDirectory(atPath: uploadsDir, withIntermediateDirectories: true)
            
            
            //Dossier où l’image sera stockée
            let savePath = uploadsDir + filename
            try await req.fileio.writeFile(upload.file.data, at: savePath)
            
            //URL publique pour accéder à l’image
            // Si tu testes sur iPhone, remplace localhost par ton IP locale (ex : 192.168.x.x)
            
            
#if DEBUG
            let publicURL = "http://127.0.0.1:8080/uploads/\(filename)"
#else
            let publicURL = "http://10.80.59.190:8080/uploads/\(filename)"
#endif
            
            return ImageUploadResponse(imageURL: publicURL)
        }
        
        @Sendable
        func getAll(_ req: Request) async throws -> [UserPublicDTO] {
            let users = try await User.query(on: req.db).all()
            return try users.map { try UserPublicDTO(from: $0) }
        }
        
        @Sendable
        func getUtilisateurByID(_ req: Request) async throws -> UserPublicDTO {
            //Récupère l’ID passé dans l’URL
            guard let userID = req.parameters.get("utilisateurID", as: UUID.self) else {
                throw Abort(.badRequest, reason: "ID utilisateur invalide ou manquant.")
            }
            
            //Recherche l’utilisateur dans la base
            guard let user = try await User.find(userID, on: req.db) else {
                throw Abort(.notFound, reason: "Aucun utilisateur trouvé avec cet ID.")
            }
            
            //Retourne un DTO public (sans mot de passe)
            return try UserPublicDTO(from: user)
        }
        
        //MARK: - GET Number Page by id user
        @Sendable
        func pageByUserId(_ req: Request) async throws -> PageTotalDTO {
            // Récupération du payload JWT
            let payload = try req.auth.require(UserPayload.self)
            
            // Recherche de l'utilisateur par son id
            guard let user = try await User.find(payload.id, on: req.db) else {
                throw Abort(.notFound)
            }
            
            // Vérifie si la DB est SQL
            guard let sql = req.db as? (any SQLDatabase) else {
                throw Abort(.internalServerError, reason: "La base de donnée n'est pas SQL")
            }
            
            // Exécution de la requête SQL avec alias explicite
            let result = try await sql.raw("""
                SELECT COUNT(*) AS count
                FROM pages
                WHERE id_user = \(bind: user.id)
            """).first(decoding: PageTotalDTO.self)
            
            // Vérifie qu'on a bien un résultat
            guard let pageTotal = result else {
                return PageTotalDTO(count: 0)
            }
            return pageTotal
        }
        
        //MARK: - GET Number Note by id user
        @Sendable
        func noteByUserId(_ req: Request) async throws -> PageTotalDTO {
            // Récupération du payload JWT
            let payload = try req.auth.require(UserPayload.self)
            
            // Recherche de l'utilisateur par son id
            guard let user = try await User.find(payload.id, on: req.db) else {
                throw Abort(.notFound)
            }
            
            // Vérifie si la DB est SQL
            guard let sql = req.db as? (any SQLDatabase) else {
                throw Abort(.internalServerError, reason: "La base de donnée n'est pas SQL")
            }
            
            // Exécution de la requête SQL avec alias explicite
            let result = try await sql.raw("""
                SELECT COUNT(note) AS count
                FROM pages
                WHERE id_user = \(bind: user.id)
            """).first(decoding: PageTotalDTO.self)
            
            // Vérifie qu'on a bien un résultat
            guard let pageTotal = result else {
                return PageTotalDTO(count: 0)
            }
            
            return pageTotal
        }
        
        //MARK: - GET Average Motivation by id user
        @Sendable
        func averageMotivationByUserId(_ req: Request) async throws -> PageTotalDTO {
            // Récupération du payload JWT
            let payload = try req.auth.require(UserPayload.self)
            
            // Recherche de l'utilisateur par son id
            guard let user = try await User.find(payload.id, on: req.db) else {
                throw Abort(.notFound)
            }
            
            // Vérifie si la DB est SQL
            guard let sql = req.db as? (any SQLDatabase) else {
                throw Abort(.internalServerError, reason: "La base de donnée n'est pas SQL")
            }
            
            // Exécution de la requête SQL avec alias explicite
            let result = try await sql.raw("""
                SELECT COALESCE(ROUND(AVG(motivation)), 0) AS count
                FROM motivations
                WHERE id_user = \(bind: user.id)
            """).first(decoding: PageTotalDTO.self)
            
            // Vérifie qu'on a bien un résultat
            guard let pageTotal = result else {
                return PageTotalDTO(count: 0)
            }
            // retourne le model avec le nombres de pages
            return pageTotal
        }
        
        //MARK: GET Emotion stats by id user
        @Sendable
        func getEmotionStats(_ req: Request) async throws -> [EmotionCategoryStatsDTO] {
            // 🔐 Récupération du payload JWT
            let payload = try req.auth.require(UserPayload.self)
            
            // 🧍‍♂️ Recherche de l'utilisateur
            guard let user = try await User.find(payload.id, on: req.db) else {
                throw Abort(.notFound, reason: "Utilisateur introuvable.")
            }
            
            // 📅 Paramètre "period"
            let period = (try? req.query.get(String.self, at: "period")) ?? "month"
            
            let now = Date()
            let calendar = Calendar.current
            let startDate: Date
            
            switch period.lowercased() {
            case "week":
                startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            case "month":
                startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            case "year":
                startDate = calendar.date(from: calendar.dateComponents([.year], from: now))!
            default:
                throw Abort(.badRequest, reason: "Invalid period. Use week, month or year.")
            }
            
            // 📊 Récupération des émotions + catégorie associée
            let results = try await EmotionOfTheDay.query(on: req.db)
                .filter(\.$user.$id == user.requireID())
                .filter(\.$date >= startDate)
                .with(\.$emotion) { $0.with(\.$category) } // charge la catégorie liée
                .all()
            
            // 📈 Regrouper par catégorie
            var categoryCount: [UUID: (title: String, color: String, count: Int)] = [:]
            
            for item in results {
                // ✅ accès à la catégorie chargée via "with"
                let category = item.emotion.category
                guard let categoryId = category.id else { continue }
                
                if var existing = categoryCount[categoryId] {
                    existing.count += 1
                    categoryCount[categoryId] = existing
                } else {
                    categoryCount[categoryId] = (category.title, category.color, 1)
                }
            }
            
            // 🎯 Conversion en DTO
            return categoryCount.map { (id, value) in
                EmotionCategoryStatsDTO(
                    categoryId: id,
                    categoryTitle: value.title,
                    color: value.color,
                    count: value.count
                )
            }
        }
        
        @Sendable
        func updateUser(_ req: Request) async throws -> UserPublicDTO {
            // Récupérer le payload JWT → permet de vérifier que le user est bien authentifié
            let payload = try req.auth.require(UserPayload.self)
            
            // Récupérer l'utilisateur à mettre à jour (depuis la base)
            guard let user = try await User.find(payload.id, on: req.db) else {
                throw Abort(.notFound, reason: "Utilisateur introuvable.")
            }
            
            // Décoder les nouvelles données envoyées par le client
            let updateData = try req.content.decode(CreateUserDTO.self)
            
            // Met à jour les champs
            user.firstName = updateData.firstName
            user.lastName = updateData.lastName
            user.userName = updateData.userName
            user.email = updateData.email
            
            // Si un mot de passe est envoyé → on le rehash
            if !updateData.password.isEmpty {
                user.password = try Bcrypt.hash(updateData.password)
            }
            
            // Si une nouvelle image est fournie
            if let imageProfil = updateData.imageProfil {
                user.imageProfil = imageProfil
            }
            
            // Enregistre les changements
            try await user.save(on: req.db)
            
            // Retourne la version publique du user
            return try UserPublicDTO(from: user)
        }
        
        @Sendable
        func patchUserStreak(req: Request) async throws -> UserPublicDTO{
            let payload = try req.auth.require(UserPayload.self)
            
            // Récupérer l'utilisateur à mettre à jour (depuis la base)
            guard let user = try await User.find(payload.id, on: req.db) else {
                throw Abort(.notFound, reason: "Utilisateur introuvable.")
            }
            
            let updateData = try req.content.decode(UserStreakDTO.self)
            
            user.streakNumber = updateData.streakNumber
            
            try await user.save(on: req.db)
            return try UserPublicDTO(from: user)
        }
        
        @Sendable
        func patchUserChallenge(req: Request) async throws -> UserPublicDTO{
            let payload = try req.auth.require(UserPayload.self)
            
            // Récupérer l'utilisateur à mettre à jour (depuis la base)
            guard let user = try await User.find(payload.id, on: req.db) else {
                throw Abort(.notFound, reason: "Utilisateur introuvable.")
            }
            
            let updateData = try req.content.decode(UserChallengeDTO.self)
            
            user.challengeNumber = updateData.challengeNumber
            
            try await user.save(on: req.db)
            return try UserPublicDTO(from: user)
        }
        
        
        @Sendable
        func deleteUser(_ req: Request) async throws -> HTTPStatus {
            //Vérifie que le token JWT est valide
            let payload = try req.auth.require(UserPayload.self)
            
            //Récupère l’utilisateur à supprimer
            guard let user = try await User.find(payload.id, on: req.db) else {
                throw Abort(.notFound, reason: "Utilisateur introuvable.")
            }
            
            //Supprime l’utilisateur
            try await user.delete(on: req.db)
            
            return .noContent // 204 No Content
        }
        
        
    }
    
}



