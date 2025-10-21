//
//  DayController.swift
//  TiMeBack
//
//  Created by Thibault on 19/10/2025.
//


import Vapor
import Fluent

struct DayController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let day = routes.grouped("day")
        
        // GET /day/:userId/:date - Récupère toutes les données d'un jour
        day.get(":userId", ":date", use: getDayData)
    }
    
    //MARK: - GET toutes les données d'un jour spécifique
    /// Cette route effectue un double JOIN pour récupérer :
    /// - L'émotion du jour avec son titre (emotionOfTheDay → emotions)
    /// - La couleur de la catégorie (emotions → categoryEmotions)
    /// - Le niveau de cœur
    /// - La motivation
    /// - La page de journal
    ///
    /// Tout ça en 1 seul appel API !
    @Sendable
    func getDayData(_ req: Request) async throws -> DayDataDTO {
        // Étape 1 : Validation des paramètres
        guard let userIdString = req.parameters.get("userId"),
              let userId = UUID(uuidString: userIdString) else {
            throw Abort(.badRequest, reason: "userId invalide")
        }
        
        guard let dateString = req.parameters.get("date") else {
            throw Abort(.badRequest, reason: "date manquante")
        }
        
        // Décoder la date ISO8601 (ex: "2025-10-17T00:00:00Z")
        let formatter = ISO8601DateFormatter()
        guard let targetDate = formatter.date(from: dateString) else {
            throw Abort(.badRequest, reason: "Format de date invalide (utilisez ISO8601)")
        }
        
        // Étape 2 : Normalisation de la date (début et fin de journée)
        let calendar = Calendar.current
        guard let startOfDay = calendar.startOfDay(for: targetDate) as Date?,
              let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            throw Abort(.internalServerError, reason: "Erreur de calcul de date")
        }
        
        // Étape 3 : Récupération de l'émotion du jour
        let emotionOfTheDay = try await EmotionOfTheDay.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$date >= startOfDay)
            .filter(\.$date < endOfDay)
            .first()
        
        // Étape 4 : JOIN pour récupérer le titre de l'émotion ET la couleur
        var emotionWithDetails: EmotionWithDetailsDTO? = nil
        
        if let eotd = emotionOfTheDay {
            // JOIN avec emotions pour avoir le titre
            if let emotion = try await Emotion.find(eotd.$emotion.id, on: req.db) {
                // JOIN avec categoryEmotions pour avoir la couleur
                if let category = try await EmotionCategory.find(emotion.$category.id, on: req.db) {
                    emotionWithDetails = EmotionWithDetailsDTO(
                        emotionOfTheDay: eotd,
                        emotion: emotion,
                        category: category
                    )
                }
            }
        }
        
        // Étape 5 : Récupération du HeartLevel
        let heartLevel = try await HeartLevel.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$createdAt >= startOfDay)
            .filter(\.$createdAt < endOfDay)
            .first()
        
        // Étape 6 : Récupération de la Motivation
        let motivation = try await Motivation.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$createdAt >= startOfDay)
            .filter(\.$createdAt < endOfDay)
            .first()
        
        // Étape 7 : Récupération de la Page
        let page = try await Page.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$createdAt >= startOfDay)
            .filter(\.$createdAt < endOfDay)
            .first()
        
        // Étape 8 : Construction du DTO final
        return DayDataDTO(
            date: targetDate,
            emotion: emotionWithDetails,
            heartLevel: heartLevel.map { HeartLevelDTO(from: $0) },
            motivation: motivation.map { MotivationDTO(from: $0) },
            page: page.map { PageDTO(from: $0) }
        )
    }
}
