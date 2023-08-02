//
//  AuthenticationService.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 14.10.21.
//

import UIKit

enum NetworkError: Error {
    case responseError
    case authenticationError
    case loginError
    case decodingError
    case registrationError
}

protocol HTTPClientProtocol {
    func getAllRecipes(completion: @escaping ((Result<[Recipe], NetworkError>) -> Void))
    func addRecipe(parameters: RecipeParameters, completion: @escaping ((Result<String, NetworkError>) -> Void))
    func editRecipe(parameters: RecipeParameters, recipeID: String, completion: @escaping ((Result<String, NetworkError>) -> Void))
    func deleteRecipe(recipeID: String, completion: @escaping ((Result<String?, NetworkError>) -> Void))
    func downloadImage(url: URL, completion: @escaping ((Result<ImageRequestResponse, NetworkError>) -> Void ))
    func login(parameters: AuthenticationParameters, completion: @escaping ((Result<String, NetworkError>) -> Void ))
    
}

class HTTPClient: HTTPClientProtocol {
    private let requestService: HTTPRequestServiceProtocol
    
    init(requestService: HTTPRequestServiceProtocol = HTTPRequestService()) {
        self.requestService = requestService
    }
    
    func login(parameters: AuthenticationParameters, completion: @escaping ((Result<String, NetworkError>) -> Void )) {
        let request = setUpAuthenticationRequest(url: Constants.singinURL, httpMethod: "POST", parameters: parameters)
        
        requestService.sendLoginRequest(request: request, completion: {
            result in
            switch result {
            case .success(let token):
                UserDefaults.standard.set(token, forKey: Constants.authToken)
                UserDefaults.standard.set(parameters.email, forKey: Constants.userEmail)
                completion(.success(token))
            case .failure:
                completion(.failure(.authenticationError))
            }
        })
    }
    
    func register(parameters: AuthenticationParameters, completion: @escaping ((Result<String?, NetworkError>) -> Void )) {
        let request = setUpAuthenticationRequest(url: Constants.singupURL, httpMethod: "POST", parameters: parameters)
        
        requestService.sendRegisterRequest(request: request, completion: {
            result in
            switch result {
            case .success(let id):
                completion(.success(id))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    
    func getAllRecipes(completion: @escaping ((Result<[Recipe], NetworkError>) -> Void )) {
        let request = setUpRequest(url: Constants.getAllRecipesURL, httpMethod: "GET", parameters: nil)
        
        requestService.sendGetAllRecipesRequest(request: request, completion: {
            result in
            switch result {
            case .success(let recipes):
                completion(.success(recipes))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func addRecipe(parameters: RecipeParameters, completion: @escaping ((Result<String, NetworkError>) -> Void )) {
        let request = setUpRequest(url: Constants.getAllRecipesURL, httpMethod: "POST", parameters: parameters)
        
        requestService.sendAddRecipeRequest(request: request, completion: {
            result in
            switch result {
            case .success(let id):
                completion(.success(id))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func editRecipe(parameters: RecipeParameters, recipeID: String, completion: @escaping ((Result<String, NetworkError>) -> Void )) {
        let url = URL(string: Constants.editRecipeString + "/" + recipeID)!
        let request = setUpRequest(url: url, httpMethod: "PUT", parameters: parameters)
        
        requestService.sendEditRecipeRequest(request: request, completion: {
            result in
            switch result {
            case .success(let id):
                completion(.success(id))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func deleteRecipe(recipeID: String, completion: @escaping ((Result<String?, NetworkError>) -> Void )) {
        let url = URL(string: Constants.editRecipeString + "/" + recipeID)!
        let request = setUpRequest(url: url, httpMethod: "DELETE", parameters: nil)
        
        requestService.sendDeleteRecipeRequest(request: request, completion: {
            result in
            switch result {
            case .success:
                completion(.success(nil))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func downloadImage(url: URL, completion: @escaping ((Result<ImageRequestResponse, NetworkError>) -> Void )) {
        
        requestService.sendDownloadImageRequest(url: url, completion: {
            result in
            switch result {
            case .success(let imageResponse):
                completion(.success(imageResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    private func setUpAuthenticationRequest(url: URL, httpMethod: String, parameters: AuthenticationParameters) -> URLRequest{
        var request = URLRequest(url: url)
        let encoder = JSONEncoder()
        do {
            let httpBody = try encoder.encode(parameters)
            request.httpMethod = httpMethod
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody
        } catch let error {
            print(error)
        }
        return request
    }
    
    private func setUpRequest(url: URL, httpMethod: String, parameters: RecipeParameters?) -> URLRequest{
        var request = URLRequest(url: url)
        let encoder = JSONEncoder()
        do {
            if let parameters = parameters {
                let httpBody = try encoder.encode(parameters)
                request.httpBody = httpBody
            }
            request.httpMethod = httpMethod
            let token = UserDefaults.standard.string(forKey: Constants.authToken) ?? ""
            request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        } catch let error {
            print(error)
        }
        return request
    }
}
