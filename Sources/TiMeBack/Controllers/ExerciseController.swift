//
//  ExerciseController.swift
//  TiMeBack
//
//  Created by Thibault on 29/10/2025.
//

import Vapor
import Fluent

//MARK: - ExerciseController
struct ExerciseController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let exercises = routes.grouped("exercises")
        
        exercises.get(use: getAll)
        exercises.get("random", use: getRandomExercise)
        exercises.get(":id", use: getById)
        exercises.post("create", use: create)
        exercises.put(":id", use: update)
        exercises.delete(":id", use: delete)
    }
    
    //MARK: - GET Exercise by id
    @Sendable
    func getById(_ req: Request) async throws -> ExerciseDTO {
        guard let id = req.parameters.get("id", as: UUID.self),
              let exercise = try await Exercise.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        
        return ExerciseDTO(from: exercise)
    }
    
    //MARK: - GET All Exercises
    @Sendable
    func getAll(_ req: Request) async throws -> [ExerciseDTO] {
        let exercises = try await Exercise.query(on: req.db).all()
        return exercises.map { ExerciseDTO(from: $0) }
    }
    
    //MARK: - GET Random Exercise (exercice aléatoire)
    @Sendable
    func getRandomExercise(_ req: Request) async throws -> ExerciseDTO {
        let exercises = try await Exercise.query(on: req.db).all()
        
        guard !exercises.isEmpty else {
            throw Abort(.notFound, reason: "Aucun exercice disponible")
        }
        
        // Sélectionne un exercice aléatoire
        let randomExercise = exercises.randomElement()!
        
        print("Exercice aléatoire sélectionné: \(randomExercise.instruction)")
        
        return ExerciseDTO(from: randomExercise)
    }
    
    //MARK: - CREATE Exercise
    @Sendable
    func create(_ req: Request) async throws -> Response {
        let dto = try req.content.decode(ExerciseCreate.self)
        
        let exercise = Exercise(
            instruction: dto.instruction,
            image: dto.image,
            challengeID: dto.challengeID
        )
        try await exercise.create(on: req.db)
        
        let responseDTO = ExerciseDTO(from: exercise)
        
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(responseDTO)
        
        return Response(status: .created, headers: headers, body: .init(data: data))
    }
    
    //MARK: - UPDATE Exercise
    @Sendable
    func update(_ req: Request) async throws -> ExerciseDTO {
        guard let id = req.parameters.get("id", as: UUID.self),
              let exercise = try await Exercise.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        let dto = try req.content.decode(ExerciseUpdate.self)
        
        if let instruction = dto.instruction {
            exercise.instruction = instruction
        }
        
        if let image = dto.image {
            exercise.image = image
        }
        
        if let challengeID = dto.challengeID {
            exercise.challengeID = challengeID
        }
        
        try await exercise.update(on: req.db)
        return ExerciseDTO(from: exercise)
    }
    
    //MARK: - DELETE Exercise
    @Sendable
    func delete(_ req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self),
              let exercise = try await Exercise.find(id, on: req.db)
        else {
            throw Abort(.notFound)
        }
        try await exercise.delete(on: req.db)
        return .noContent
    }
}
