//
//  RecipesPresenterTests.swift
//  RecipesAppTests
//
//  Created by Hyusein Hyusein on 28.10.21.
//

import XCTest
@testable import RecipesApp

class MockRecipesViewController: MainViewControllerProtocol {
    var setupCollectionViewCalls = 0
    var switchToLoginCalls = 0
    var switchToListViewCalls = 0
    var switchToGridViewCalls = 0
    var stopRefreshingCalls = 0
    var showTryAgainViewControllerCalls = 0
    var stopRefreshingExp: XCTestExpectation?
    var generalExp: XCTestExpectation?

    func startRefreshing() {
        //
    }
    
    func stopRefreshing() {
        stopRefreshingCalls += 1
        stopRefreshingExp?.fulfill()
    }
    
    func switchToLogin() {
        switchToLoginCalls += 1
        generalExp?.fulfill()
    }
    
    func showTryAgainViewController() {
        showTryAgainViewControllerCalls += 1
        generalExp?.fulfill()
    }
    
    func setDataError() {
        //
    }
    
    func reloadData() {
        setupCollectionViewCalls += 1
    }
    
    func switchToListView() {
        switchToListViewCalls += 1
    }
    
    func switchToGridView() {
        switchToGridViewCalls += 1
    }
   
    func applyPendingChanges(pendingChanges: [Change]) {
        //
    }
    
    func dismissLogin() {
        //
    }
}

class RecipesPresenterTests: XCTestCase {
    var presenter: RecipesPresenter!
    let recipe = Recipe(id: "1234", name: "TestRecipe", imageURL: "None", steps: "steps", ingredients: "ingredients")
    var mockRecipeManager: MockRecipeManager!
    var view: MockRecipesViewController!
    
    override func setUpWithError() throws {
        mockRecipeManager = MockRecipeManager()

    }

    override func tearDownWithError() throws {
        mockRecipeManager = nil
        view = nil

    }

    func testLogout() throws {
        presenter = RecipesPresenter(recipesManager: mockRecipeManager)
        view = MockRecipesViewController()
        presenter.view = view
        presenter.logout()
        XCTAssertEqual(view.switchToLoginCalls, 1)
    }
    
    func testSwitchLayout() {
        presenter = RecipesPresenter(recipesManager: mockRecipeManager)
        view = MockRecipesViewController()
        presenter.view = view
        presenter.layoutSwitched(isListView: true)
        XCTAssertEqual(view.switchToListViewCalls, 1)
        presenter.layoutSwitched(isListView: false)
        XCTAssertEqual(view.switchToGridViewCalls, 1)
    }
    
    func testLoadDataSuccess() {
        mockRecipeManager.isLoadRecipesSuccess = true
        let exp = expectation(description: "loadRecipes exp")
        presenter = RecipesPresenter(recipesManager: mockRecipeManager)
        view = MockRecipesViewController()
        view.stopRefreshingExp = exp
        presenter.view = view
        presenter.getRecipesFromAPI()
        waitForExpectations(timeout: 0.1, handler: nil)

        XCTAssertEqual(view.stopRefreshingCalls, 1)
    }
    
    func testLoadDataFailure() {
        mockRecipeManager.isLoadRecipesSuccess = false
        let exp = expectation(description: "loadRecipes exp")
        let exp2 = expectation(description: "loadRecipes exp")
        presenter = RecipesPresenter(recipesManager: mockRecipeManager)
        view = MockRecipesViewController()
        view.stopRefreshingExp = exp
        view.generalExp = exp2
        presenter.view = view
        presenter.getRecipesFromAPI()
        waitForExpectations(timeout: 0.1, handler: nil)
        
        XCTAssertEqual(view.showTryAgainViewControllerCalls, 1)
        XCTAssertEqual(view.stopRefreshingCalls, 1)
    }
}
