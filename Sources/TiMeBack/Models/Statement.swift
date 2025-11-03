//
//  Statement.swift
//  TiMeBack
//
//  Created by Thibault on 29/10/2025.
//


import Fluent
import Vapor

final class Statement: Model, Content, @unchecked Sendable {
    static let schema = "statements"
    
    @ID(custom: "id_statement")
    var id: UUID?
    
    @Field(key: "sentence")
    var sentence: String
    
    @Field(key: "date")
    var date: Date
    
    init() {}
    
    init(id: UUID? = nil, sentence: String, date: Date) {
        self.id = id
        self.sentence = sentence
        self.date = date
    }
}
