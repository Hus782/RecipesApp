//
//  LoginPresenterTests.swift
//  RecipesAppTests
//
//  Created by Hyusein Hyusein on 10.11.21.
//

import XCTest
@testable import RecipesApp

class MockLoginView: LoginViewControllerProtocol {
    var startLoadingCalls = 0
    var stopLoadingCalls = 0
    var showLoginErrorCalls = 0
    var enableButtonCalls = 0
    var disableButtonCalls = 0
    var exp: XCTestExpectation?
    var stopLoadingExp: XCTestExpectation?
    
    func startLoading() {
        startLoadingCalls += 1
    }
    
    func stopLoading() {
        stopLoadingCalls += 1
        stopLoadingExp?.fulfill()
    }
    
    func showLoginError() {
        showLoginErrorCalls += 1
        exp?.fulfill()
    }
    
    func enableButton() {
        enableButtonCalls += 1
    }
    
    func disableButton() {
        disableButtonCalls += 1
    }
}

class LoginPresenterTests: XCTestCase {
    var presenter: LoginPresenter!
    var mockHTTPClient: MockHTTPClient!
    var view: MockLoginView!
    
    override func setUpWithError() throws {
        mockHTTPClient = MockHTTPClient()
        view = MockLoginView()
    }

    override func tearDownWithError() throws {
        mockHTTPClient = nil
        view = nil
    }

    func testLoginSuccess() throws {
        let exp = expectation(description: "loginButtonPressed exp")
        mockHTTPClient.isLoginSuccess = true
        presenter = LoginPresenter(client: mockHTTPClient)
        view.stopLoadingExp = exp
        presenter.view = view
        presenter.loginButtonPressed()
        
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssertEqual(view.stopLoadingCalls, 1)
    }
    
    func testLoginFailure() throws {
        let exp = expectation(description: "loginButtonPressed exp")
        mockHTTPClient.isLoginSuccess = false
        presenter = LoginPresenter(client: mockHTTPClient)
        view.exp = exp
        presenter.view = view
        presenter.loginButtonPressed()
        
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssertEqual(view.showLoginErrorCalls, 1)
    }
    
    func testValidInput() throws {
        presenter = LoginPresenter(client: mockHTTPClient)
        presenter.view = view
        // set email only, button stays disabled
        presenter.email = "email@gmail.com"
        XCTAssertEqual(view.disableButtonCalls, 1)
        // sent password as well, button is enabled
        presenter.password = "password"
        XCTAssertEqual(view.enableButtonCalls, 1)
    }
}
