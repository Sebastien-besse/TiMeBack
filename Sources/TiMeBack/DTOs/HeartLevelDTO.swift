//
//  HeartLevelDTO.swift
//  TiMeBack
//
//  Created by Thibault on 19/10/2025.
//

import Vapor

//MARK: - HeartLevelDTO
struct HeartLevelDTO: Content, Identifiable {
    let id: UUID?
    let level: Int
    let createdAt: Date
    let idUser: UUID
    
    init(from heartLevel: HeartLevel) {
        self.id = heartLevel.id
        self.level = heartLevel.level
        self.createdAt = heartLevel.createdAt ?? Date()
        self.idUser = heartLevel.$user.id
    }
}

struct HeartLevelCreate: Content {
    let level: Int
    let idUser: UUID
}

struct HeartLevelUpdate: Content {
    let level: Int?
}
