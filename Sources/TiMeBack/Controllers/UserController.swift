//
//  File.swift
//  TiMeBack
//
//  Created by Sebastien Besse on 26/09/2025.
//

import Vapor

struct UserController: RouteCollection{
   
    func boot(routes: any RoutesBuilder) throws{
        let users = routes.grouped("users")
        users.post(use: createUser)
    }
    
    func createUser(_ req: Request) async throws -> UserPublicDTO{
        let dto = try req.content.decode(CreateUserDTO.self)
        let user = User(userName: dto.userName, firstName: dto.firstName, lastName: dto.lastName, email: dto.email, password: dto.password, role: User.Role.user)
        try await user.create(on: req.db)
        return try UserPublicDTO(from: user)
    }
}
    
    

