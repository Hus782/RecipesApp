//
//  RecipesAppTests.swift
//  RecipesAppTests
//
//  Created by Hyusein Hyusein on 11.10.21.
//

import XCTest
import CoreData
@testable import RecipesApp

class MockCoreDataManager: CoreDataManagerProtocol {
    func getCoreDataStore() -> CoreDataStoreProtocol {
        return CoreDataStore()
    }
    
    func addNewRecipe(newRecipe: Recipe) {
        //
    }
    
    var recipes: [Recipe] = []
    
    // only use this method for mocking
    func loadRecipesFromDB() -> [Recipe] {
        return recipes
    }
    
    func saveAllRecipesInDB(recipes: [Recipe]) {
        // do nothing
    }
    
    func updateRecipe(modifiedRecipe: Recipe) {
        // do nothing
    }
    
    func deleteRecipe(id: String) {
        // do nothing
    }
    
    
}

class MockHTTPClient: HTTPClientProtocol {
    var recipes: [Recipe] = []
    var isGetRecipesSuccess = true
    var isLoginSuccess = true
    var isAddRecipeSuccess = true
    var isEditRecipeSuccess = true
    var isDeleteRecipeSuccess = true
    var isDownloadImageSuccess = true
    let testImage = UIImage(named: "placeholder")!
    let testURL = URL(string: "https://www.seriouseats.com/thmb/JW66xWgB-owXZUSlIiP1n9BoM50=/960x0/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/__opt__aboutcom__coeus__resources__content_migration__serious_eats__seriouseats.com__2019__05__20190520-cheesecake-vicky-wasik-34-16488b3671ae47b5b29eb7124dbaf938.jpg)")!
    
    func getAllRecipes(completion: @escaping ((Result<[Recipe], NetworkError>) -> Void)) {
        isGetRecipesSuccess ? completion(.success(recipes)) : completion(.failure(.responseError))
    }
    
    func login(parameters: AuthenticationParameters, completion: @escaping ((Result<String, NetworkError>) -> Void)) {
        isLoginSuccess ? completion(.success("token")) : completion(.failure(.responseError))
    }
    
    func addRecipe(parameters: RecipeParameters, completion: @escaping ((Result<String, NetworkError>) -> Void)) {
        isAddRecipeSuccess ? completion(.success("1234")) : completion(.failure(.responseError))
    }
    
    func editRecipe(parameters: RecipeParameters, recipeID: String, completion: @escaping ((Result<String, NetworkError>) -> Void)) {
        isEditRecipeSuccess ? completion(.success("1234")) : completion(.failure(.responseError))
    }
    
    func deleteRecipe(recipeID: String, completion: @escaping ((Result<String?, NetworkError>) -> Void)) {
        isDeleteRecipeSuccess ? completion(.success("1234")) : completion(.failure(.responseError))
    }
    
    func downloadImage(url: URL, completion: @escaping ((Result<ImageRequestResponse, NetworkError>) -> Void)) {
        
        if isDownloadImageSuccess {
        let response = ImageRequestResponse(image: testImage, url: testURL, cost: 2)
            completion(.success(response))
        }
        else {
            completion(.failure(.responseError))
        }
    }
}

class RecipesManagerTests: XCTestCase {
    var recipeManager: RecipeManager!
    let recipe = Recipe(id: "1234", name: "TestRecipe", imageURL: "None", steps: "Boil the eggs", ingredients: "eggs")
    var mockClient: MockHTTPClient!
    var mockCoreDataManager: MockCoreDataManager!
    
    override func setUp() {
        mockClient = MockHTTPClient()
        mockCoreDataManager = MockCoreDataManager()
    }
    
    override func tearDown() {
        recipeManager = nil
        mockCoreDataManager = nil
    }
    
    func testLoadRecipesSuccess() {
        mockClient.recipes = [recipe, recipe]
        recipeManager = RecipeManager(client: mockClient, preloadedRecipes: [])
        let exp = expectation(description: "loadRecipes completion")

        recipeManager.loadRecipes(completion: {result in
            exp.fulfill()
            
            switch result {
            case .success(let result):
                XCTAssertEqual(result.count, 2)
                XCTAssertEqual(self.recipeManager.recipes.count, 2)
                XCTAssertEqual(result[0].id, "1234")
                XCTAssertEqual(result[0].name, "TestRecipe")
            case .failure:
                XCTFail()
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testLoadRecipesFailure() {
        mockClient.isGetRecipesSuccess = false
        recipeManager = RecipeManager(client: mockClient, preloadedRecipes: [])
        recipeManager.loadRecipes(completion: {result in })
        XCTAssertEqual(recipeManager.recipes.count, 0)
    }
    
    func testAddRecipeSuccess() {
        let exp = self.expectation(description: "LoadingRecipes")
        recipeManager = RecipeManager(client: mockClient, preloadedRecipes: [])
        let recipeParams = RecipeParameters(name: "name", imageURL: "none", ingredients: "", steps: "")
        recipeManager.addRecipe(params: recipeParams, completion: {result in
            exp.fulfill()
        })
        waitForExpectations(timeout: 0.01, handler: nil)
        XCTAssertEqual(recipeManager.recipes.count, 1)
    }
    
    func testAddRecipeFailure() {
        let exp = self.expectation(description: "LoadingRecipes")
        mockClient.isAddRecipeSuccess = false
        recipeManager = RecipeManager(client: mockClient, preloadedRecipes: [])
        let recipeParams = RecipeParameters(name: "name", imageURL: "none", ingredients: "", steps: "")
        recipeManager.addRecipe(params: recipeParams, completion: {result in
            exp.fulfill()
        })
        waitForExpectations(timeout: 0.01, handler: nil)
        XCTAssertEqual(recipeManager.recipes.count, 0)
    }
    
    func testEditRecipeSuccess() {
        let exp = self.expectation(description: "LoadingRecipes")
        recipeManager = RecipeManager(client: mockClient, preloadedRecipes: [recipe])
        let recipeParams = RecipeParameters(name: "EditedName", imageURL: "none", ingredients: "", steps: "")
        recipeManager.editRecipe(params: recipeParams, id: recipe.id, completion: {result in
            exp.fulfill()
        })
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssertEqual(recipeManager.recipes.count, 1)
        XCTAssertEqual(recipeManager.recipes[0].id, recipe.id)
        XCTAssertEqual(recipeManager.recipes[0].name, recipeParams.name)
        XCTAssertEqual(recipeManager.recipes[0].steps, recipeParams.steps)
        XCTAssertEqual(recipeManager.recipes[0].ingredients, recipeParams.ingredients)
        XCTAssertEqual(recipeManager.recipes[0].imageURL, recipeParams.imageURL)
    }
    
    func testEditRecipeFailure() {
        let exp = self.expectation(description: "LoadingRecipes")
        mockClient.isEditRecipeSuccess = false
        recipeManager = RecipeManager(client: mockClient, preloadedRecipes: [recipe])
        let recipeParams = RecipeParameters(name: "EditedName", imageURL: "none", ingredients: "", steps: "")
        recipeManager.editRecipe(params: recipeParams, id: recipe.id, completion: {result in
            exp.fulfill()
        })
        waitForExpectations(timeout: 0.01, handler: nil)
        XCTAssertEqual(recipeManager.recipes.count, 1)
        XCTAssertEqual(recipeManager.recipes[0].id, recipe.id)
        XCTAssertEqual(recipeManager.recipes[0].name, recipe.name)
        XCTAssertEqual(recipeManager.recipes[0].steps, recipe.steps)
        XCTAssertEqual(recipeManager.recipes[0].ingredients, recipe.ingredients)
        XCTAssertEqual(recipeManager.recipes[0].imageURL, recipe.imageURL)
    }
    
    func testDeleteRecipeSuccess() {
        let exp = self.expectation(description: "LoadingRecipes")
        recipeManager = RecipeManager(client: mockClient, preloadedRecipes: [recipe])
        recipeManager.deleteRecipe(id: recipe.id, completion: {result in
            exp.fulfill()
        })
        waitForExpectations(timeout: 0.01, handler: nil)
        XCTAssertEqual(recipeManager.recipes.count, 0)
    }
    
    func testDeleteRecipeFailure() {
        let exp = self.expectation(description: "LoadingRecipes")
        mockClient.isDeleteRecipeSuccess = false
        recipeManager = RecipeManager(client: mockClient, preloadedRecipes: [recipe])
        recipeManager.deleteRecipe(id: recipe.id, completion: {result in
            exp.fulfill()
        })
        waitForExpectations(timeout: 0.01, handler: nil)
        XCTAssertEqual(recipeManager.recipes.count, 1)
    }
    
    func testLoadRecipesFromDB() {
        mockCoreDataManager.recipes = [recipe]
        recipeManager = RecipeManager(client: mockClient, preloadedRecipes: [], coreDataManager: mockCoreDataManager)
        recipeManager.loadRecipesFromDB()
        XCTAssertEqual(recipeManager.recipes[0].id, recipe.id)
        XCTAssertEqual(recipeManager.recipes[0].name, recipe.name)
        XCTAssertEqual(recipeManager.recipes[0].imageURL, recipe.imageURL)
        XCTAssertEqual(recipeManager.recipes[0].steps, recipe.steps)
        XCTAssertEqual(recipeManager.recipes[0].ingredients, recipe.ingredients)

    }
}
