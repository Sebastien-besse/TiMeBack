//
//  EmotionOfTheDay.swift
//  TiMeBack
//
//  Created by Thibault on 05/10/2025.
//

import Fluent
import Vapor

final class EmotionOfTheDay: Model, Content, @unchecked Sendable {
    
    //MARK: lien à la table
    static let schema = "emotionOfTheDay"
    
    //MARK: Attributs liés aux colonnes
    @ID(custom: "id_emotion_of_the_day")
    var id: UUID?
    
    @Field(key: "date")
    var date: Date
    
    @Parent(key: "id_user")
    var user: User
    
    @Parent(key: "id_emotion")
    var emotion: Emotion
    
    //MARK: Relation
    //est lié à User
    //est lié à Emotion
    
    init() {}
    
    init(
        id: UUID? = nil,
        date: Date,
        userID: User.IDValue,
        emotionID: Emotion.IDValue
    ) {
        self.id = id
        self.date = date
        self.$user.id = userID
        self.$emotion.id = emotionID
    }
}
