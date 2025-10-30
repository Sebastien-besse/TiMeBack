//
//  File.swift
//  TiMeBack
//
//  Created by Apprenant125 on 17/10/2025.
//

import Vapor

struct ChallengeOfTheDayController : RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        
        let challengeOfTheDay = routes.grouped("challengeOfTheDay")
        let protectedRoutes = challengeOfTheDay.grouped(JWTMiddleware())
        
        protectedRoutes.post("randomChallengeOTD", use: postRandomChallengeOfTheDay)
        protectedRoutes.get("get_challenge_of_the_day", use: getChallengeOfTheDay)
        protectedRoutes.delete("deleteForToday", use: deleteChallengeOfTheDay)
    }
    
    //MARK: - Post ChallengeOfTheDay.random -> ajout d'un challenge aléatoire en tant que challenge du jour
    
    
    @Sendable
    func postRandomChallengeOfTheDay(_ req : Request) async throws -> ChallengeOfTheDay{
        //je récupère le challenge aléatoire ici
        let randomChallenge = try await Challenge.query(on: req.db).all().randomElement() ?? Challenge()
        
        // ici on recherche l'utilisateur dans la base de données en utilisant l'ID extrait du payload
        let payload = try req.auth.require(UserPayload.self)
        guard let user = try await User.find(payload.id, on: req.db) else {
            throw Abort (.notFound, reason: "user hasn't been found")
        }
        //instanciation du challengeOfTheDay ici
        if #available(iOS 15, *) {
            let randomChallengeOTD = ChallengeOfTheDay(dateExp: Date.now, instructionOTD: randomChallenge.instruction, messageMotivationOTD: randomChallenge.messageMotivation, idChallenge: try randomChallenge.requireID(), idUser: try user.requireID())
            // ici le RequireId assure un id de type UUID lorsque l'objet n'est pas encore instancié
            
            //creation du challenge ici
            try await randomChallengeOTD.create(on: req.db)
            
            return randomChallengeOTD
            
            
        } else {
            let randomChallengeOTD = ChallengeOfTheDay(dateExp: Date(), instructionOTD: randomChallenge.instruction, messageMotivationOTD: randomChallenge.messageMotivation, idChallenge: try randomChallenge.requireID(), idUser: try user.requireID())
            
            //creation du challenge ici
            try await randomChallengeOTD.create(on: req.db)
            
            return randomChallengeOTD
        }
    }

    //MARK: - Get ChallengeOfTheDay -> pour récupérer le challenge du jour coté front
    
    @Sendable
    func getChallengeOfTheDay(_ req: Request) async throws -> ChallengeOfTheDay{
        try await ChallengeOfTheDay.query(on: req.db).first() ?? Abort(.notFound) as! ChallengeOfTheDay
    }
    
    //MARK: - Delete ChallengeOfTheDay -> pour supprimer l'assignation du challenge du jour à un challenge
    
    @Sendable
    func deleteChallengeOfTheDay(req: Request) async throws -> HTTPStatus {
        guard let challengeOfTheDay = try await ChallengeOfTheDay.find(req.parameters.require("challengeID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await challengeOfTheDay.delete(on: req.db)
        return .noContent
        
    }

}
