//
//  TimerPresenter.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 31.10.21.
//

import Foundation

protocol TimerPresenterProtocol: AnyObject {
    func viewIsReady()
    func buttonClicked()
}

class TimerPresenter: TimerPresenterProtocol {
    weak var view: TimerViewControllerProtocol?
    private var timer = TimerUtil()

    var seconds = 0
    var minutes = 0
    var hours = 0
    private var isRunning = false
    private var currNotificationID = ""
    
    func buttonClicked() {
        if hours == 0 && minutes == 0 && seconds == 0 {
            return
        }
        timer.hours = hours
        timer.minutes = minutes
        timer.seconds = seconds + 1
        let timeInterval = TimeInterval(calculateTime())
        if !isRunning {
            startTimer()
            currNotificationID = UUID().uuidString
            NotificationManager.shared.scheduleNotification(identifier: currNotificationID, timeInterval: timeInterval)
            view?.setProgressBar(timeInterval: timeInterval)
        }
        else {
            killTimer()
     
        }
    }
    
    private func startTimer() {
        timer.startTimer()
        isRunning = true
        DispatchQueue.main.async {
            self.view?.setButtonTitle(text: "Stop")
            self.view?.showButtons()
        }
    }
    
    private func killTimer() {
        timer.stopTimer()
        isRunning = false
        DispatchQueue.main.async {
            self.view?.hideButtons()
            self.view?.setButtonTitle(text: "Start")
        }
        NotificationManager.shared.removeScheduledNotification(identifier: currNotificationID)
        currNotificationID = ""
        view?.setProgressBar(timeInterval: 0)
    }
    
    func viewIsReady() {
        timer.delegate = self
    }
    
    private func calculateTime() -> Int {
        var compHours = 1
        var compMinutes = 1
        var compSeconds = 1

        if hours != 0 {
            compHours = hours
        }
        
        if minutes != 0 {
            compMinutes = minutes
        }
        
        if seconds != 0 {
            compSeconds = seconds
        }
        
        return compHours * compMinutes * compSeconds
    }
    
}

extension TimerPresenter: TimerUtilDelegate {
    func timerStopped() {
        killTimer()
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.view?.updateTimerLabel(text: self.timer.getTimerString())
        }
    }
}
