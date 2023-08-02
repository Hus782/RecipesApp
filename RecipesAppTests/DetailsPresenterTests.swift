//
//  DetailsPresenterTests.swift
//  RecipesAppTests
//
//  Created by Hyusein Hyusein on 28.10.21.
//

import XCTest
@testable import RecipesApp

class MockRecipeManager: RecipesManagerProtocol {
    var recipes: [Recipe] = []
    func getCoreDataStore() -> CoreDataStoreProtocol {
        //
        return CoreDataStore()
    }
    
    
    var isDeleteSuccess = true
    var isLoadRecipesSuccess = true
    var exp: XCTestExpectation?
    var loadRecipesCalls = 0
    var saveRecipesInDBCalls = 0
    var viewIsReadyCalls = 0

    func loadRecipesFromDB() {
        // do nothing
    }
    
    func saveRecipesInDB() {
        saveRecipesInDBCalls += 1
    }
    
    func loadRecipes(completion: @escaping ((Result<[Recipe], NetworkError>) -> Void)) {
        if isLoadRecipesSuccess {
            completion(.success(recipes))
        }
        else {
            completion(.failure(.responseError))
        }
    }
    
    func editRecipe(params: RecipeParameters, id: String, completion: @escaping ((Result<Any?, NetworkError>) -> Void)) {
        // do nothing
    }
    
    func addRecipe(params: RecipeParameters, completion: @escaping ((Result<Any?, NetworkError>) -> Void)) {
        // do nothing
    }
    
    func deleteRecipe(id: String, completion: @escaping ((Result<Any?, NetworkError>) -> Void)) {
        if isDeleteSuccess {
            completion(.success(nil))
            exp?.fulfill()
        }
        else {
            completion(.failure(.responseError))
            exp?.fulfill()
        }
    }
}


class MockRecipeDetailsView: RecipeDetailsViewControllerProtocol {
    var recipe: RecipeDetailsViewModel?
    var loadingIndicatorCalls = 0
    var popBackCalls = 0
    var setDataCalls = 0
    var setImageCalls = 0
    var showAlertForDeleteFailureCalls = 0
    var exp: XCTestExpectation?

    var segmentedControllText = ""
    func showConfirmationAlert() {
        //
    }
    
    func showAlertForDeleteFailure() {
        showAlertForDeleteFailureCalls += 1
        exp?.fulfill()
    }
    
    func showLoadingIndicator() {
        loadingIndicatorCalls += 1
    }
    
    func hideLoadingIndicator() {
        //
    }
    
    func popBackToList() {
        popBackCalls += 1
        exp?.fulfill()
    }
    
    func setSegmentControllerText(text: String) {
        segmentedControllText = text
    }
    
    func setRecipeParams(recipe: RecipeDetailsViewModel) {
        setDataCalls += 1
    }
    
    func setRecipeImage(image: UIImage) {
        setImageCalls += 1
        exp?.fulfill()
    }
}

class DetailsPresenterTests: XCTestCase {
    var presenter: DetailsPresenter!
    let recipe = Recipe(id: "1234", name: "TestRecipe", imageURL: "None", steps: "steps", ingredients: "ingredients")
    var mockRecipeManager: MockRecipeManager!
    var view: MockRecipeDetailsView!
    
    override func setUp() {
        mockRecipeManager = MockRecipeManager()
    }

    override func tearDown() {
        mockRecipeManager = nil
    }

    func testDeleteRecipeSuccess() {
        let exp = expectation(description: "deleteRecipe exp")
        presenter = DetailsPresenter(recipe: recipe, recipesManager: mockRecipeManager)
        view = MockRecipeDetailsView()
        view.exp = exp
        presenter.view = view
        presenter.deleteRecipe()
        waitForExpectations(timeout: 0.1, handler: nil)

        XCTAssertEqual(view.loadingIndicatorCalls, 1)
        XCTAssertEqual(view.popBackCalls, 1)
    }
    
//    func testDeleteRecipeFailure() {
//        let exp = expectation(description: "deleteRecipe exp")
//        mockRecipeManager.isDeleteSuccess = false
//        mockRecipeManager.exp = exp
//        presenter = DetailsPresenter(recipe: recipe, recipesManager: mockRecipeManager)
//        view = MockRecipeDetailsView()
//        view.exp = exp
//
//        presenter.view = view
//        presenter.deleteRecipe()
//        waitForExpectations(timeout: 0.1, handler: nil)
//
//        XCTAssertEqual(view.loadingIndicatorCalls, 1)
//        XCTAssertEqual(view.showAlertForDeleteFailureCalls, 1)
//    }
    
    func testSwitchSegment() {
        presenter = DetailsPresenter(recipe: recipe, recipesManager: mockRecipeManager)
        view = MockRecipeDetailsView()
        presenter.view = view
        presenter.switchSegmentControll(index: 0)
        XCTAssertEqual(view.segmentedControllText, recipe.ingredients)
        
        presenter.switchSegmentControll(index: 1)
        XCTAssertEqual(view.segmentedControllText, recipe.steps)
    }
    
    func testViewIsReady() {
        let exp = expectation(description: "getImage exp")
        presenter = DetailsPresenter(recipe: recipe, recipesManager: mockRecipeManager)
        view = MockRecipeDetailsView()
        view.exp = exp

        presenter.view = view
        presenter.viewIsReady()
        waitForExpectations(timeout: 0.1, handler: nil)

        XCTAssertEqual(view.setDataCalls, 1)
        XCTAssertEqual(view.setImageCalls, 1)
    }
    
}
