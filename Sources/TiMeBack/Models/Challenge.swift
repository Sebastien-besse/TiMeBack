//
//  File.swift
//  TiMeBack
//
//  Created by Apprenant125 on 29/09/2025.
//

import Fluent
import Vapor

final class Challenge: Model, Content, @unchecked Sendable {
    
    //MARK: lien à la table
    static let schema: String = "challenges"

    //MARK: Atributs liés aux colonnes
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "instruction")
    var instruction : String
    
    @Field(key: "message_motivation")
    var messageMotivation : String
    
    //MARK: Relation
    //est lié à exercices
    
    
    
    //MARK: Constructeurs
    init() { }
    
    init(id: UUID? = nil, instruction: String, messageMotivation: String) {
        self.id = id
        self.instruction = instruction
        self.messageMotivation = messageMotivation
    }
    
}
