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
    
    @Field(key: "id_user")
    var idUser: UUID
    
    @Field(key: "id_emotion")
    var idEmotion: UUID
    
    init() {}
    
    init(
        id: UUID? = nil,
        date: Date,
        idUser: UUID,
        idEmotion: UUID
    ) {
        self.id = id
        self.date = date
        self.idUser = idUser
        self.idEmotion = idEmotion
    }
}
