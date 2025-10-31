//
//  ChallengeController.swift
//  TiMeBack
//
//  Created by Apprenant125 on 29/09/2025.
//

import Vapor

struct ChallengeController : RouteCollection{
    func boot(routes: any RoutesBuilder) throws {
        let challenge = routes.grouped("challenge")
        
        
        //pour realiser un get id s'assurer d'avoir les 2 points ( : ) et que le pathName soit le même que celui indiqué dans ma route au niveau du parameters ⬇️
        challenge.get(":id", use: getById)
        challenge.get("indexChallenge", use: index)
        challenge.get("randomChallenge", use: randomChallenge)
        
        
        challenge.post("create", use: createChallenge)
        
        //les endpoints doivent soit avoir un params comme ici ↙️ soit un titre reconnaissable ↖️ pour fonctionner correctement
        challenge.put(":challengeID", use: updateChallenge)
        
        challenge.delete(":challengeID", use: deleteChallenge)
        
    }
    
    //MARK: - GET Challenge by id
    @Sendable
    func getById(_ req: Request) async throws -> ChallengeResponseDTO {
        guard let id = req.parameters.get("id", as: UUID.self), // ⬅️ ici
              let challenge = try await Challenge.find(id, on: req.db)
        else {throw Abort(.notFound)}
        
        return .init(from: challenge)
    }
    
    //MARK: - GET Challenge.all -> index
    @Sendable
    func index(_ req: Request) async throws -> [Challenge]{
        try await Challenge.query(on: req.db).all()
    }
    
    //MARK: - GET Challenge.random -> selection d'un challenge
    @Sendable
    func randomChallenge(_ req: Request) async throws -> Challenge{
        try await Challenge.query(on: req.db).all().randomElement()!
    }
    
    //MARK: - Create Challenge
    @Sendable
    func createChallenge(_ req: Request) async throws -> ChallengeResponseDTO{
        let dto = try req.content.decode(ChallengeCreateDTO.self)
        let challenge = Challenge(instruction: dto.instruction, messageMotivation: dto.messageMotivation)
        try await challenge.create(on: req.db)
        return ChallengeResponseDTO(from: challenge)
    }
    
    //MARK: - Update Challenge
    
    @Sendable
    func updateChallenge(_ req: Request) async throws -> ChallengeResponseDTO {
        guard let challengeIDString = req.parameters.get("challengeID"),
              let challengeID = UUID(uuidString: challengeIDString) else {
            throw Abort(.badRequest, reason: "Invalid challenge ID")
        }
        
        let updatedChallenge = try req.content.decode(Challenge.self)
        
        guard let challenge = try await Challenge.find(challengeID, on: req.db) else {
            throw Abort(.notFound, reason: "Challenge not found")
        }
        
        challenge.instruction = updatedChallenge.instruction
        challenge.messageMotivation = updatedChallenge.messageMotivation
        
        try await challenge.save(on: req.db)
        return ChallengeResponseDTO(from: challenge)
    }
    
    //MARK: - Delete Challenge
    
    @Sendable
    func deleteChallenge(_ req: Request) async throws -> HTTPStatus {
        guard let challengeIDSting = req.parameters.get("challengeID"),
              let challengeID = UUID(uuidString: challengeIDSting) else {
            throw Abort(.notFound, reason: "invalid challenge Id")
        }
        
        guard let challenge = try await Challenge.find(challengeID, on: req.db) else {
            throw Abort(.notFound, reason: "no challenge has been found")
        }
        
        try await challenge.delete(on: req.db)
        return .noContent
        
    }
    
}
