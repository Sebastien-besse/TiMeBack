//
//  EmotionDTO.swift
//  TiMeBack
//
//  Created by Thibault on 03/10/2025.
//

import Vapor

struct EmotionDTO: Content, Identifiable {
    let id: UUID?
    let title: String
    let idCategoryEmotion: UUID?
    
    init(from emotion: Emotion) {
        self.id = emotion.id
        self.title = emotion.title
        self.idCategoryEmotion = emotion.idCategoryEmotion
    }
}

struct EmotionCreate: Content {
    let title: String
    let idCategoryEmotion: UUID?
}

struct EmotionUpdate: Content {
      let title: String?
      let idCategoryEmotion: UUID?
  }
