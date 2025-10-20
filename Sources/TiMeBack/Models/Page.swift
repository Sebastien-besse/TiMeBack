//
//  Page.swift
//  TiMeBack
//
//  Created by Thibault on 17/10/2025.
//

import Fluent
import Vapor

final class Page: Model, Content, @unchecked Sendable {
    
    static let schema = "pages"
    
    @ID(custom: "id_page")
    var id: UUID?
    
    @Field(key: "note")
    var note: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Parent(key: "id_user")
    var user: User
    
    init() {}
    
    init(
        id: UUID? = nil,
        note: String,
        userID: User.IDValue
    ) {
        self.id = id
        self.note = note
        self.$user.id = userID
    }
}
