//
//  TimerUtil.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 30.10.21.
//

import Foundation


protocol TimerUtilDelegate: AnyObject {
    func timerStopped()
    func updateUI()
}

class TimerUtil {
    private var timer = BackgroundTimer(timeInterval: 0.01)

    var fractions = 0
    var seconds = 0
    var minutes = 0
    var hours = 0
    weak var delegate: TimerUtilDelegate?
    
    func decrementTimer() -> Bool {
        return handleDecrementTimeFormat()
    }
    
    func startTimer() {
        timer.eventHandler = { self.increment() }
        timer.resume()
    }
    
    @objc func increment() {
        if !decrementTimer(){
            delegate?.timerStopped()
        }
        else {
            delegate?.updateUI()
        }
    }
    
    func handleDecrementTimeFormat() -> Bool {
        if !isValidTime(){
            return false
        }
        fractions -= 1
        
        if fractions <= 0 && seconds > 0 {
            seconds-=1
            fractions=99
        }
        
        if seconds <= 0 && minutes > 0 {
            minutes-=1
            seconds=60
        }
        if minutes <= 0 && hours>0 {
            hours-=1
            minutes=59
        }
        return true

    }
    
    func isValidTime() -> Bool {
        if seconds <= 0 && minutes <= 0 && hours <= 0 {
            return false
        }
        return true
    }
    
    func stopTimer() {
        timer.suspend()
        fractions = 0
        seconds = 0
        minutes = 0
        hours = 0
    }
    
    func getTimerString() -> String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
