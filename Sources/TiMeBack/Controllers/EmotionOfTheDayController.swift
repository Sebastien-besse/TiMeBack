//
//  EmotionOfTheDayController.swift
//  TiMeBack
//
//  Created by Thibault on 05/10/2025.
//

import Vapor


struct EmotionOfTheDayController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let emotionOfTheDAy = routes.grouped("emotionOfTheDay")
        
        emotionOfTheDAy.get(":id", use: getById)
        emotionOfTheDAy.post("create", use: createEmotionOfTheDay)
        emotionOfTheDAy.put(":id", use: updateEmotionOfTheDay)
        emotionOfTheDAy.delete(":id", use: deleteEmotionOfTheDay)
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
    
}
    
//MARK: - CREATE EmotionOfTheDay
@Sendable
func createEmotionOfTheDay(_ req: Request) async throws -> Response {
    let dto = try req.content.decode(EmotionOfTheDayDTO.self)
    let emotionOfTheDay = EmotionOfTheDay(date: dto.date, idUser: dto.idUser, idEmotion: dto.idEmotion)
    try await emotionOfTheDay.create(on: req.db)
    let responseDTO = EmotionOfTheDayDTO(from: emotionOfTheDay)
    let data = try JSONEncoder().encode(responseDTO)
    return Response(status: .created, headers: ["ContentType": "application/json"], body: .init(data: data))
}

//MARK: - UPDATE EmotionOfTheDay
@Sendable
func updateEmotionOfTheDay(_ req: Request) async throws -> EmotionOfTheDayDTO {
    guard let id = req.parameters.get("id", as: UUID.self),
          let emotionOfTheDay = try await EmotionOfTheDay.find(id, on: req.db)
    else {
        throw Abort(.notFound)
    }
    let dto = try req.content.decode(EmotionOfTheDayDTO.self)
    emotionOfTheDay.date = dto.date
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
