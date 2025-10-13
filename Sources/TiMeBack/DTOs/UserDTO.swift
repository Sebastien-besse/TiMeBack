//
//  File.swift
//  TiMeBack
//
//  Created by Sebastien Besse on 26/09/2025.
//

import Vapor

struct UserDTO: Content{
    var id: UUID?
    var firstName: String
    var lastName: String
    var userName: String
    var email: String
    var imageProfil: String?
    
    func toModel() -> User {
        return User(userName: userName, firstName: firstName, lastName: lastName, email: email, password: "default", role: .user, imageProfil: "")
    }
    
}

struct CreateUserDTO: Content{
    var firstName: String
    var lastName: String
    var userName: String
    var email: String
    var password: String
    var imageProfil: String?
}

struct UserPublicDTO: Content{
    var id: UUID?
    var firstName: String
    var lastName: String
    var userName: String
    var email: String
    var streakNumber: Int
    var challengeNumber: Int
    var imageProfil: String?
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
        self.imageProfil = user.imageProfil
    }
}
