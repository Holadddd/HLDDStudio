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
    
    let userDefault = UserDefaults()
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait, complete: nil)
        return true
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let moc = StorageManager.sharedManager.persistentContainer.viewContext
        let drumFetchRequest = NSFetchRequest<DrumMachinePatternCoreData>(entityName: "DrumMachinePatternCoreData")
        let result = Result{try moc.fetch(drumFetchRequest)}
        switch result {
        case .success(let data):
            
            StorageManager.sharedManager.fetchedOrderList = data.sorted{ $0.seq < $1.seq }
        case .failure(let error):
            print(error)
        }
        
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
        
        if userDefault.object(forKey: "NeedDefaultPattern") == nil {
            userDefault.setValue(true, forKey: "NeedDefaultPattern")
        }
        
        guard let neededDefault = userDefault.object(forKey: "NeedDefaultPattern") as? Bool else { fatalError() }
        
        
        needDefaultDrumPattern(bool: neededDefault )
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        savePattern()
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

                for (_, element) in kicksURLs.enumerated(){
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
    
    func needDefaultDrumPattern(bool: Bool) {
        
        if bool {
            
            let kickPattern = DrumBeatPattern(true, false, false, false,
                                              true, false, false, false,
                                              true, false, false, false,
                                              true, false, false, false)
            DrumMachineManger.manger.creatPattern(withType: .kicks, drumBeatPattern: kickPattern, fileIndex: 9)
            
            let snarePattern = DrumBeatPattern(false, false, true, false,
                                               false, false, true, false,
                                               false, false, true, false,
                                               false, false, true, false)
            DrumMachineManger.manger.creatPattern(withType: .snares, drumBeatPattern: snarePattern, fileIndex: 56)
            
            let hihatsPattern = DrumBeatPattern(true, false, true, false,
                                                true, false, true, false,
                                                true, false, true, false,
                                                true, false, true, false)
            DrumMachineManger.manger.creatPattern(withType: .hihats, drumBeatPattern: hihatsPattern, fileIndex: 9)
            
            let openHihatsPattern = DrumBeatPattern(false, true, false, true,
                                                false, true, false, true,
                                                false, true, false, true,
                                                false, true, false, true)
            DrumMachineManger.manger.creatPattern(withType: .hihats, drumBeatPattern: openHihatsPattern, fileIndex: 26)
            
           
            
            let hiTomPattern = DrumBeatPattern()
            DrumMachineManger.manger.creatPattern(withType: .percussion, drumBeatPattern: hiTomPattern, fileIndex: 19)
            
            let lowTomPattern = DrumBeatPattern()
            DrumMachineManger.manger.creatPattern(withType: .percussion, drumBeatPattern: lowTomPattern, fileIndex: 23)
            
            let classicPattern = DrumBeatPattern()
            DrumMachineManger.manger.creatPattern(withType: .classic, drumBeatPattern: classicPattern, fileIndex: 4)
            //only connect in firstTime
            MixerManger.manger.mixer.connect(input: DrumMachineManger.manger.drumMixer, bus: 5)
            userDefault.setValue(false, forKey: "NeedDefaultPattern")
        } else {
            for (index, drumPattern) in StorageManager.sharedManager.fetchedOrderList.enumerated() {
                let pattern = DrumBeatPattern(drumPattern.barOneBeatOne, drumPattern.barOneBeatTwo, drumPattern.barOneBeatThree, drumPattern.barOneBeatFour, drumPattern.barTwoBeatOne, drumPattern.barTwoBeatTwo, drumPattern.barTwoBeatThree, drumPattern.barTwoBeatFour, drumPattern.barThreeBeatOne, drumPattern.barThreeBeatTwo, drumPattern.barTwoBeatThree, drumPattern.barThreeBeatFour, drumPattern.barFourBeatOne, drumPattern.barFourBeatTwo, drumPattern.barFourBeatThree, drumPattern.barFourBeatFour)
                guard let drumType = DrumType(rawValue: Int(drumPattern.drumTypeRawValue)) else { fatalError()}
                DrumMachineManger.manger.copyPatternFromCore(withType: drumType, drumBeatPattern: pattern, fileIndex: Int(drumPattern.sampleFileIndex))
                DrumMachineManger.manger.pattern[index].equlizerAndPanner.busBooster.gain = drumPattern.vol
                DrumMachineManger.manger.pattern[index].equlizerAndPanner.busPanner.pan = drumPattern.pan
            }
            MixerManger.manger.mixer.connect(input: DrumMachineManger.manger.drumMixer, bus: 5)
        }
    }
    
    func savePattern() {
        for (inxex, element) in DrumMachineManger.manger.pattern.enumerated() {
            StorageManager.sharedManager.fetchedOrderList[inxex].sampleFileName = element.fileName
            StorageManager.sharedManager.fetchedOrderList[inxex].drumTypeRawValue = Int32(element.drumType.rawValue)
            switch element.drumType {
            case .classic:
                let classicFileNameArr = DrumMachineManger.manger.classicFileArr.map { $0.fileNamePlusExtension }
                guard let fileIndex = classicFileNameArr.firstIndex(of: element.fileName) else { fatalError() }
                StorageManager.sharedManager.fetchedOrderList[inxex].sampleFileIndex = Int32(fileIndex)
            case .hihats:
                let hihatsFileNameArr = DrumMachineManger.manger.hihatsFileArr.map { $0.fileNamePlusExtension }
                guard let fileIndex = hihatsFileNameArr.firstIndex(of: element.fileName) else { fatalError() }
                StorageManager.sharedManager.fetchedOrderList[inxex].sampleFileIndex = Int32(fileIndex)
            case .kicks:
                let kicksFileNameArr = DrumMachineManger.manger.kicksFileArr.map { $0.fileNamePlusExtension }
                guard let fileIndex = kicksFileNameArr.firstIndex(of: element.fileName) else { fatalError() }
                StorageManager.sharedManager.fetchedOrderList[inxex].sampleFileIndex = Int32(fileIndex)
            case .percussion:
                let percussionFileNameArr = DrumMachineManger.manger.percussionFileArr.map { $0.fileNamePlusExtension }
                guard let fileIndex = percussionFileNameArr.firstIndex(of: element.fileName) else { fatalError() }
                StorageManager.sharedManager.fetchedOrderList[inxex].sampleFileIndex = Int32(fileIndex)
            case .snares:
                let snaresFileNameArr = DrumMachineManger.manger.snaresFileArr.map { $0.fileNamePlusExtension }
                guard let fileIndex = snaresFileNameArr.firstIndex(of: element.fileName) else { fatalError() }
                StorageManager.sharedManager.fetchedOrderList[inxex].sampleFileIndex = Int32(fileIndex)
            }

            StorageManager.sharedManager.fetchedOrderList[inxex].drumTypeRawValue = Int32(element.drumType.rawValue)
            StorageManager.sharedManager.fetchedOrderList[inxex].vol = element.equlizerAndPanner.busBooster.gain
            StorageManager.sharedManager.fetchedOrderList[inxex].pan = element.equlizerAndPanner.busPanner.pan
            StorageManager.sharedManager.fetchedOrderList[inxex].barOneBeatOne = element.drumBeatPattern.beatPattern[0]
            StorageManager.sharedManager.fetchedOrderList[inxex].barOneBeatTwo = element.drumBeatPattern.beatPattern[1]
            StorageManager.sharedManager.fetchedOrderList[inxex].barOneBeatThree = element.drumBeatPattern.beatPattern[2]
            StorageManager.sharedManager.fetchedOrderList[inxex].barOneBeatFour = element.drumBeatPattern.beatPattern[3]
            StorageManager.sharedManager.fetchedOrderList[inxex].barTwoBeatOne = element.drumBeatPattern.beatPattern[4]
            StorageManager.sharedManager.fetchedOrderList[inxex].barTwoBeatTwo = element.drumBeatPattern.beatPattern[5]
            StorageManager.sharedManager.fetchedOrderList[inxex].barTwoBeatThree = element.drumBeatPattern.beatPattern[6]
            StorageManager.sharedManager.fetchedOrderList[inxex].barTwoBeatFour = element.drumBeatPattern.beatPattern[7]
            StorageManager.sharedManager.fetchedOrderList[inxex].barThreeBeatOne = element.drumBeatPattern.beatPattern[8]
            StorageManager.sharedManager.fetchedOrderList[inxex].barThreeBeatTwo = element.drumBeatPattern.beatPattern[9]
            StorageManager.sharedManager.fetchedOrderList[inxex].barThreeBeatThree = element.drumBeatPattern.beatPattern[10]
            StorageManager.sharedManager.fetchedOrderList[inxex].barThreeBeatFour = element.drumBeatPattern.beatPattern[11]
            StorageManager.sharedManager.fetchedOrderList[inxex].barFourBeatOne = element.drumBeatPattern.beatPattern[12]
            StorageManager.sharedManager.fetchedOrderList[inxex].barFourBeatTwo = element.drumBeatPattern.beatPattern[13]
            StorageManager.sharedManager.fetchedOrderList[inxex].barFourBeatThree = element.drumBeatPattern.beatPattern[14]
            StorageManager.sharedManager.fetchedOrderList[inxex].barFourBeatFour = element.drumBeatPattern.beatPattern[15]
        }
        StorageManager.sharedManager.saveContext()
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
