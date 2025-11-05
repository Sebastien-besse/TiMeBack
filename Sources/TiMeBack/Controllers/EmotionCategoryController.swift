//
//  EmotionCategoryController.swift
//  TiMeBack
//
//  Created by Assistant on 03/10/2025.
//

import Vapor

struct EmotionCategoryController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let categories = routes.grouped("emotion-category")
        let protectedRoutes = categories.grouped(JWTMiddleware())
        
        categories.get(use: listEmotionCategories)
        categories.get(":id", use: getEmotionCategoryById)
        categories.post(use: createEmotionCategory)
        categories.put(":id", use: updateEmotionCategory)
        categories.delete(":id", use: deleteEmotionCategory)
    }
}

// MARK: - List
@Sendable
func listEmotionCategories(_ req: Request) async throws -> [EmotionCategoryDTO] {
    let models = try await EmotionCategory.query(on: req.db).all()
    return models.map(EmotionCategoryDTO.init(from:))
}

// MARK: - Get by id
@Sendable
func getEmotionCategoryById(_ req: Request) async throws -> EmotionCategoryDTO {
    guard let id = req.parameters.get("id", as: UUID.self),
          let category = try await EmotionCategory.find(id, on: req.db) else {
        throw Abort(.notFound)
    }
    return EmotionCategoryDTO(from: category)
}

// MARK: - Create
@Sendable
func createEmotionCategory(_ req: Request) async throws -> EmotionCategoryDTO {
    let dto = try req.content.decode(EmotionCategoryCreate.self)
    let category = EmotionCategory(title: dto.title, color: dto.color)
    try await category.create(on: req.db)
    return EmotionCategoryDTO(from: category)
}

// MARK: - Update
@Sendable
func updateEmotionCategory(_ req: Request) async throws -> EmotionCategoryDTO {
    guard let id = req.parameters.get("id", as: UUID.self),
          let category = try await EmotionCategory.find(id, on: req.db) else {
        throw Abort(.notFound)
    }
    let dto = try req.content.decode(EmotionCategoryUpdate.self)
    category.title = dto.title
    try await category.update(on: req.db)
    return EmotionCategoryDTO(from: category)
}

// MARK: - Delete
@Sendable
func deleteEmotionCategory(_ req: Request) async throws -> HTTPStatus {
    guard let id = req.parameters.get("id", as: UUID.self),
          let category = try await EmotionCategory.find(id, on: req.db) else {
        throw Abort(.notFound)
    }
    try await category.delete(on: req.db)
    return .noContent
}
