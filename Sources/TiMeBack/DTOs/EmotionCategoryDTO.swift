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
    let color: String

    init(from category: EmotionCategory) {
        self.id = category.id
        self.title = category.title
        self.color = category.color
    }
}

struct EmotionCategoryCreate: Content {
    let title: String
    let color: String
}

struct EmotionCategoryUpdate: Content {
    let title: String
    let color: String
}


struct EmotionCategoryStatsDTO: Content {
    var categoryId: UUID
    var categoryTitle: String
    var color: String
    var count: Int
}
