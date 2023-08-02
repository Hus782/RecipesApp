//
//  HTTPClientTests.swift
//  RecipesAppTests
//
//  Created by Hyusein Hyusein on 26.10.21.
//

import XCTest
@testable import RecipesApp

class MockRequestService: HTTPRequestServiceProtocol {
    var recipes: [Recipe] = []
    var isGetRecipesSuccess = true
    var isAddRecipeSuccess = true
    var isEditRecipeSuccess = true
    var isDeleteRecipeSuccess = true
    var isLoginSuccess = true
    var isRegisterSuccess = true

    func sendLoginRequest(request: URLRequest, completion: @escaping ((Result<String, NetworkError>) -> Void)) {
        isLoginSuccess ? completion(.success("token")) : completion(.failure(.responseError))
    }
    
    func sendRegisterRequest(request: URLRequest, completion: @escaping ((Result<String?, NetworkError>) -> Void)) {
        isRegisterSuccess ? completion(.success("id")) : completion(.failure(.responseError))
    }
    
    func sendGetAllRecipesRequest(request: URLRequest, completion: @escaping ((Result<[Recipe], NetworkError>) -> Void)) {
        isGetRecipesSuccess ? completion(.success(recipes)) : completion(.failure(.responseError))
    }
    
    func sendAddRecipeRequest(request: URLRequest, completion: @escaping ((Result<String, NetworkError>) -> Void)) {
        isAddRecipeSuccess ? completion(.success("new recipe id")) : completion(.failure(.responseError))
    }
    
    func sendEditRecipeRequest(request: URLRequest, completion: @escaping ((Result<String, NetworkError>) -> Void)) {
        isEditRecipeSuccess ? completion(.success("1234")) : completion(.failure(.responseError))
    }
    
    func sendDeleteRecipeRequest(request: URLRequest, completion: @escaping ((Result<String?, NetworkError>) -> Void)) {
        isDeleteRecipeSuccess ? completion(.success(nil)) : completion(.failure(.responseError))
    }
    
    func sendDownloadImageRequest(url: URL, completion: @escaping ((Result<ImageRequestResponse, NetworkError>) -> Void)) {
        // do nothing
    }
}

class HTTPClientTests: XCTestCase {
    var mockRequestService: MockRequestService!
    var client: HTTPClient!
    let testRecipe = Recipe(id: "1234", name: "TestRecipe", imageURL: "None", steps: "", ingredients: "Boil the egg")
    let testParams = AuthenticationParameters(email: "email", password: "password")
    
    override func setUp() {
        mockRequestService = MockRequestService()
    }

    override func tearDownWithError() throws {
        mockRequestService = nil
        client = nil
    }

    func testLoadRecipesSuccess() {
        mockRequestService.recipes = [testRecipe]
        client = HTTPClient(requestService: mockRequestService)
        let exp = expectation(description: "loadRecipes completion")
        
        client.getAllRecipes(completion: {result in
            exp.fulfill()
            switch result {
            case .success(let result):
                XCTAssertEqual(result.count, 1)
                XCTAssertEqual(result[0].id, self.testRecipe.id)
                XCTAssertEqual(result[0].name, self.testRecipe.name)
            case .failure:
                XCTFail()
            }
        })
        wait(for: [exp], timeout: 0.01)
    }

    func testLoadRecipesFailure() {
        mockRequestService.isGetRecipesSuccess = false
        mockRequestService.recipes = [testRecipe]
        client = HTTPClient(requestService: mockRequestService)
        let exp = expectation(description: "loadRecipes completion")
        
        client.getAllRecipes(completion: {result in
            exp.fulfill()
            switch result {
            case .success:
                XCTFail()
            case .failure:
                XCTAssertEqual(1, 1)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testLoginSuccess() {
        client = HTTPClient(requestService: mockRequestService)
        let exp = expectation(description: "login completion")
        client.login(parameters: testParams, completion: {result in
            exp.fulfill()
            switch result {
            case .success(let result):
                XCTAssertEqual(result, "token")
            case .failure:
                XCTFail()
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testLoginFailure() {
        mockRequestService.isLoginSuccess = false
        client = HTTPClient(requestService: mockRequestService)
        let exp = expectation(description: "login completion")
        client.login(parameters: testParams, completion: {result in
            exp.fulfill()
            switch result {
            case .success:
                XCTFail()
            case .failure:
                XCTAssertEqual(1, 1)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testRegisterSuccess() {
        client = HTTPClient(requestService: mockRequestService)
        let exp = expectation(description: "register completion")
        client.register(parameters: testParams, completion: {result in
            exp.fulfill()
            switch result {
            case .success(let result):
                XCTAssertEqual(result, "id")
            case .failure:
                XCTFail()
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testRegisterFailure() {
        mockRequestService.isRegisterSuccess = false
        client = HTTPClient(requestService: mockRequestService)
        let exp = expectation(description: "register completion")
        client.register(parameters: testParams, completion: {result in
            exp.fulfill()
            switch result {
            case .success:
                XCTFail()
            case .failure:
                XCTAssertEqual(1, 1)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testAddRecipeSuccess() {
        mockRequestService.recipes = []
        client = HTTPClient(requestService: mockRequestService)
        let exp = expectation(description: "addRecipe completion")
        let recipeParams = RecipeParameters(name: "name", imageURL: "none", ingredients: "", steps: "")
        client.addRecipe(parameters: recipeParams, completion: {result in
            exp.fulfill()
            switch result {
            case .success(let result):
                XCTAssertEqual(result, "new recipe id")
            case .failure:
                XCTFail()
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testAddRecipeFailure() {
        mockRequestService.isAddRecipeSuccess = false
        client = HTTPClient(requestService: mockRequestService)
        let exp = expectation(description: "addRecipe completion")
        let recipeParams = RecipeParameters(name: "name", imageURL: "none", ingredients: "", steps: "")
        client.addRecipe(parameters: recipeParams, completion: {result in
            exp.fulfill()
            switch result {
            case .success:
                XCTFail()
            case .failure:
                XCTAssertEqual(1, 1)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testEditRecipeSuccess() {
        mockRequestService.recipes = []
        client = HTTPClient(requestService: mockRequestService)
        let exp = expectation(description: "editRecipe completion")
        let recipeParams = RecipeParameters(name: "name", imageURL: "none", ingredients: "", steps: "")
        client.editRecipe(parameters: recipeParams, recipeID: "1234", completion: {result in
            exp.fulfill()
            switch result {
            case .success(let result):
                XCTAssertEqual(result, "1234")
            case .failure:
                XCTFail()
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testEditRecipeFailure() {
        mockRequestService.isEditRecipeSuccess = false
        client = HTTPClient(requestService: mockRequestService)
        let exp = expectation(description: "editRecipe completion")
        let recipeParams = RecipeParameters(name: "name", imageURL: "none", ingredients: "", steps: "")
        client.editRecipe(parameters: recipeParams, recipeID: "1234", completion: {result in
            exp.fulfill()
            switch result {
            case .success:
                XCTFail()
            case .failure:
                XCTAssertEqual(1, 1)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testDeleteRecipeSuccess() {
        mockRequestService.recipes = [testRecipe]
        client = HTTPClient(requestService: mockRequestService)
        let exp = expectation(description: "editRecipe completion")
        client.deleteRecipe(recipeID: testRecipe.id, completion: {result in
            exp.fulfill()
            switch result {
            case .success:
                XCTAssertEqual(1, 1)
            case .failure:
                XCTFail()
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testDeleteRecipeFailure() {
        mockRequestService.recipes = [testRecipe]
        mockRequestService.isDeleteRecipeSuccess = false
        client = HTTPClient(requestService: mockRequestService)
        let exp = expectation(description: "editRecipe completion")
        client.deleteRecipe(recipeID: testRecipe.id, completion: {result in
            exp.fulfill()
            switch result {
            case .success:
                XCTFail()
            case .failure:
                XCTAssertEqual(1, 1)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
}
