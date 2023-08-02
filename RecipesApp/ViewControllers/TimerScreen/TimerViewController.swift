//
//  TimerViewCOntroller.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 30.10.21.
//

import Foundation
import UIKit

protocol TimerViewControllerProtocol: AnyObject {
    func updateTimerLabel(text: String)
    func showButtons()
    func hideButtons()
    func setButtonTitle(text: String)
    func setProgressBar(timeInterval: TimeInterval)
}

class TimerViewController: UIViewController, TimerViewControllerProtocol {
    private var circularProgressBarView = CircularProgressBarView()
    let container = UIView()
    var presenter: TimerPresenter?
    var buttonBounceConstraint: NSLayoutConstraint?
    @IBOutlet weak var notificationsButton: UIBarButtonItem!
    
    var timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00:00"
        label.textColor = UIColor.black
        label.isHidden = true
        label.font = UIFont.systemFont(ofSize: 25)
        return label
    }()
    
    lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.systemRed
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.clipsToBounds = true
        button.layer.cornerRadius = 40

        return button
    }()
    
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        setUpPickerView()
        setUpCircularProgressBarView()
        setUpButton()
        startButton.addTarget(self, action: #selector(startButtonClicked), for: .touchUpInside)
        presenter?.viewIsReady()
    }
    
    func updateTimerLabel(text: String) {
        timerLabel.text = text
    }
    func setButtonTitle(text: String) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [], animations: {
            self.buttonBounceConstraint?.constant = 100
            self.startButton.setTitle(text, for: .normal)
            self.view.layoutIfNeeded()
        }, completion: nil)
        UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: [], animations: {
            self.buttonBounceConstraint?.constant = -40
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func setProgressBar(timeInterval: TimeInterval) {
        circularProgressBarView.progressAnimation(duration: timeInterval)
    }
    
    func setUpButton() {
        view.addSubview(startButton)
        buttonBounceConstraint = startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        NSLayoutConstraint.activate([
            startButton.heightAnchor.constraint(equalToConstant: 80),
            startButton.widthAnchor.constraint(equalToConstant: 80),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            startButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20),
        ])
        buttonBounceConstraint?.isActive = true
    }
    
    func setUpPickerView() {
        view.addSubview(pickerView)
        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            pickerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            pickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        ])
    }
    
    func setUpCircularProgressBarView() {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(circularProgressBarView)
        container.addSubview(timerLabel)
        circularProgressBarView.translatesAutoresizingMaskIntoConstraints = false
        container.isHidden = true
        view.addSubview(container)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 220),
            container.widthAnchor.constraint(equalToConstant: 220),
            container.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            circularProgressBarView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            circularProgressBarView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            timerLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])
    }
    
    @IBAction func allowNotifications(_ sender: Any) {
        NotificationManager.shared.requestAuthorization {[weak self] granted in
            if granted {
                self?.notificationsButton.isEnabled = false
            }
            else {
                
            }
        }
    }
    
    @objc func startButtonClicked() {
//        NotificationManager.shared.requestAuthorization {[weak self] granted in
//            if granted {
//                self?.notificationsButton.isEnabled = false
//            }
//            else {
//                
//            }
//        }
        presenter?.buttonClicked()
    }
    
    func showButtons() {
        UIView.transition(with: container, duration: 0.4, options: .transitionFlipFromLeft, animations: {
            self.pickerView.isHidden = true
            self.timerLabel.isHidden = false
            self.container.isHidden = false
        })
    }
    
    func hideButtons() {
        UIView.transition(with: pickerView, duration: 0.4, options: .transitionFlipFromRight, animations: {
            self.pickerView.isHidden = false
            self.timerLabel.isHidden = true
            self.container.isHidden = true
            
        })
    }
}

extension TimerViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 25
        case 1, 2:
            return 60
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width/3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return String(format: "%02d", row)
        case 1:
            return String(format: "%02d", row)
        case 2:
            return String(format: "%02d", row)
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            presenter?.hours = row
        case 1:
            presenter?.minutes = row
        case 2:
            presenter?.seconds = row
        default:
            break;
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
}

