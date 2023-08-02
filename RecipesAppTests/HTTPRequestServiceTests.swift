//
//  HTTPClientTests.swift
//  RecipesAppTests
//
//  Created by Hyusein Hyusein on 18.10.21.
//

import XCTest
@testable import RecipesApp

class MockURLSession: URLSessionProtocol {
    var result: (Data?, URLResponse?, Error?)! = nil
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        completionHandler(result.0, result.1, result.2)
        return MockURLSessionDataTask(resume: {})
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        completionHandler(result.0, result.1, result.2)
        return MockURLSessionDataTask(resume: {})
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    init(resume: () -> Void) {}
    
    override func resume() {
        // Do nothing
    }
}

class HTTPRequestServiceTests: XCTestCase {
    var mockSession: MockURLSession!
    let dummyRequest = URLRequest(url: URL(string: "www.google.com")!)

    let recipe = Recipe(id: "1234", name: "TestRecipe", imageURL: "None", steps: "", ingredients: "Boil the egg")
    let successResponse = HTTPURLResponse(url: URL(string: "www.google.com")!,
                                   statusCode: 200,
                                   httpVersion: nil,
                                   headerFields: nil)
    let badResponse = HTTPURLResponse(url: URL(string: "www.google.com")!,
                                   statusCode: 404,
                                   httpVersion: nil,
                                   headerFields: nil)
    override func setUp() {
        mockSession = MockURLSession()
    }
    
    func testGetAllRecipesSuccess() throws {
        let recipes = [recipe]
        let data = try JSONEncoder().encode(["recipes": recipes])

        mockSession.result = (data, successResponse, nil)
        let requestService = HTTPRequestService(session: mockSession)
        let exp = expectation(description: "loadRecipes completion")
        requestService.sendGetAllRecipesRequest(request: dummyRequest, completion: {
            result in
            exp.fulfill()
            switch result {
            case .success(let result):
                XCTAssertEqual(result.count, 1)
                XCTAssertEqual(result[0].id, "1234")
                XCTAssertEqual(result[0].name, "TestRecipe")
            case .failure:
                XCTFail()
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testGetAllRecipesDecodingFailure() throws {
        mockSession.result = (nil, successResponse, nil)
        let requestService = HTTPRequestService(session: mockSession)
        let exp = expectation(description: "loadRecipes completion")
        requestService.sendGetAllRecipesRequest(request: dummyRequest, completion: {
            result in
            exp.fulfill()
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .decodingError)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testGetAllRecipesResponseFailure() throws {
        mockSession.result = (nil, badResponse, nil)
        
        let requestService = HTTPRequestService(session: mockSession)
        let exp = expectation(description: "loadRecipes completion")
        requestService.sendGetAllRecipesRequest(request: dummyRequest, completion: {
            result in
            exp.fulfill()
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .responseError)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    
    func testAddRecipeSuccess() throws {
        let data = try JSONEncoder().encode(["id": "12345"])
        mockSession.result = (data, successResponse, nil)
        
        let requestService = HTTPRequestService(session: mockSession)
        let exp = expectation(description: "addRecipe completion")
        requestService.sendAddRecipeRequest(request: dummyRequest, completion: {
            result in
            exp.fulfill()
            switch result {
            case .success(let result):
                // returned correct id of new added recipe
                XCTAssertEqual(result, "12345")
            case .failure:
                XCTFail()
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testAddRecipeDecodingFailure() throws {
        mockSession.result = (nil, successResponse, nil)
        
        let requestService = HTTPRequestService(session: mockSession)
        let exp = expectation(description: "addRecipe completion")
        requestService.sendAddRecipeRequest(request: dummyRequest, completion: {
            result in
            exp.fulfill()
            switch result {
            case .success(_):
                XCTFail()
                
            case .failure(let error):
                XCTAssertEqual(error, .decodingError)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testAddRecipeResponseFailure() throws {
        mockSession.result = (nil, badResponse, nil)
        
        let requestService = HTTPRequestService(session: mockSession)
        let exp = expectation(description: "addRecipe completion")
        requestService.sendAddRecipeRequest(request: dummyRequest, completion: {
            result in
            exp.fulfill()
            
            switch result {
            case .success(_):
                XCTFail()
                
            case .failure(let error):
                XCTAssertEqual(error, .responseError)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testEditRecipeSuccess() throws {
        let data = try JSONEncoder().encode(["id": "1234"])
        mockSession.result = (data, successResponse, nil)
        
        let requestService = HTTPRequestService(session: mockSession)
        let exp = expectation(description: "editRecipe completion")
        requestService.sendEditRecipeRequest(request: dummyRequest, completion: {
            result in
            exp.fulfill()
            switch result {
            case .success(let result):
                // returned correct id of edited recipe
                XCTAssertEqual(result, "1234")
            case .failure:
                XCTFail()
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testEditRecipeDecodeFailure() throws {
        mockSession.result = (nil, successResponse, nil)
        
        let requestService = HTTPRequestService(session: mockSession)
        let exp = expectation(description: "editRecipe completion")
        requestService.sendAddRecipeRequest(request: dummyRequest, completion: {
            result in
            exp.fulfill()
            
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .decodingError)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testEditRecipeResponseFailure() throws {
        mockSession.result = (nil, badResponse, nil)
        
        let requestService = HTTPRequestService(session: mockSession)
        let exp = expectation(description: "editRecipe completion")
        requestService.sendAddRecipeRequest(request: dummyRequest, completion: {
            result in
            exp.fulfill()
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .responseError)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testDeleteRecipeSuccess() throws {
        let data = Data()
        mockSession.result = (data, successResponse, nil)
        
        let requestService = HTTPRequestService(session: mockSession)
        let exp = expectation(description: "deleteRecipe completion")
        requestService.sendDeleteRecipeRequest(request: dummyRequest, completion: {
            result in
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
    
    func testDeleteRecipeResponseFailure() throws {
        let data = Data()
        mockSession.result = (data, badResponse, nil)
        
        let requestService = HTTPRequestService(session: mockSession)
        let exp = expectation(description: "deleteRecipe completion")
        requestService.sendDeleteRecipeRequest(request: dummyRequest, completion: {
            result in
            exp.fulfill()
            
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .responseError)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testLoginSuccess() throws {
        let token = "test token 111"
        let data = try JSONEncoder().encode(["authToken": token])
        mockSession.result = (data, successResponse, nil)
        
        let requestService = HTTPRequestService(session: mockSession)
        let exp = expectation(description: "login completion")
        requestService.sendLoginRequest(request: dummyRequest, completion: {
            result in
            exp.fulfill()
            switch result {
            case .success(let result):
                // returned correct authToken
                XCTAssertEqual(result, token)
            case .failure:
                XCTFail()
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testLoginFailure() throws {
        let token = "test token 111"
        let data = try JSONEncoder().encode(["authToken": token])
        mockSession.result = (data, badResponse, nil)
        
        let requestService = HTTPRequestService(session: mockSession)
        let exp = expectation(description: "login completion")
        requestService.sendLoginRequest(request: dummyRequest, completion: {
            result in
            exp.fulfill()
            switch result {
            case .success:
                XCTFail()
            case .failure (let error):
                print(error)
                XCTAssertEqual(error, .responseError)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testRegisterSuccess() throws {
        let id = "some random id"
        let data = try JSONEncoder().encode(["id": id])
        mockSession.result = (data, successResponse, nil)
        
        let requestService = HTTPRequestService(session: mockSession)
        let exp = expectation(description: "register completion")
        requestService.sendRegisterRequest(request: dummyRequest, completion: {
            result in
            exp.fulfill()
            switch result {
            case .success(let result):
                // returned correct id
                XCTAssertEqual(result, id)
            case .failure:
                XCTFail()
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testRegisterFailure() throws {
        let id = "some random id"
        let data = try JSONEncoder().encode(["id": id])
        mockSession.result = (data, badResponse, nil)
        
        let requestService = HTTPRequestService(session: mockSession)
        let exp = expectation(description: "register completion")
        requestService.sendRegisterRequest(request: dummyRequest, completion: {
            result in
            exp.fulfill()

            switch result {
            case .success:
                XCTFail()
            case .failure (let error):
                XCTAssertEqual(error, .responseError)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
}
