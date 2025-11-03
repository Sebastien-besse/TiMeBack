//
//  ExerciseDTO.swift
//  TiMeBack
//
//  Created by Thibault on 29/10/2025.
//

import Vapor
import Foundation

//MARK: - ExerciseDTO (pour les réponses)
struct ExerciseDTO: Content {
    let id: UUID?
    let instruction: String
    let image: String
    let challengeID: UUID?
    
    init(from exercise: Exercise) {
        self.id = exercise.id
        self.instruction = exercise.instruction
        self.image = exercise.image
        self.challengeID = exercise.challengeID
    }
}

//MARK: - ExerciseCreate (pour créer un exercice)
struct ExerciseCreate: Content {
    let instruction: String
    let image: String
    let challengeID: UUID?
}

//MARK: - ExerciseUpdate (pour modifier un exercice)
struct ExerciseUpdate: Content {
    let instruction: String?
    let image: String?
    let challengeID: UUID?
}
