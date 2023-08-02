//
//  LoginViewController.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 21.10.21.
//

import UIKit

protocol LoginViewControllerProtocol: AnyObject {
    func startLoading()
    func stopLoading()
    func showLoginError()
    func enableButton()
    func disableButton()
}

class LoginViewController: UIViewController, LoginViewControllerProtocol {
    var presenter: LoginPresenterProtocol?
    
    var email: String = "" {
        didSet {
            presenter?.email = email
        }
    }
    
    var password: String = "" {
        didSet {
            presenter?.password = password
        }
    }
    
    func startLoading() {
        showLoadingIndicator()
    }
    
    func stopLoading() {
        dismiss(animated: false, completion: nil)
    }
    
    func enableButton() {
        loginView.loginButton.isEnabled = true
    }
    
    func disableButton() {
        loginView.loginButton.isEnabled = false
    }
    
    func showLoginError() {
        loginView.loginError()
    }
    
    private var loginView = LoginView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loginView.delegate = self
        view.backgroundColor = .white
    }
    
    private func loginButtonPressed(params: AuthenticationParameters) {
        presenter?.loginButtonPressed()
    }
    
    private func registerButtonPressed() {
        switchToRegister()
    }
    
    private func switchToRegister() {
        let registerController = RegisterViewController()
        registerController.modalPresentationStyle = .fullScreen
        self.present(registerController, animated: true)
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
        view.addSubview(loginView)
        let safeAreaMargins = view.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            loginView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            loginView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            loginView.topAnchor.constraint(equalTo: safeAreaMargins.topAnchor, constant: 40),
            loginView.bottomAnchor.constraint(equalTo: safeAreaMargins.bottomAnchor)
        ])
    }
}

extension LoginViewController: LoginViewProtocol {
    func pressedLogin(params: AuthenticationParameters) {
        loginButtonPressed(params: params)
    }
    
    func pressedRegister() {
        switchToRegister()
    }
}

extension UITextField {
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: self.center.x - 4.0, y: self.center.y)
        animation.toValue = CGPoint(x: self.center.x + 4.0, y: self.center.y)
        layer.add(animation, forKey: "position")
    }
}

protocol LoginDelegate : AnyObject{
    func logginSuccess()
}
