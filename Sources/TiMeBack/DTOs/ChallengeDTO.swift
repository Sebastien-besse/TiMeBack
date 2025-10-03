//
//  ChallengeDTO.swift
//  TiMeBack
//
//  Created by Apprenant125 on 29/09/2025.
//

import Vapor


struct ChallengeCreateDTO: Content {
    let instruction : String
    let messageMotivation : String
}

struct ChallengeUpdateDTO: Content{
    let id : UUID?
    let instruction : String?
    let messageMotivation : String?
}

struct ChallengeResponseDTO: Content {
    let id : UUID?
    let instruction : String
    let messageMotivation : String
}

extension ChallengeResponseDTO {
    init(from c: Challenge) {
        self.init(id: c.id, instruction: c.instruction, messageMotivation: c.messageMotivation)
    }
}
