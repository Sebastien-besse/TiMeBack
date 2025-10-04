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
        challenge.post("create", use: createChallenge)
        
    }
    
    //MARK: - GET Challenge by id
    @Sendable
    func getById(_ req: Request) async throws -> ChallengeResponseDTO {
        guard let id = req.parameters.get("id", as: UUID.self), // ⬅️ ici
              let challenge = try await Challenge.find(id, on: req.db)
        else {throw Abort(.notFound)}
        
        return .init(from: challenge)
    }
    
    //MARK: - Create Challenge
    func createChallenge(_ req: Request) async throws -> ChallengeResponseDTO{
        let dto = try req.content.decode(ChallengeCreateDTO.self)
        let challenge = Challenge(instruction: dto.instruction, messageMotivation: dto.messageMotivation)
        try await challenge.create(on: req.db)
        return try ChallengeResponseDTO(from: challenge)
    }
    
}
