//
//  File.swift
//  TiMeBack
//
//  Created by Sebastien Besse on 26/09/2025.
//

import Vapor

struct CreateUserDTO: Content{
    var firstName: String
    var lastName: String
    var userName: String
    var email: String
    var password: String
}

struct UserPublicDTO: Content{
    var id: UUID?
    var firstName: String
    var lastName: String
    var userName: String
    var email: String
    var streakNumber: Int
    var challengeNumber: Int
}

extension UserPublicDTO{
    init(from user: User) throws {
        self.id = try user.requireID()
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.userName = user.userName
        self.email = user.email
        self.streakNumber = user.streakNumber
        self.challengeNumber = user.challengeNumber
    }
}
