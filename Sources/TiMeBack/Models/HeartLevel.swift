//
//  HeartLevel.swift
//  TiMeBack
//
//  Created by Thibault on 17/10/2025.
//

import Fluent
import Vapor

final class HeartLevel: Model, Content, @unchecked Sendable {
    
    //MARK: lien à la table
    static let schema = "heartLevel"
    
    //MARK: Attributs liés aux colonnes
    @ID(custom: "id_heartLevel")
    var id: UUID?
    
    @Field(key: "level")
    var level: Int
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Parent(key: "id_user")
    var user: User
    
    //MARK: Relation
    //est lié à User
    //est lié à EmotionOfTheDay
    // est lié à CreateJournal
    
    init() {}
    
    init(
        id: UUID? = nil,
        level: Int,
        userID: User.IDValue
    ) {
        self.id = id
        self.level = level
        self.$user.id = userID
    }
}
