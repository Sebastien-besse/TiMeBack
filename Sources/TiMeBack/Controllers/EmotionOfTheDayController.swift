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
