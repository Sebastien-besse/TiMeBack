//
//  PageController.swift
//  TiMeBack
//
//  Created by Thibault on 19/10/2025.
//

import Vapor

//MARK: - PageController
struct PageController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let page = routes.grouped("page")
        let protectedRoutes = page.grouped(JWTMiddleware())
        
        protectedRoutes.get(use: getAll)
        protectedRoutes.get(":id", use: getById)
        protectedRoutes.post("create", use: create)
        protectedRoutes.put(":id", use: update)
        protectedRoutes.delete(":id", use: delete)
    }
    
    //MARK: - GET Page by id
    @Sendable
    func getById(_ req: Request) async throws -> PageDTO {
        guard let id = req.parameters.get("id", as: UUID.self),
              let page = try await Page.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        return PageDTO(from: page)
    }
    
    //MARK: - GET All Page
    @Sendable
    func getAll(_ req: Request) async throws -> [PageDTO] {
        let pages = try await Page.query(on: req.db).all()
        return pages.map { PageDTO(from: $0) }
    }
    
    
    //MARK: - CREATE Page
    @Sendable
    func create(_ req: Request) async throws -> Response {
        let dto = try req.content.decode(PageCreate.self)
        
        let page = Page(
            note: dto.note,
            userID: dto.idUser
        )
        try await page.create(on: req.db)
        
        let responseDTO = PageDTO(from: page)
        
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(responseDTO)
        
        return Response(status: .created, headers: headers, body: .init(data: data))
    }
    
    //MARK: - UPDATE Page
    @Sendable
    func update(_ req: Request) async throws -> PageDTO {
        guard let id = req.parameters.get("id", as: UUID.self),
              let page = try await Page.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        let dto = try req.content.decode(PageUpdate.self)
        
        if let note = dto.note {
            page.note = note
        }
        
        try await page.update(on: req.db)
        return PageDTO(from: page)
    }
    
    //MARK: - DELETE Page
    @Sendable
    func delete(_ req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self),
              let page = try await Page.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        try await page.delete(on: req.db)
        return .noContent
    }
}
