import Foundation
import UserNotifications

final class NotificationsHandler: NativeHandler {
    let namespace = "notifications"

    var onAsyncCallback: ((String, Any?) -> Void)?

    func handle(method: String, args: [String: Any]) -> Any? {
        switch method {
        case "requestPermission":
            let ref = args["_callbackRef"] as? String
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                self.onAsyncCallback?(ref ?? "", [
                    "granted": granted,
                    "error": error?.localizedDescription as Any
                ])
            }
            return ["status": "requesting"]

        case "checkPermission":
            let ref = args["_callbackRef"] as? String
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                let status: String
                switch settings.authorizationStatus {
                case .authorized: status = "granted"
                case .denied: status = "denied"
                case .provisional: status = "provisional"
                case .notDetermined: status = "notDetermined"
                @unknown default: status = "unknown"
                }
                self.onAsyncCallback?(ref ?? "", ["status": status])
            }
            return ["status": "checking"]

        case "schedule":
            return scheduleNotification(args)

        case "cancel":
            let id = args["id"] as? String ?? ""
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            return true

        case "cancelAll":
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            return true

        case "setBadge":
            let count = args["count"] as? Int ?? 0
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = count
            }
            return true

        default:
            return ["error": "Unknown method: \(method)"]
        }
    }

    private func scheduleNotification(_ args: [String: Any]) -> Any? {
        let id = args["id"] as? String ?? UUID().uuidString
        let title = args["title"] as? String ?? ""
        let body = args["body"] as? String ?? ""
        let delay = args["delay"] as? TimeInterval ?? 0

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        if let badge = args["badge"] as? Int {
            content.badge = NSNumber(value: badge)
        }

        let trigger: UNNotificationTrigger?
        if delay > 0 {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        } else {
            trigger = nil
        }

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                dbg.error("Notifications", "Failed to schedule: \(error)")
            }
        }

        return ["id": id]
    }
}
