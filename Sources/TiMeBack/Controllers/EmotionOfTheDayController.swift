//
//  EmotionOfTheDayController.swift
//  TiMeBack
//
//  Created by Thibault on 05/10/2025.
//

import Vapor


struct EmotionOfTheDayController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let emotionOfTheDay = routes.grouped("emotionOfTheDay")
        
        emotionOfTheDay.get(use: getAll)
        emotionOfTheDay.get(":id", use: getById)
        emotionOfTheDay.post("create", use: createOrUpdateEmotionOfTheDay)
        emotionOfTheDay.put(":id", use: updateEmotionOfTheDay)
        emotionOfTheDay.delete(":id", use: deleteEmotionOfTheDay)
        emotionOfTheDay.get("daily-suggestion", use: getDailySuggestion)
    }
    
    
    //MARK: - GET EmotionOfTheDay by id
    @Sendable
    func getById(_ req: Request) async throws -> EmotionOfTheDayDTO {
        guard let id = req.parameters.get("id", as: UUID.self),
              let emotionOfTheDay = try await EmotionOfTheDay.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        return EmotionOfTheDayDTO(from: emotionOfTheDay)
    }
    
    //MARK: - GET All EmotionOfTheDay
    @Sendable
    func getAll(_ req: Request) async throws -> [EmotionOfTheDayDTO] {
        let emotionOfTheDay = try await EmotionOfTheDay.query(on: req.db).all()
        return emotionOfTheDay.map { EmotionOfTheDayDTO(from: $0) }
    }
    
}

//MARK: - GET Daily Suggestion (émotion positive aléatoire du jour)
@Sendable
func getDailySuggestion(_ req: Request) async throws -> EmotionDTO {
    // 1. Définir les couleurs des catégories positives
    let positiveColors = ["Orange", "Rose"]
    
    // 2. Récupérer les catégories positives (par couleur)
    /// On utilise Fluent donc on récupère grâce à 'in' et 3 arguments : KeyPath(\.$color), Opérateur(equal) & Valeur(color)
    let positiveCategories = try await EmotionCategory.query(on: req.db)
        .group(.or) { group in
            for color in positiveColors {
                group.filter(\.$color, .equal, color)
            }
        }
        .all()
    
    // 3. Récupérer les IDs des catégories
    let categoryIDs = positiveCategories.compactMap { $0.id }
    
    guard !categoryIDs.isEmpty else {
        throw Abort(.notFound, reason: "Aucune catégorie positive trouvée")
    }
    
    // 4. Récupérer toutes les émotions de ces catégories
    let emotions = try await Emotion.query(on: req.db)
        .group(.or) { group in
            for categoryID in categoryIDs {
                group.filter(\.$category.$id, .equal, categoryID)
            }
        }
        .all()
    
    guard !emotions.isEmpty else {
        throw Abort(.notFound, reason: "Aucune émotion positive trouvée")
    }
    
    // 5. Choisir une émotion basée sur la date du jour (seed)
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let daysSince1970 = Int(today.timeIntervalSince1970 / 86400)
    
    // Utiliser le nombre de jours comme seed
    let index = daysSince1970 % emotions.count
    let selectedEmotion = emotions[index]
    
    // 6. Retourner l'émotion choisie
    return EmotionDTO(from: selectedEmotion)
}
    
//MARK: - CREATE or UPDATE EmotionOfTheDay
@Sendable
func createOrUpdateEmotionOfTheDay(_ req: Request) async throws -> Response {
    let dto = try req.content.decode(EmotionOfTheDayCreate.self)
    
    // Extraire juste la date (sans l'heure) pour vérifier que le jour est unique
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: dto.date)
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
    
    // Vérifier si une émotion existe déjà pour cet utilisateur à cette date
    let existingEmotion = try await EmotionOfTheDay.query(on: req.db)
        .filter(\.$user.$id, .equal, dto.idUser)
        .filter(\.$date, .greaterThanOrEqual, startOfDay)
        .filter(\.$date, .lessThan, endOfDay)
        .first()
    
        let responseDTO: EmotionOfTheDayDTO
        let status: HTTPResponseStatus
    
    if let existing = existingEmotion {
        existing.date = dto.date
        existing.$emotion.id = dto.idEmotion
        try await existing.update(on: req.db)
        responseDTO = EmotionOfTheDayDTO(from: existing)
        status = .ok
    } else {
        let emotionOfTheDay = EmotionOfTheDay(
            date: dto.date,
            userID: dto.idUser,
            emotionID: dto.idEmotion
        )
        try await emotionOfTheDay.create(on: req.db)
        responseDTO = EmotionOfTheDayDTO(from: emotionOfTheDay)
        status = .created
    }
    // Encoder le DTO avec l'encoder ISO8601
    var headers = HTTPHeaders()
    headers.add(name: .contentType, value: "application/json")
    
    // Utiliser l'encoder avec ISO8601
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(responseDTO)
    
    return Response(status: status, headers: headers, body: .init(data: data))
}

//MARK: - UPDATE EmotionOfTheDay
@Sendable
func updateEmotionOfTheDay(_ req: Request) async throws -> EmotionOfTheDayDTO {
    guard let id = req.parameters.get("id", as: UUID.self),
          let emotionOfTheDay = try await EmotionOfTheDay.find(id, on: req.db)
    else {
        throw Abort(.notFound)
    }
    let dto = try req.content.decode(EmotionOfTheDayUpdate.self)
    
    if let date = dto.date {
        emotionOfTheDay.date = date
    }
    if let emotionID = dto.idEmotion {
        emotionOfTheDay.$emotion.id = emotionID
    }
    
    try await emotionOfTheDay.update(on: req.db)
    return EmotionOfTheDayDTO(from: emotionOfTheDay)
}

//MARK: - DELETE EmotionOfTheDay
@Sendable
func deleteEmotionOfTheDay(_ req: Request) async throws -> HTTPStatus {
    guard let id = req.parameters.get("id", as: UUID.self),
          let emotionOfTheDay = try await EmotionOfTheDay.find(id, on: req.db)
    else {
        throw Abort(.notFound)
    }
    try await emotionOfTheDay.delete(on: req.db)
    return .noContent
}
