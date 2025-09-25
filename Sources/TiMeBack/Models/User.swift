//
//  File.swift
//  TiMeBack
//
//  Created by Sebastien Besse on 25/09/2025.
//

import Vapor
import Fluent

final class User: Model, Content, @unchecked Sendable{
    
    static let schema = "User"
    
    @ID(key: .id)
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
    var streakNumber: Int?
    
    @Field(key: "role")
    var role: String
    
    @Field(key: "challenge_number")
    var challengeNumber: Int
    
    init() {}
    
    init(userName: String, firstName: String, lastName: String, email: String, password: String, streakNumber: Int?, role: String, challengeNumber: Int ){
        self.userName = userName
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.streakNumber = streakNumber ?? 0
        self.role = role
        self.challengeNumber = challengeNumber
    }
}



