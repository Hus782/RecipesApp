//
//  LoginViewModel.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 27.10.21.
//

import Foundation

protocol LoginPresenterProtocol {
    var email: String { get set }
    var password: String { get set }
    func loginButtonPressed()
}

class LoginPresenter: LoginPresenterProtocol {
    weak var view: LoginViewControllerProtocol?
    weak var delegate: LoginDelegate?
    private let client: HTTPClientProtocol

    init(client: HTTPClientProtocol = HTTPClient()) {
        self.client = client
    }

    var email: String = "" {
        didSet {
            validateInput()
        }
    }
    var password: String = "" {
        didSet {
            validateInput()
        }
    }

    func loginButtonPressed() {
        view?.startLoading()
        let params = AuthenticationParameters(email: email, password: password)
        client.login(parameters: params, completion: { [weak self] result in
            switch result {
            case .failure:
                DispatchQueue.main.async {
                    self?.view?.stopLoading()
                    self?.view?.showLoginError()
                }
            case .success:
                DispatchQueue.main.async {
                    self?.view?.stopLoading()
                    self?.delegate?.logginSuccess()
                }
            }
        })
    }

    private func validateInput() {
        if email != "" && password != "" {
            view?.enableButton()
        } else {
            view?.disableButton()
        }
    }
}

