//
//  Notification+extension.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/13.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import AudioKit

extension Notification.Name {
    static let didInsertPlugIn = Notification.Name("didInsertPlugIn")
    static let didUpdatePlugIn = Notification.Name("didUpdatePlugIn")
    static let didRemovePlugIn = Notification.Name("didRemovePlugIn")
    
    static let mixerNotificationTitleChange = Notification.Name("mixerNotificationTitleChange")
    
    static let mixerNotificationSubTitleChange = Notification.Name("mixerNotificationSubTitleChange")
    
    static let mixerBarTitleChange = Notification.Name("mixerBarTitleChange")
}


extension FileManager {
    static var docs: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    static func emtpyDocumentsDirectory() {
        let fileManager = FileManager.default
        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: docs.path)
            for fileName in fileNames {
                try fileManager.removeItem(at: docs.appendingPathComponent(fileName))
            }
        } catch {
            AKLog(error)
        }
    }
}
