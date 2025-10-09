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
    let categoryID: UUID?
    
    init(from emotion: Emotion) {
        self.id = emotion.id
        self.title = emotion.title
        self.categoryID = emotion.$category.id
    }
}

struct EmotionCreate: Content {
    let title: String
    let categoryID: UUID
}

struct EmotionUpdate: Content {
      let title: String?
      let categoryID: UUID?
  }
