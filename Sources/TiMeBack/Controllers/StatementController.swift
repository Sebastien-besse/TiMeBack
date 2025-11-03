//
//  StatementController.swift
//  TiMeBack
//
//  Created by Thibault on 29/10/2025.
//

import Vapor
import Fluent

    //MARK: - StatementController
struct StatementController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let statements = routes.grouped("statements")
        
        statements.get(use: getAll)
        statements.get("daily", use: getDailyStatement)
        statements.get(":id", use: getById)
        statements.post("create", use: create)
        statements.put(":id", use: update)
        statements.delete(":id", use: delete)
    }
    
        //MARK: - GET Statement by id
    @Sendable
    func getById(_ req: Request) async throws -> StatementDTO {
        guard let id = req.parameters.get("id", as: UUID.self),
              let statement = try await Statement.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        return StatementDTO(from: statement)
    }
    
        //MARK: - GET All Statements
    @Sendable
    func getAll(_ req: Request) async throws -> [StatementDTO] {
        let statements = try await Statement.query(on: req.db).all()
        return statements.map { StatementDTO(from: $0) }
    }
    
        //MARK: - GET Daily Statement (statement du jour)
    @Sendable
    func getDailyStatement(_ req: Request) async throws -> StatementDTO {
        let calendar = Calendar.current
        let today = Date()
        
            // Récupère uniquement la partie date (sans l'heure)
        let startOfDay = calendar.startOfDay(for: today)
        
            // Cherche le statement correspondant à la date du jour
        guard let statement = try await Statement.query(on: req.db)
            .filter(\.$date >= startOfDay)
            .filter(\.$date < calendar.date(byAdding: .day, value: 1, to: startOfDay)!)
            .first() else {
            throw Abort(.notFound, reason: "Aucun statement pour aujourd'hui")
        }
        
        return StatementDTO(from: statement)
    }
    
        //MARK: - CREATE Statement
    @Sendable
    func create(_ req: Request) async throws -> Response {
        let dto = try req.content.decode(StatementCreate.self)
        
        let statement = Statement(
            sentence: dto.sentence,
            date: dto.date
        )
        try await statement.create(on: req.db)
        
        let responseDTO = StatementDTO(from: statement)
        
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(responseDTO)
        
        return Response(status: .created, headers: headers, body: .init(data: data))
    }
    
        //MARK: - UPDATE Statement
    @Sendable
    func update(_ req: Request) async throws -> StatementDTO {
        guard let id = req.parameters.get("id", as: UUID.self),
              let statement = try await Statement.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        let dto = try req.content.decode(StatementUpdate.self)
        
        if let sentence = dto.sentence {
            statement.sentence = sentence
        }
        
        if let date = dto.date {
            statement.date = date
        }
        
        try await statement.update(on: req.db)
        return StatementDTO(from: statement)
    }
    
        //MARK: - DELETE Statement
    @Sendable
    func delete(_ req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self),
              let statement = try await Statement.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        try await statement.delete(on: req.db)
        return .noContent
    }
}
