//
//  EmotionController.swift
//  TiMeBack
//
//  Created by Thibault on 03/10/2025.
//

import Vapor

struct EmotionController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let emotion = routes.grouped("emotion")
        
        emotion.get(use: getAll)
        emotion.get(":id", use: getById)
        emotion.post("create", use: createEmotion)
        emotion.put(":id", use: updateEmotion)
        emotion.delete(":id", use: deleteEmotion)
    }
}

//MARK: - GET Emotion by id
@Sendable
func getById(_ req: Request) async throws -> EmotionDTO {
    guard let id = req.parameters.get("id", as: UUID.self),
          let emotion = try await Emotion.find(id, on: req.db)
    else {
        throw Abort(.notFound)
    }
    
    return EmotionDTO(from: emotion)
}

//MARK: - GET All Emotions
@Sendable
func getAll(_ req: Request) async throws -> [EmotionDTO] {
    let emotions = try await Emotion.query(on: req.db).all()
    return emotions.map { EmotionDTO(from: $0) }
}

//MARK: - CREATE Emotion
@Sendable
    func createEmotion(_ req: Request) async throws -> Response {
        let dto = try req.content.decode(EmotionCreate.self)
        let emotion = Emotion(title: dto.title, categoryID: dto.categoryID)
        try await emotion.create(on: req.db)
        let responseDTO = EmotionDTO(from: emotion)
        let data = try JSONEncoder().encode(responseDTO)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: data))
    }

//MARK: - UPDATE Emotion
@Sendable
func updateEmotion(_ req: Request) async throws -> EmotionDTO {
    guard let id = req.parameters.get("id", as: UUID.self),
          let emotion = try await Emotion.find(id, on: req.db) else {
        throw Abort(.notFound)
    }
    let dto = try req.content.decode(EmotionUpdate.self)
    emotion.title = dto.title!
    try await emotion.update(on: req.db)
    return EmotionDTO(from: emotion)
}

//MARK: - DELETE Emotion
@Sendable
func deleteEmotion(_ req: Request) async throws -> HTTPStatus {
    guard let id = req.parameters.get("id", as: UUID.self),
          let emotion = try await Emotion.find(id, on: req.db) else {
        throw Abort(.notFound)
    }
    try await emotion.delete(on: req.db)
    return .noContent
}
