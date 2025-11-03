//
//  ChallengeOfTheDayController.swift
//  TiMeBack
//
//  Created by Carla on 17/10/2025.
//

import Vapor

struct ChallengeOfTheDayController : RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        
        let challengeOfTheDay = routes.grouped("challengeOfTheDay")
        let protectedRoutes = challengeOfTheDay.grouped(JWTMiddleware())
        
        protectedRoutes.get("get_challenge_of_the_day", use: getChallengeOfTheDay)
        protectedRoutes.delete("deleteForToday", use: deleteChallengeOfTheDay)
    }
    
    //MARK: - Post ChallengeOfTheDay.random -> ajout d'un challenge aléatoire en tant que challenge du jour
        
    @Sendable
    func createRandomChallengeOfTheDay(_ req: Request) async throws -> ChallengeOfTheDayResponseDTO {
        // Je récupère un challenge random
        guard let randomChallenge = try await Challenge.query(on: req.db).all().randomElement() else {
            throw Abort(.notFound, reason: "Random challenge hasn't been found")
        }
        
        // je récupère en paramètre l'id de l'user correspondant
        guard let userID = req.parameters.get("userID", as: UUID.self) else{
            throw Abort(.notFound, reason: "no user found with this Id")
        }
        
        
        
        // j'instancie le random challenge en tant que challenge du jour
       // _ = try req.content.decode(ChallengeOfTheDayCreateDTO.self)
        let challengeOfTheDay = ChallengeOfTheDay(dateExp: Date.now, instructionOTD: randomChallenge.instruction, messageMotivationOTD: randomChallenge.messageMotivation, idChallenge: randomChallenge.id ?? UUID(), idUser: userID)
        
        
        try await challengeOfTheDay.create(on: req.db)
        return try ChallengeOfTheDayResponseDTO(from: challengeOfTheDay)
        
    }
    
    //MARK: - Get All ChallengeOfTheDay -> pour récupérer tous les challengeOfTheDay si plusieurs ont été crée
    
    @Sendable
    func indexChallengeOfThDay (_ req: Request) async throws -> [ChallengeOfTheDay] {
        try await ChallengeOfTheDay.query(on: req.db).all()
    }
    
    //MARK: - Get ChallengeOfTheDay -> pour récupérer le challenge du jour coté front
    
    @Sendable
    func getChallengeOfTheDay(_ req: Request) async throws -> ChallengeOfTheDayResponseDTO{
        guard let challengeOfTheDay = try await ChallengeOfTheDay.query(on: req.db).first() else{
            throw Abort(.notFound, reason: "Challenge of the day not available")
        }
        return try ChallengeOfTheDayResponseDTO(from: challengeOfTheDay)
    }
    
    //MARK: - Delete ChallengeOfTheDay -> pour supprimer l'assignation du challenge du jour à un challenge
    
    @Sendable
    func deleteChallengeOfTheDay(req: Request) async throws -> HTTPStatus {
        guard let challengeOfTheDay = try await ChallengeOfTheDay.find(req.parameters.get("challengeID", as: UUID.self), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await challengeOfTheDay.delete(on: req.db)
        return .noContent
        
    }
    
    //MARK: - Delete All ChallengeOfTheDay afin de n'en laisser qu'un / ou vide
    
    @Sendable
    func deleteAllChallengeOfTheDay(_ req: Request) async throws -> HTTPStatus {
        let challengeOfTheDay = try await ChallengeOfTheDay.query(on: req.db).all()
        
        try await challengeOfTheDay.delete(on: req.db)
        return .noContent
    }
    
}
