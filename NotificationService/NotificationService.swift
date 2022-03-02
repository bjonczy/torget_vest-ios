import UserNotifications

public class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override public func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else { return }
        
        var imageUrl: String?
        if let options = request.content.userInfo["fcm_options"] as? [String: Any], let url = options["image"] as? String {
            imageUrl = url
        }
        
        if let aps = request.content.userInfo["aps"] as? [String: Any], let alert = aps["alert"] as? [String: Any], let title = alert["title"] as? String {
            bestAttemptContent.title = title
        }
        
        if let imageUrl = imageUrl, imageUrl.isEmpty == false {
            if let imageData = getMediaAttachment(for: imageUrl),
               let attachment = saveImageAttachment(imageData: imageData, forIdentifier: "\(bestAttemptContent.title).jpg") {
                bestAttemptContent.attachments = [attachment]
            }
        }
        
        contentHandler(bestAttemptContent)
    }
    
    public override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    private func saveImageAttachment(imageData: NSData, forIdentifier identifier: String) -> UNNotificationAttachment? {
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        let directoryPath = tempDirectory.appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: directoryPath, withIntermediateDirectories: true, attributes: nil)
            let fileURL = directoryPath.appendingPathComponent(identifier)
            try imageData.write(to: fileURL)
            return try UNNotificationAttachment(identifier: identifier, url: fileURL, options: nil)
        } catch {
            return nil
        }
    }
    
    private func getMediaAttachment(for urlString: String) -> NSData? {
        guard let url = URL(string: urlString) else { return nil }
        return NSData(contentsOf: url)
    }
}
