//
//  File.swift
//  TiMeBack
//
//  Created by Apprenant125 on 17/10/2025.
//

import Vapor

struct ChallengeOfTheDayCreateDTO : Content {
    let instruction : String
    let messageMotivation : String
    let idChallenge : UUID
    let idUser : UUID
}

struct ChallengeOfTheDayUpdateDTO : Content {
    let dateExp : Date?
    let idChallenge: UUID?
}

struct ChallengeOfTheDayResponseDTO : Content {
    let id : UUID?
    let instructionOTD : String
    let messageMotivationOTD : String
    let dateExp : Date
    let idChallenge : UUID
    let idUser : UUID
}

extension ChallengeOfTheDayResponseDTO {
    init(from cOTD:ChallengeOfTheDay) throws {
        self.init(id: cOTD.id, instructionOTD: cOTD.instructionOTD, messageMotivationOTD: cOTD.messageMotivationOTD, dateExp: cOTD.dateExp ?? Date.now, idChallenge:  cOTD.$idChallenge.id , idUser:  cOTD.$idUser.id)
        
    }
}
