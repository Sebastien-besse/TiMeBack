//
//  EmotionCategoryDTO.swift
//  TiMeBack
//
//  Created by Assistant on 03/10/2025.
//

import Vapor

struct EmotionCategoryDTO: Content, Identifiable {
    let id: UUID?
    let title: String

    init(from category: EmotionCategory) {
        self.id = category.id
        self.title = category.title
    }
}

struct EmotionCategoryCreate: Content {
    let title: String
}

struct EmotionCategoryUpdate: Content {
    let title: String
}
