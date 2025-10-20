//
//  Motivation.swift
//  TiMeBack
//
//  Created by Thibault on 17/10/2025.
//

import Fluent
import Vapor

final class Motivation: Model, Content, @unchecked Sendable {
    
    //MARK: lien à la table
    static let schema = "motivations"
    
    //MARK: Attributs liés aux colonnes
    @ID(custom: "id_motivation")
    var id: UUID?
    
    @Field(key: "motivation")
    var motivation: Int
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Parent(key: "id_user")
    var user: User
    
    //MARK: Relation
    //est lié à User
    // est lié à CreateJournal
    
    init() {}
    
    init(
        id: UUID? = nil,
        motivation: Int,
        userID: User.IDValue
    ) {
        self.id = id
        self.motivation = motivation
        self.$user.id = userID
    }
}
