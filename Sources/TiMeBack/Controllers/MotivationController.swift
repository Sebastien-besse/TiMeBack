//
//  MotivationController.swift
//  TiMeBack
//
//  Created by Thibault on 19/10/2025.
//

import Vapor

//MARK: - MotivationController
struct MotivationController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let motivation = routes.grouped("motivation")
        let protectedRoute = motivation.grouped(JWTMiddleware())
        
        protectedRoute.get(use: getAll)
        protectedRoute.get(":id", use: getById)
        protectedRoute.post("create", use: create)
        protectedRoute.put(":id", use: update)
        protectedRoute.delete(":id", use: delete)
    }
    
    //MARK: - GET Motivation by id
    @Sendable
    func getById(_ req: Request) async throws -> MotivationDTO {
        guard let id = req.parameters.get("id", as: UUID.self),
              let motivation = try await Motivation.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        return MotivationDTO(from: motivation)
    }
    
    //MARK: - GET All Motivation
    @Sendable
    func getAll(_ req: Request) async throws -> [MotivationDTO] {
        let motivations = try await Motivation.query(on: req.db).all()
        return motivations.map { MotivationDTO(from: $0) }
    }
    
    //MARK: - CREATE Motivation
    @Sendable
    func create(_ req: Request) async throws -> Response {
        let dto = try req.content.decode(MotivationCreate.self)
        
        let motivation = Motivation(
            motivation: dto.motivation,
            userID: dto.idUser
        )
        try await motivation.create(on: req.db)
        
        let responseDTO = MotivationDTO(from: motivation)
        
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(responseDTO)
        
        return Response(status: .created, headers: headers, body: .init(data: data))
    }
    
    //MARK: - UPDATE Motivation
    @Sendable
    func update(_ req: Request) async throws -> MotivationDTO {
        guard let id = req.parameters.get("id", as: UUID.self),
              let motivation = try await Motivation.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        let dto = try req.content.decode(MotivationUpdate.self)
        
        if let motivationValue = dto.motivation {
            motivation.motivation = motivationValue
        }
        
        try await motivation.update(on: req.db)
        return MotivationDTO(from: motivation)
    }
    
    //MARK: - DELETE Motivation
    @Sendable
    func delete(_ req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self),
              let motivation = try await Motivation.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        try await motivation.delete(on: req.db)
        return .noContent
    }
}
