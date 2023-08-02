//
//  LoginViewController.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 21.10.21.
//

import UIKit

class RegisterViewController: UIViewController {
    private var registerView = RegisterView()
    private let client = HTTPClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        registerView.delegate = self
        view.backgroundColor = .white
    }

    private func registerButtonPressed(params: AuthenticationParameters) {
        showLoadingIndicator()
        client.register(parameters: params, completion: { [weak self] result in
            switch result {
            case .failure:
                DispatchQueue.main.async {
                    self?.dismiss(animated: false, completion: nil)
                    self?.registerView.registerError()
                }
            case .success:
                DispatchQueue.main.async {
                    self?.dismiss(animated: false, completion: nil)
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
    
    private func loginButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
        
    private func showLoadingIndicator() {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
    }
    
    private func setupView() {
        registerView = RegisterView()
        view.addSubview(registerView)
        let safeAreaMargins = view.layoutMarginsGuide

        NSLayoutConstraint.activate([
            registerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            registerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            registerView.topAnchor.constraint(equalTo: safeAreaMargins.topAnchor, constant: 40),
            registerView.bottomAnchor.constraint(equalTo: safeAreaMargins.bottomAnchor)
        ])
    }
}

extension RegisterViewController: RegisterViewProtocol {
    func pressedLogin() {
        loginButtonPressed()
    }
    
    func pressedRegister(params: AuthenticationParameters) {
        registerButtonPressed(params: params)
    }
}
