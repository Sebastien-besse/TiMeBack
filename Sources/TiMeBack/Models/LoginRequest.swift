//
//  File.swift
//  TiMeBack
//
//  Created by apprenant152 on 10/10/2025.
//

import Vapor

struct LoginRequest: Content{
    let email: String?
    let username: String?
    let password: String
}
