    //
    //  StatementDTO.swift
    //  TiMeBack
    //
    //  Created by Thibault on 29/10/2025.
    //

import Vapor
import Foundation

    //MARK: - StatementDTO (pour les réponses)
struct StatementDTO: Content {
    let id: UUID?
    let sentence: String
    let date: Date
    
    init(from statement: Statement) {
        self.id = statement.id
        self.sentence = statement.sentence
        self.date = statement.date
    }
}

    //MARK: - StatementCreate (pour créer un statement)
struct StatementCreate: Content {
    let sentence: String
    let date: Date
}

    //MARK: - StatementUpdate (pour modifier un statement)
struct StatementUpdate: Content {
    let sentence: String?
    let date: Date?
}
