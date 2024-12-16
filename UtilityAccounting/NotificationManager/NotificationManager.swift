//
//  NotificationManager.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 14.12.24.
//

import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    self.showSettingsAlert()
                    completion(false)
                }
            case .authorized, .provisional:
                DispatchQueue.main.async {
                    completion(true)
                }
            case .ephemeral:
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }
    
    // MARK: - Show Settings Alert
    private func showSettingsAlert() {
        let alert = UIAlertController(
            title: "Enable Notifications",
            message: "Please enable notifications in Settings to receive alerts.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        })
        
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func scheduleNotification(for reminder: ReminderModel) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Reminder for your service: \(ServiceType.allCases[reminder.service ?? 0].rawValue)"
        content.sound = .default

        guard let date = reminder.date, let time = reminder.time else { return }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        var triggerDate = DateComponents()
        triggerDate.year = components.year
        triggerDate.month = components.month
        triggerDate.day = components.day
        triggerDate.hour = calendar.component(.hour, from: time)
        triggerDate.minute = calendar.component(.minute, from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: reminder.periodicity == 1)
        let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for \(reminder.id)")
            }
        }
    }


}
