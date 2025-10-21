////
////  PrivateJournalController.swift
////  TiMeBack
////
////  Created by Thibault on 15/10/2025.
////
//
//import Vapor
//import Fluent
//
//struct PrivateJournalController: RouteCollection {
//    func boot(routes: any RoutesBuilder) throws {
//        let journal = routes.grouped("journal")
//        
//        // GET /journal/day?date=2025-01-12T00:00:00Z&userId=xxx
//        journal.get("day", use: getDayData)
//    }
//    
//    @Sendable
//    func getDayData(_ req: Request) async throws -> DayDataDTO {
//        // Récupère les query parameters
//        guard let dateString = try? req.query.get(String.self, at: "date"),
//              let userIdString = try? req.query.get(String.self, at: "userId"),
//              let userId = UUID(uuidString: userIdString),
//              let date = ISO8601DateFormatter().date(from: dateString)
//        else {
//            throw Abort(.badRequest, reason: "Paramètres invalides (date ou userId manquant)")
//        }
//        
//        // Définir le début et la fin du jour
//        let calendar = Calendar.current
//        let startOfDay = calendar.startOfDay(for: date)
//        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
//        
//        // Requêtes parallèles pour toutes les données du jour
//        async let emotionData = EmotionOfTheDay.query(on: req.db)
//            .filter(\.$user.$id == userId)
//            .filter(\.$date >= startOfDay)
//            .filter(\.$date < endOfDay)
//            .with(\.$emotion)
//            .first()
//        
//        async let heartLevelData = HeartLevel.query(on: req.db)
//            .filter(\.$user.$id == userId)
//            .filter(\.$createdAt >= startOfDay)
//            .filter(\.$createdAt < endOfDay)
//            .first()
//        
//        async let motivationData = Motivation.query(on: req.db)
//            .filter(\.$user.$id == userId)
//            .filter(\.$createdAt >= startOfDay)
//            .filter(\.$createdAt < endOfDay)
//            .first()
//        
//        async let pageData = Page.query(on: req.db)
//            .filter(\.$user.$id == userId)
//            .filter(\.$createdAt >= startOfDay)
//            .filter(\.$createdAt < endOfDay)
//            .first()
//        
//        // Attend toutes les réponses
//        let (emotion, heartLevel, motivation, page) = try await (
//            emotionData, heartLevelData, motivationData, pageData
//        )
//        
//        // Construit le DTO
//        let emotionDTO: EmotionDetailDTO? = if let emotion = emotion, let emotionDetail = emotion.$emotion.value {
//            EmotionDetailDTO(from: emotion, emotion: emotionDetail)
//        } else {
//            nil
//        }
//        
//        return DayDataDTO(
//            date: dateString,
//            emotion: emotionDTO,
//            heartLevel: heartLevel.map { HeartLevelDTO(from: $0) },
//            motivation: motivation.map { MotivationDTO(from: $0) },
//            page: page.map { PageDTO(from: $0) }
//        )
//    }
//}
