//
//  NotificationManager.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 03/09/25.
//

import Foundation
import UserNotifications
import SwiftUI

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var deviceToken: String?
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                } else if granted {
                    print("Notification permission granted")
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    print("Notification permission denied")
                }
            }
        }
    }
    
    func didRegisterForRemoteNotifications(deviceTokenData: Data) {
        let tokenParts = deviceTokenData.map { String(format: "%02x", $0) }
        let token = tokenParts.joined()
        self.deviceToken = token
        print("Device APNs token: \(token)")
    }
    
    func didFailToRegisterForRemoteNotifications(error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func sendNotification(title: String, body: String, inSeconds seconds: TimeInterval = 1) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    func sendNotificationToUser(title: String, body: String, deviceToken: String) {
        // Ini hanya skeleton: untuk notifikasi ke akun spesifik, perlu backend yang memanggil APNs.
        // Bisa panggil API server: POST /sendNotification { "token": deviceToken, "title": title, "body": body }
        print("Send notification to \(deviceToken): \(title) - \(body)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
