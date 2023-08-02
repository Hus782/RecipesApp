//
//  NotificationManager.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 30.10.21.
//

import Foundation
import UserNotifications

enum NotificationManagerConstants {
  static let timeBasedNotificationThreadId =
    "TimeBasedNotificationThreadId"
}

class NotificationManager: ObservableObject {
  static let shared = NotificationManager()
  @Published var settings: UNNotificationSettings?

  func requestAuthorization(completion: @escaping  (Bool) -> Void) {
    UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _  in
        self.fetchNotificationSettings()
        completion(granted)
      }
  }

  func fetchNotificationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      DispatchQueue.main.async {
        self.settings = settings
      }
    }
  }

  func removeScheduledNotification(identifier: String) {
    UNUserNotificationCenter.current()
      .removePendingNotificationRequests(withIdentifiers: [identifier])
  }

    func scheduleNotification(identifier: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Time is up!"
        content.body = "Go check out the oven"
        content.categoryIdentifier = "OrganizerPlusCategory"
        content.userInfo = ["content" : "some content"]
        var trigger: UNNotificationTrigger?
        trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false)
        content.threadIdentifier =
        NotificationManagerConstants.timeBasedNotificationThreadId
        
    if let trigger = trigger {
      let request = UNNotificationRequest(
        identifier: identifier,
        content: content,
        trigger: trigger)

      UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
          print(error)
        }
      }
    }
  }
}
