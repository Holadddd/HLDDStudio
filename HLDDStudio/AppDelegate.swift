//
//  AppDelegate.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/7.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManager
import Firebase
import Fabric
import AudioKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var orientationLock = UIInterfaceOrientationMask.all
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait, complete: nil)
        return true
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().toolbarBarTintColor = .black
        IQKeyboardManager.shared().toolbarTintColor = .white
        //GA
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self]);
        Fabric.sharedSDK().debug = true;
        
        for raw in 0...4{
            guard let drumType = DrumType(rawValue: raw) else { fatalError() }
            sampleGet(drumType: drumType)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "HLDDStudio")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
extension AppDelegate {
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
}

extension AppDelegate {
    
    func sampleGet(drumType: DrumType) {
        if let path = Bundle.main.resourcePath {

            let samplePath = path + "/808_drum_kit/\(drumType)"
            let url = URL(fileURLWithPath: samplePath)
            let fileManager = FileManager.default

            let properties = [URLResourceKey.localizedNameKey,
                              URLResourceKey.creationDateKey, URLResourceKey.localizedTypeDescriptionKey]
            
            var samplePathFileArr: [AKAudioFile] = []
            do {
                let kicksURLs = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: properties, options:FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)

                for (index, element) in kicksURLs.enumerated(){
                    let sampleFileURL = element
                    
                    let result = Result{try AKAudioFile(forReading: sampleFileURL)}
                    switch result {
                    case .success(let file):
                        samplePathFileArr.append(file)
                        
                    case .failure(let error):
                        print(error)
                    }
                    
                }
                
            } catch let error1 as NSError {
                print(error1.description)
            }
            
            switch drumType {
            case .classic:
                DrumMachineManger.manger.classicFileArr = samplePathFileArr.sorted{ $0.fileNamePlusExtension < $1.fileNamePlusExtension }
            case .hihats:
                DrumMachineManger.manger.hihatsFileArr = samplePathFileArr.sorted{ $0.fileNamePlusExtension < $1.fileNamePlusExtension }
            case .kicks:
                DrumMachineManger.manger.kicksFileArr = samplePathFileArr.sorted{ $0.fileNamePlusExtension < $1.fileNamePlusExtension }
            case .percussion:
                DrumMachineManger.manger.percussionFileArr = samplePathFileArr.sorted{ $0.fileNamePlusExtension < $1.fileNamePlusExtension }
            case .snares:
                DrumMachineManger.manger.snaresFileArr = samplePathFileArr.sorted{ $0.fileNamePlusExtension < $1.fileNamePlusExtension }
            }
        }
    }
}
//lock orientation event
struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation, complete:(()-> Void)? ){
        self.lockOrientation(orientation)
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        guard let handle = complete else { return }
        handle()
    }
}
