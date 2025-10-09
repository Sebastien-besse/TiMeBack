//
//  EmotionOfTheDayDTO.swift
//  TiMeBack
//
//  Created by Thibault on 05/10/2025.
//

import Vapor

struct EmotionOfTheDayDTO: Content, Identifiable {
    let id: UUID?
    let date: Date
    let idUser: UUID
    let idEmotion: UUID
    
    init(from emotionOfTheDay: EmotionOfTheDay) {
        self.id = emotionOfTheDay.id
        self.date = emotionOfTheDay.date
        self.idUser = emotionOfTheDay.$user.id
        self.idEmotion = emotionOfTheDay.$emotion.id
    }
}

struct EmotionOfTheDayCreate: Content {
    let date: Date
    let idUser: UUID
    let idEmotion: UUID
}

struct EmotionOfTheDayUpdate: Content {
    let date: Date?
    let idEmotion: UUID?
}
