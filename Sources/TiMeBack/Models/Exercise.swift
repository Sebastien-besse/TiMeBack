//
//  Exercise.swift
//  TiMeBack
//
//  Created by Thibault on 29/10/2025.
//


import Fluent
import Vapor

final class Exercise: Model, Content, @unchecked Sendable {
    static let schema = "exercices"
    
    @ID(custom: "id_exercice")
    var id: UUID?
    
    @Field(key: "instruction")
    var instruction: String
    
    @Field(key: "image")
    var image: String
    
    @OptionalField(key: "id_challenge")
    var challengeID: UUID?
    
    init() {}
    
    init(id: UUID? = nil, instruction: String, image: String, challengeID: UUID? = nil) {
        self.id = id
        self.instruction = instruction
        self.image = image
        self.challengeID = challengeID
    }
}
