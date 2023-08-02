//
//  Codables.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 18.10.21.
//

import Foundation

struct RecipesResponse: Decodable {
    let recipes: [Recipe]
}

struct AuthenticationResponse: Decodable {
    let authToken: String
}

struct RegistrationResponse: Decodable {
    let id: String
}

struct AddRecipeResponse: Decodable {
    let id: String
}

struct RecipeParameters: Encodable {
    let name: String
    let imageURL: String
    let ingredients: String
    let steps: String
}

struct AuthenticationParameters: Encodable {
    let email: String
    let password: String
}

