//
//  MotivationDTO.swift
//  TiMeBack
//
//  Created by Thibault on 19/10/2025.
//

import Vapor

//MARK: - MotivationDTO
struct MotivationDTO: Content, Identifiable {
    let id: UUID?
    let motivation: Int
    let createdAt: Date
    let idUser: UUID
    
    init(from motivation: Motivation) {
        self.id = motivation.id
        self.motivation = motivation.motivation
        self.createdAt = motivation.createdAt ?? Date()
        self.idUser = motivation.$user.id
    }
}

struct MotivationCreate: Content {
    let motivation: Int
    let idUser: UUID
}

struct MotivationUpdate: Content {
    let motivation: Int?
}
