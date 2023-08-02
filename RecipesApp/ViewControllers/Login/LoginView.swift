//
//  LoginView.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 21.10.21.
//

import UIKit

class LoginView: UIView {
    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Email"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.1)
        textField.autocapitalizationType = .none
        return textField
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Password"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.1)
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        return textField
    }()
    
    lazy var errorLabel: UILabel = {
        let textField = UILabel()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "Wrong email or password"
        textField.textColor = UIColor.red
        textField.isHidden = true
        return textField
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Login"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.bold)
        label.textColor = UIColor.systemRed
        return label
    }()
    
    lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sign in to start cooking!"
        label.numberOfLines = 0
        return label
    }()
    
    lazy var registrationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Don't have an account?"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.setTitleColor(UIColor.systemRed, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        return button
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign up now!", for: .normal)
        button.setTitleColor(UIColor.systemRed, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        return button
    }()
    
    lazy var stackViewTop = UIStackView()
    weak var delegate: LoginViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupStackTop()
        
        loginButton.isEnabled = false
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField == emailTextField {
            delegate?.email = textField.text ?? ""
        } else {
            delegate?.password = textField.text ?? ""
        }
    }
    
    func loginError() {
        errorLabel.isHidden = false
        passwordTextField.shake()
    }
    
    @objc private func loginButtonPressed() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        errorLabel.isHidden = true
        let authenticationParams = AuthenticationParameters(email: email, password: password)
        delegate?.pressedLogin(params: authenticationParams)
    }
    
    @objc private func registerButtonPressed() {
        delegate?.pressedRegister()
    }
    
    private func setupStackTop() {
        let spacer = UIView()
        stackViewTop = UIStackView(arrangedSubviews: [titleLabel, greetingLabel, emailTextField, passwordTextField,errorLabel, loginButton, spacer, registrationLabel, registerButton])
        stackViewTop.translatesAutoresizingMaskIntoConstraints = false
        stackViewTop.spacing = 10
        stackViewTop.distribution = .fillEqually
        stackViewTop.axis = .vertical
        addSubview(stackViewTop)
        
        NSLayoutConstraint.activate([
            stackViewTop.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.0),
            stackViewTop.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.0),
            stackViewTop.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackViewTop.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

protocol LoginViewProtocol: AnyObject {
    func pressedLogin(params: AuthenticationParameters)
    func pressedRegister()

    var email: String { get set }
    var password: String { get set }
}
