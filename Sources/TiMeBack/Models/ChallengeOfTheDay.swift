//
//  ChallengeOfTheDay.swift
//  TiMeBack
//
//  Created by Apprenant125 on 17/10/2025.
//

import Fluent
import Vapor

final class ChallengeOfTheDay : Model, Content, @unchecked Sendable, Decodable{
    
    static let schema: String = "challengeOfTheDay"
    
    @ID(custom: "id_chellengeOfTheDay")
    var id: UUID?
    
    @Field(key: "date")
    var dateExp : Date
    
    @Field(key: "instruction")
    var instructionOTD : String
    
    @Field(key: "motivation_message")
    var messageMotivationOTD : String
    
    @Parent(key: "id_challenge")
    var idChallenge : Challenge
    
    @Parent(key: "id_user")
    var idUser : User
    

    init() {  }

    //foreign key de type UUID et non de type Challenge et User
    init(id: UUID? = nil, dateExp: Date, instructionOTD: String, messageMotivationOTD: String, idChallenge: UUID, idUser: UUID) {
        self.id = id
        self.dateExp = dateExp
        self.instructionOTD = instructionOTD
        self.messageMotivationOTD = messageMotivationOTD
        
        //ici mise en place du lien entre le @Parent pour aller chercher l'id direct à la source
        self.$idChallenge.id = idChallenge
        self.$idUser.id = idUser
    }
    
}
