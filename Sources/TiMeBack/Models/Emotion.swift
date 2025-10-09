//
//  File.swift
//  TiMeBack
//
//  Created by Thibault on 03/10/2025.
//

import Fluent
import Vapor

final class Emotion: Model, Content, @unchecked Sendable {
    
    //MARK: lien à la table
    static let schema = "emotions"
    
    //MARK: Atributs liés aux colonnes
    @ID(custom: "id_emotion")
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Parent(key: "id_category_emotion")
    var category: EmotionCategory
    
    //MARK: Relation
    //est lié à CategoryEmotion
    
    //MARK: Constructeurs
    init() {}

    init(id: UUID? = nil, title: String, categoryID: EmotionCategory.IDValue) {
        self.id = id
        self.title = title
        self.$category.id = categoryID
    }
}
