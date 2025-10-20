//
//  PageDTO.swift
//  TiMeBack
//
//  Created by Thibault on 19/10/2025.
//

import Vapor

//MARK: - PageDTO
struct PageDTO: Content, Identifiable {
    let id: UUID?
    let note: String
    let createdAt: Date
    let idUser: UUID
    
    init(from page: Page) {
        self.id = page.id
        self.note = page.note
        self.createdAt = page.createdAt ?? Date()
        self.idUser = page.$user.id
    }
}

struct PageCreate: Content {
    let note: String
    let idUser: UUID
}

struct PageUpdate: Content {
    let note: String?
}
