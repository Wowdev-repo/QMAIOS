//
//  CPLogger.swift
//  QatarMuseums
//
//  Created by Musheer on 3/12/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation
import CocoaLumberjack
import SSZipArchive
import CocoaLumberjack

public var fileLogger: DDFileLogger = DDFileLogger()


// MARK: Bundle application storage directories locations

func applicationStorageDirectory() -> String? {
    return applicationCachesDirectory()
}

func applicationDocumentDirectory() -> String? {
    DDLogInfo("File: \(#file)" + "Function: \(#function)")
    var documentDirectory: String? = nil
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    if paths.count != 0 {
        documentDirectory = paths[0]
    }
    return documentDirectory
}

func applicationCachesDirectory() -> String? {
    DDLogInfo("File: \(#file)" + "Function: \(#function)")
    var cacheDirectory: String? = nil
    let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
    if paths.count != 0 {
        cacheDirectory = paths[0]
    }
    return cacheDirectory
}

//MARK: Logger implementation Initializing logs

func setupQMLogger(){
    DDLogInfo("File: \(#file)" + "Function: \(#function)")
    // Configure CocoaLumberjack
//    DDLog.add(DDASLLogger.sharedInstance)
    DDLog.add(DDTTYLogger.sharedInstance)
    
    // Enable Colors
    let ttyLogger = DDTTYLogger.sharedInstance
    ttyLogger?.colorsEnabled = true
    ttyLogger?.setForegroundColor(UIColor.green, backgroundColor: UIColor.blackColor, for: DDLogFlag(rawValue: 2))
    
    // Initialize File Logger
    var fileLogger: DDFileLogger = DDFileLogger()
    
    // Configure File Logger
    fileLogger.maximumFileSize = (1024 * 1024)
    fileLogger.rollingFrequency = (3600.0 * 24.0)
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7
    
    let defaultLogFileManager = DDLogFileManagerDefault(logsDirectory: URL(fileURLWithPath: applicationDocumentDirectory()!).appendingPathComponent("QMLogs").path)
    fileLogger = DDFileLogger(logFileManager: defaultLogFileManager)

    DDLog.add(fileLogger, with: .info)

//        fileLogger.logFormatter = UCFileLoggerFormatter()
    
    DDLogInfo("Initializing Logger ...")
    
}

func snapshotAndZipLogs(_ includeCrashes: Bool) -> Data? {
    DDLogInfo("File: \(#file)" + "Function: \(#function)")
    let logsPath = URL(fileURLWithPath: applicationDocumentDirectory()!).appendingPathComponent("QMIOSLogs.zip").path
    let file = URL(fileURLWithPath: logsPath).path
    if snapshotLogsAndZipLogs(onDisk: file, includeCrashes: false) {
        return NSData(contentsOfFile: file) as Data?
    }
    return nil
}


func snapshotLogsAndZipLogs(onDisk destination: String?, includeCrashes crashes: Bool) -> Bool {
    DDLogInfo("File: \(#file)" + "Function: \(#function)")
    let removeError: Error? = nil
    var success = false
    let fileManager = FileManager.default
    
    if destination?.hasPrefix(applicationDocumentDirectory()!) ?? false {
        //Delete old if necessary
        if fileManager.fileExists(atPath: destination ?? "") {
            if (try? fileManager.removeItem(atPath: destination ?? "")) == nil || removeError != nil {
                DDLogError("Failed to clear out old ZIP location: %@ [error: %@]")
            }
        }
    }
    
    do {
        var documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        documentsDirectory += "/QMIOSLogs.zip"
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let zipFilePath = documentDirectoryPath!.appending("/QMLogs")
        
        let password = "12"
        
        success = SSZipArchive.createZipFile(atPath: documentsDirectory, withContentsOfDirectory: zipFilePath, keepParentDirectory: false, withPassword: password)
        
        if success {
            DDLogInfo("Success zip")
        } else {
            DDLogInfo("No success zip")
        }
    }

    return success
}

//class UCFileLoggerFormatter: DDLogFileFormatterDefault {
//    func formatLogMessage(logMessage: DDLogMessage?) -> String? {
//        var dateAndTime: String? = nil
//        if let timestamp = logMessage?.timestamp {
//            dateAndTime = DateFormatter.string(timestamp)
//        }
//        if let machThreadID = logMessage?.machThreadID, let logMsg = logMessage?.logMsg {
//            return String(format: "%@ - [%ul] - %@", dateAndTime ?? "", machThreadID, logMsg)
//        }
//        return nil
//    }
//}
