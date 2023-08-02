//
//  HTTPRequestService.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 24.10.21.
//

import UIKit

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}

protocol HTTPRequestServiceProtocol {
    func sendLoginRequest(request: URLRequest, completion: @escaping ((Result<String, NetworkError>) -> Void ))
    func sendRegisterRequest(request: URLRequest, completion: @escaping ((Result<String?, NetworkError>) -> Void ))
    func sendGetAllRecipesRequest(request: URLRequest, completion: @escaping ((Result<[Recipe], NetworkError>) -> Void ))
    func sendAddRecipeRequest(request: URLRequest, completion: @escaping ((Result<String, NetworkError>) -> Void ))
    func sendEditRecipeRequest(request: URLRequest, completion: @escaping ((Result<String, NetworkError>) -> Void ))
    func sendDeleteRecipeRequest(request: URLRequest, completion: @escaping ((Result<String?, NetworkError>) -> Void ))
    func sendDownloadImageRequest(url: URL, completion: @escaping ((Result<ImageRequestResponse, NetworkError>) -> Void ))
}

class HTTPRequestService: HTTPRequestServiceProtocol {
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func sendLoginRequest(request: URLRequest, completion: @escaping ((Result<String, NetworkError>) -> Void )) {
        session.dataTask(with: request) { (data, response, error) in
            if !self.isResponseSuccess(response: response) {
                completion(.failure(.responseError))
                return
            }
            let responseData = self.decodeResponseData(data: data, type: AuthenticationResponse.self)
            if let responseData = responseData {
                completion(.success(responseData.authToken))
            }
            else {
                completion(.failure(.authenticationError))
            }
        }.resume()
    }
    
    func sendRegisterRequest(request: URLRequest, completion: @escaping ((Result<String?, NetworkError>) -> Void )) {
        
        session.dataTask(with: request) { (data, response, error) in
            if !self.isResponseSuccess(response: response) {
                completion(.failure(.responseError))
                return
            }
            let responseData = self.decodeResponseData(data: data, type: RegistrationResponse.self)
            if let responseData = responseData {
                //return it so we can test
                completion(.success(responseData.id))
            }
            else {
                completion(.failure(.authenticationError))
            }
        }.resume()
    }
    
    func sendGetAllRecipesRequest(request: URLRequest, completion: @escaping ((Result<[Recipe], NetworkError>) -> Void )) {
        session.dataTask(with: request) { (data, response, error) in
            if !self.isAuthorized(response: response) {
                completion(.failure(.authenticationError))
                return
            }
            if !self.isResponseSuccess(response: response) {
                completion(.failure(.responseError))
                return
            }
            
            let responseData = self.decodeResponseData(data: data, type: RecipesResponse.self)
            if let responseData = responseData {
                completion(.success(responseData.recipes))
            }
            else {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func sendAddRecipeRequest(request: URLRequest, completion: @escaping ((Result<String, NetworkError>) -> Void )) {
        session.dataTask(with: request) { (data, response, error) in
            if !self.isAuthorized(response: response) {
                completion(.failure(.authenticationError))
                return
            }
            if !self.isResponseSuccess(response: response) {
                completion(.failure(.responseError))
                return
            }
            
            let responseData = self.decodeResponseData(data: data, type: AddRecipeResponse.self)
            if let responseData = responseData {
                completion(.success(responseData.id))
            }
            else {
                completion(.failure(.decodingError))
            }
            
        }.resume()
    }
    
    func sendEditRecipeRequest(request: URLRequest, completion: @escaping ((Result<String, NetworkError>) -> Void )) {
        session.dataTask(with: request) { (data, response, error) in
            if !self.isAuthorized(response: response) {
                completion(.failure(.authenticationError))
                return
            }
            if !self.isResponseSuccess(response: response) {
                completion(.failure(.responseError))
                return
            }
            
            let responseData = self.decodeResponseData(data: data, type: AddRecipeResponse.self)
            if let responseData = responseData {
                completion(.success(responseData.id))
            }
            else {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func sendDeleteRecipeRequest(request: URLRequest, completion: @escaping ((Result<String?, NetworkError>) -> Void )) {
        session.dataTask(with: request) { (data, response, error) in
            if !self.isAuthorized(response: response) {
                completion(.failure(.authenticationError))
                return
            }
            if !self.isResponseSuccess(response: response) {
                completion(.failure(.responseError))
                return
            }
            if data != nil {
                completion(.success(nil))
            }
            else {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func sendDownloadImageRequest(url: URL, completion: @escaping ((Result<ImageRequestResponse, NetworkError>) -> Void )) {
        session.dataTask(with: url) { (data, response, error) in
            if !self.isResponseSuccess(response: response) {
                completion(.failure(.responseError))
                return
            }
            guard let responseData = data, let image = UIImage(data: responseData)?.forceLoad() else {
                completion(.failure(.decodingError))
                return
            }
            let results = ImageRequestResponse(image: image, url: url, cost: responseData.count)
            
                completion(.success(results))
        }.resume()
    }
    
    private func decodeResponseData<T>(data: Data?, type: T.Type) -> T? where T: Decodable{
        if let data = data {
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode(type, from: data)
                return json
            } catch {
                return nil
            }
        }
        return nil
    }
    
    private func isResponseSuccess(response: URLResponse?) -> Bool{
        if let response = response as? HTTPURLResponse , (200..<300).contains(response.statusCode) {
            //print(response)
            return true
        }
        else {
            return false
        }
    }
    
    private func isAuthorized(response: URLResponse?) -> Bool{
        if let response = response as? HTTPURLResponse , response.statusCode == 401 {
            return false
        }
        else {
            return true
        }
    }
}
