//
//  File.swift
//  TiMeBack
//
//  Created by Sebastien Besse on 25/09/2025.
//

import Vapor
import Fluent

final class User: Model, Content, @unchecked Sendable{
    
    //MARK: lien à la table
    static let schema = "users"
    
    //MARK: Atributs liés aux colonnes
    @ID(custom: "id_user")
    var id: UUID?
    
    @Field(key: "username")
    var userName: String
    
    @Field(key: "firstname")
    var firstName: String
    
    @Field(key: "lastname")
    var lastName: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "streak_number")
    var streakNumber: Int
    
    enum Role: String, Codable{
        case user
        case admin
    }
    
    @Enum(key: "role")
    var role: Role
    
    @Field(key: "challenge_number")
    var challengeNumber: Int
    
    @Field(key: "image")
    var imageProfil: String?
    
    //MARK: Relation
    
//    // est relié à Challenge Of The Day
//    @OptionalChild(for: \.$idUser)
//    var idUser : ChallengeOfTheDay?

    
    //MARK: Constructeur
    
    init(){
        self.id = UUID()
    }

    
    init(id: UUID? = nil, userName: String, firstName: String, lastName: String, email: String, password: String, streakNumber: Int = 0, role: Role, challengeNumber: Int = 0, imageProfil: String, idUser : ChallengeOfTheDay? = nil){
        self.id = id ?? UUID()
        self.userName = userName
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.streakNumber = streakNumber
        self.role = role
        self.challengeNumber = challengeNumber
        self.imageProfil = imageProfil
//        self.idUser = idUser
    }
    
    func toDTO()->UserDTO{
        return UserDTO(firstName: firstName, lastName: lastName, userName: userName, email: email, streakNumber: streakNumber, challengeNumber: challengeNumber)
    }
}
