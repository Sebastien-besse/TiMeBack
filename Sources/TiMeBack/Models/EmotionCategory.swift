//
//  EmotionCategory.swift
//  TiMeBack
//
//  Created by Assistant on 03/10/2025.
//

import Fluent
import Vapor

final class EmotionCategory: Model, Content, @unchecked Sendable {

    //MARK: lien à la table
    static let schema = "categoryEmotions"

    //MARK: Atributs liés aux colonnes
    @ID(custom: "id_category_emotion")
    var id: UUID?

    @Field(key: "title")
    var title: String
    
    @Field(key: "color")
    var color: String
    
    //MARK: Relation
    //est lié à Emotion

    //MARK: Constructeur
    init() {}

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
        self.color = color
    }
}
