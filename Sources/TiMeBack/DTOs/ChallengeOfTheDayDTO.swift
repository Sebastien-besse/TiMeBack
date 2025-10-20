//
//  File.swift
//  TiMeBack
//
//  Created by Apprenant125 on 17/10/2025.
//

import Vapor

struct ChallengeOfTheDayUpdateDTO : Content {
    let dateExp : Date?
    let idChallenge: UUID?
}

struct ChallengeOfTheDayCreateDTO : Content {
    let instructionOTD : String
    let messageMotivationOTD : String
    let dateExp : Date
    let idChallenge : UUID
    let idUser : UUID
}

struct ChallengeOfTheDayResponseDTO : Content {
    let id : UUID?
    let instructionOTD : String
    let messageMotivationOTD : String
    let dateExp : Date
    let idChallenge : UUID
    let idUser : UUID
}
