//
//  HeartLevelController.swift
//  TiMeBack
//
//  Created by Thibault on 19/10/2025.
//

import Vapor

//MARK: - HeartLevelController
struct HeartLevelController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let heartLevel = routes.grouped("heartLevel")
        
        heartLevel.get(use: getAll)
        heartLevel.get(":id", use: getById)
        heartLevel.post("create", use: create)
        heartLevel.put(":id", use: update)
        heartLevel.delete(":id", use: delete)
    }
    
    //MARK: - GET HeartLevel by id
    @Sendable
    func getById(_ req: Request) async throws -> HeartLevelDTO {
        guard let id = req.parameters.get("id", as: UUID.self),
              let heartLevel = try await HeartLevel.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        return HeartLevelDTO(from: heartLevel)
    }
    
    //MARK: - GET All HeartLevel
    @Sendable
    func getAll(_ req: Request) async throws -> [HeartLevelDTO] {
        let heartLevels = try await HeartLevel.query(on: req.db).all()
        return heartLevels.map { HeartLevelDTO(from: $0) }
    }
    
    //MARK: - CREATE HeartLevel
    @Sendable
    func create(_ req: Request) async throws -> Response {
        let dto = try req.content.decode(HeartLevelCreate.self)
        
        let heartLevel = HeartLevel(
            level: dto.level,
            userID: dto.idUser
        )
        try await heartLevel.create(on: req.db)
        
        let responseDTO = HeartLevelDTO(from: heartLevel)
        
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(responseDTO)
        
        return Response(status: .created, headers: headers, body: .init(data: data))
    }
    
    //MARK: - UPDATE HeartLevel
    @Sendable
    func update(_ req: Request) async throws -> HeartLevelDTO {
        guard let id = req.parameters.get("id", as: UUID.self),
              let heartLevel = try await HeartLevel.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        let dto = try req.content.decode(HeartLevelUpdate.self)
        
        if let level = dto.level {
            heartLevel.level = level
        }
        
        try await heartLevel.update(on: req.db)
        return HeartLevelDTO(from: heartLevel)
    }
    
    //MARK: - DELETE HeartLevel
    @Sendable
    func delete(_ req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self),
              let heartLevel = try await HeartLevel.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        try await heartLevel.delete(on: req.db)
        return .noContent
    }
}
