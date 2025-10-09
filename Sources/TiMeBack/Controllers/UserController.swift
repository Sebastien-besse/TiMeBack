//
//  File.swift
//  TiMeBack
//
//  Created by Sebastien Besse on 26/09/2025.
//

import Vapor

struct ImageUploadResponse: Content {
    let imageURL: String
}

struct UserController: RouteCollection {
   
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: createUser)
        users.post("upload", use: uploadImage)
    }
    
    
    @Sendable
    // Création d’un nouvel utilisateur
    func createUser(_ req: Request) async throws -> UserPublicDTO {
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
        try await user.create(on: req.db)
        return try UserPublicDTO(from: user)
    }
    
    
    @Sendable
    // Upload d’image de profil
    func uploadImage(_ req: Request) async throws -> ImageUploadResponse {
        struct UploadData: Content { var file: File }

        let upload = try req.content.decode(UploadData.self)
        let filename = UUID().uuidString + ".jpg"
        
        let uploadsDir = req.application.directory.publicDirectory + "uploads/"
        try FileManager.default.createDirectory(atPath: uploadsDir, withIntermediateDirectories: true)


        // 📁 Dossier où l’image sera stockée
        let savePath = uploadsDir + filename
        try await req.fileio.writeFile(upload.file.data, at: savePath)

        // 🔗 URL publique pour accéder à l’image
        // Si tu testes sur iPhone, remplace localhost par ton IP locale (ex : 192.168.x.x)
        let publicURL = "http://127.0.0.1:8080/uploads/\(filename)"

        return ImageUploadResponse(imageURL: publicURL)
    }
}

    
    

