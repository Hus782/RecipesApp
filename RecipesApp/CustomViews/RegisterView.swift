//
//  LoginView.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 21.10.21.
//

import UIKit

class RegisterView: UIView {
    var emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Email"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.1)
        textField.autocapitalizationType = .none
        return textField
    }()
    
    var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Password"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.1)
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        return textField
    }()
    
    var passwordTextField2: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Confirm password"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.1)
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        return textField
    }()
    
    var loginLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "You already have an account?"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var emailErrorLabel: UILabel = {
        let textField = UILabel()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "Email is improperly formatted."
        textField.textColor = UIColor.red
        textField.isHidden = true
        return textField
    }()
    
    lazy var passwordErrorLabel: UILabel = {
        let textField = UILabel()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "The password must be a string with at least 6 characters."
        textField.textColor = UIColor.red
        textField.isHidden = true
        return textField
    }()
    
    lazy var passwordsDontMatchError: UILabel = {
        let textField = UILabel()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "Passwords do not match"
        textField.textColor = UIColor.red
        textField.isHidden = true
        return textField
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Register"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.bold)
        label.textColor = UIColor.systemRed
        return label
    }()
    
    var greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sign up to get access to the best recipes!"
        label.numberOfLines = 0
        return label
    }()
    
    var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.systemRed, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        return button
    }()
    
    var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign in now!", for: .normal)
        button.setTitleColor(UIColor.systemRed, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        return button
    }()
    var stackView = UIStackView()
    weak var delegate: RegisterViewProtocol?

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupView()
        registerButton.isEnabled = false

        registerButton.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func checkPasswordsMatch()-> Bool {
        guard let password1 = passwordTextField.text, let password2 = passwordTextField2.text else {
            return false
        }
        if password1 == password2 {
            return true
        }
        else {
            return false
        }
    }
    
    func registerError() {
        emailErrorLabel.isHidden = false
    }
    
    @objc private func loginButtonPressed() {
        delegate?.pressedLogin()
    }
    
    @objc private func registerButtonPressed() {
        passwordsDontMatchError.isHidden = true
        emailErrorLabel.isHidden = true
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        if !checkPasswordsMatch() {
            passwordTextField.shake()
            passwordTextField2.shake()
            passwordsDontMatchError.isHidden = false
            return
        }
        
        let authenticationParams = AuthenticationParameters(email: email, password: password)
        
        delegate?.pressedRegister(params: authenticationParams)
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        guard
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else {
            registerButton.isEnabled = false
            return
        }
        registerButton.isEnabled = true
    }
    
    private func setupView() {
        let spacer = UIView()
        stackView = UIStackView(arrangedSubviews: [titleLabel, greetingLabel,emailTextField, emailErrorLabel, passwordTextField, passwordErrorLabel, passwordTextField2, passwordsDontMatchError, registerButton, spacer, loginLabel, loginButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.0),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

protocol RegisterViewProtocol: AnyObject {
    func pressedLogin()
    func pressedRegister(params: AuthenticationParameters)
}
