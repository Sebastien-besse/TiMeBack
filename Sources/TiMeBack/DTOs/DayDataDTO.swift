//
//  DayDataDTO.swift
//  TiMeBack
//
//  Created by Thibault on 19/10/2025.
//

import Vapor

//MARK: - DayDataDTO
/// DTO qui agrège toutes les données d'un jour
/// Utilisé par le DayController pour retourner emotion + heartLevel + motivation + page en un seul appel
struct DayDataDTO: Content {
    let date: Date
    let emotion: EmotionWithDetailsDTO?
    let heartLevel: HeartLevelDTO?
    let motivation: MotivationDTO?
    let page: PageDTO?
}

//MARK: - EmotionWithDetailsDTO
struct EmotionWithDetailsDTO: Content, Identifiable {
    let id: UUID?
    let date: Date
    let emotionId: UUID
    let emotionTitle: String
    let emotionColor: String
    let categoryId: UUID
    let categoryTitle: String
    
    /// Crée le DTO à partir des 3 tables jointes
    init(
        emotionOfTheDay: EmotionOfTheDay,
        emotion: Emotion,
        category: EmotionCategory
    ) {
        self.id = emotionOfTheDay.id
        self.date = emotionOfTheDay.date
        self.emotionId = emotionOfTheDay.$emotion.id
        self.emotionTitle = emotion.title
        self.emotionColor = category.color
        self.categoryId = emotion.$category.id
        self.categoryTitle = category.title
    }
}
