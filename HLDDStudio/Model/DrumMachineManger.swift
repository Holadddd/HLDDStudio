//
//  DrumMachineManger.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/21.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import AudioKit
import CoreData

enum DrumMachineStatus {
    
    enum LockOrientation {
        case landscape
        
        case portrait
    }
}

enum DrumType: Int {
    
    case classic = 0
    
    case hihats = 1
    
    case kicks = 2

    case percussion = 3
    
    case snares = 4
    
}

enum DrumMachineError: Error {
    case noSuchFile
    
    case playerError
}

enum DrumMachinePatternBackgroundColor: String {
    
    case firstSec = "AD5151"
    
    case secondSec = "D1893C"
    
    case thirdSec = "D1BF3C"
    
    case fourthSec = "CFC998"
    
}

struct DrumMachinePatternAnimationInfo {
    
    var indexPath: IndexPath
    
    var startTime: AVAudioTime

}

class DrumMachinePattern {
    
    var fileName: String
    
    var filePlayer: AKPlayer!
    
    var drumType: DrumType
    
    var drumBeatPattern: DrumBeatPattern
    
    var equlizerAndPanner: FaderEqualizerAndPanner
    
    var node: AKBooster
    
    init(DrumBeatPattern: DrumBeatPattern, drumType: DrumType, fileIndex: Int) {
        self.drumType = drumType
        self.drumBeatPattern = DrumBeatPattern
        
        switch drumType {
        case .classic:
            self.fileName = DrumMachineManger.manger.classicFileArr[fileIndex].fileNamePlusExtension
            self.filePlayer = AKPlayer(audioFile:DrumMachineManger.manger.classicFileArr[fileIndex])
        case .hihats:
            self.fileName = DrumMachineManger.manger.hihatsFileArr[fileIndex].fileNamePlusExtension
            self.filePlayer = AKPlayer(audioFile:DrumMachineManger.manger.hihatsFileArr[fileIndex])
        case .kicks:
            self.fileName = DrumMachineManger.manger.kicksFileArr[fileIndex].fileNamePlusExtension
            self.filePlayer = AKPlayer(audioFile: DrumMachineManger.manger.kicksFileArr[fileIndex])
        case .percussion:
            self.fileName = DrumMachineManger.manger.percussionFileArr[fileIndex].fileNamePlusExtension
            self.filePlayer = AKPlayer(audioFile:DrumMachineManger.manger.percussionFileArr[fileIndex])
        case .snares:
            self.fileName = DrumMachineManger.manger.snaresFileArr[fileIndex].fileNamePlusExtension
            self.filePlayer = AKPlayer(audioFile:DrumMachineManger.manger.snaresFileArr[fileIndex])
        }
        
        self.equlizerAndPanner = FaderEqualizerAndPanner(node: filePlayer)
        
        self.node = equlizerAndPanner.busBooster
    }
}

class DrumBeatPattern {
    
    var beatPattern: [Bool] = []
    
    init(_ barOneBeatOne: Bool = false, _ barOneBeatTwo: Bool = false, _ barOneBeatThree: Bool = false, _ barOneBeatFour: Bool = false,
         _ barTwoBeatOne: Bool = false, _ barTwoBeatTwo: Bool = false, _ barTwoBeatThree: Bool = false, _ barTwoBeatFour: Bool = false,
         _ barThreeBeatOne: Bool = false, _ barThreeBeatTwo: Bool = false, _ barThreeBeatThree: Bool = false, _ barThreeBeatFour: Bool = false,
         _ barFourBeatOne: Bool = false, _ barFourBeatTwo: Bool = false, _ barFourBeatThree: Bool = false, _ barFourBeatFour: Bool = false) {
        beatPattern.append(barOneBeatOne)
        beatPattern.append(barOneBeatTwo)
        beatPattern.append(barOneBeatThree)
        beatPattern.append(barOneBeatFour)
        beatPattern.append(barTwoBeatOne)
        beatPattern.append(barTwoBeatTwo)
        beatPattern.append(barTwoBeatThree)
        beatPattern.append(barTwoBeatFour)
        beatPattern.append(barThreeBeatOne)
        beatPattern.append(barThreeBeatTwo)
        beatPattern.append(barThreeBeatThree)
        beatPattern.append(barThreeBeatFour)
        beatPattern.append(barFourBeatOne)
        beatPattern.append(barFourBeatTwo)
        beatPattern.append(barFourBeatThree)
        beatPattern.append(barFourBeatFour)
    }
}

class DrumMachineManger {
    
    static let manger = DrumMachineManger()
    
    var drumMixer = AKMixer()
    
    var timer = Timer()
    
    var bpm = 60
    
    var numberOfBeats = 0
    
    var pattern: [DrumMachinePattern] = []
    
    var kicksFileArr: [AKAudioFile] = []
    
    var snaresFileArr: [AKAudioFile] = []
    
    var percussionFileArr: [AKAudioFile] = []
    
    var hihatsFileArr: [AKAudioFile] = []
    
    var classicFileArr: [AKAudioFile] = []
    
    let drumTypeStringArr = ["Classic", "Hihats", "Kicks", "Percussion", "Snares"]
    
    func creatPattern(withType: DrumType, drumBeatPattern: DrumBeatPattern, fileIndex: Int){
        pattern.append(DrumMachinePattern(DrumBeatPattern: drumBeatPattern, drumType: withType, fileIndex: fileIndex))
        let patternIndex = pattern.count - 1
        drumMixer.connect(input: pattern[patternIndex].node, bus: patternIndex)
        creatCoreData(withType: withType, drumBeatPattern: drumBeatPattern, fileIndex: fileIndex)
    }
    
    func changeDrumSample(atRow: Int, withType: DrumType, fileIndex: Int) {
        
        
        switch withType.rawValue {
        case 0:
            pattern[atRow].fileName = DrumMachineManger.manger.classicFileArr[fileIndex].fileNamePlusExtension
            pattern[atRow].filePlayer.load(audioFile: DrumMachineManger.manger.classicFileArr[fileIndex])
        case 1:
            pattern[atRow].fileName = DrumMachineManger.manger.hihatsFileArr[fileIndex].fileNamePlusExtension
            pattern[atRow].filePlayer.load(audioFile: DrumMachineManger.manger.hihatsFileArr[fileIndex])
        case 2:
            pattern[atRow].fileName = DrumMachineManger.manger.kicksFileArr[fileIndex].fileNamePlusExtension
            pattern[atRow].filePlayer.load(audioFile: DrumMachineManger.manger.kicksFileArr[fileIndex])
        case 3:
            pattern[atRow].fileName = DrumMachineManger.manger.snaresFileArr[fileIndex].fileNamePlusExtension
            pattern[atRow].filePlayer.load(audioFile: DrumMachineManger.manger.percussionFileArr[fileIndex])
        case 4:
            pattern[atRow].fileName = DrumMachineManger.manger.snaresFileArr[fileIndex].fileNamePlusExtension
            pattern[atRow].filePlayer.load(audioFile: DrumMachineManger.manger.snaresFileArr[fileIndex])
        default:
            print("")
        }
        
    }
    
    func changeDrumType(atRow: Int, drumType: DrumType) {
        pattern[atRow].drumType = drumType
        switch drumType {
        case .classic:
            changeDrumSample(atRow: atRow, withType: .classic, fileIndex: 21)
        case .hihats:
            changeDrumSample(atRow: atRow, withType: .hihats, fileIndex: 0)
        case .kicks:
            changeDrumSample(atRow: atRow, withType: .kicks, fileIndex: 0)
        case .percussion:
            changeDrumSample(atRow: atRow, withType: .percussion, fileIndex: 19)
        case .snares:
            changeDrumSample(atRow: atRow, withType: .snares, fileIndex: 23)
        }
    }
    
    func removeDrumPattern(atRow: Int) {
        
    }
    
    func playDrumMachine() {
        
        timer = Timer.scheduledTimer(timeInterval: (60 * 4 / 8)/bpm, target: self, selector: #selector(drumMachineSetAndPlay), userInfo: nil, repeats: true)
    }
    
    @objc func drumMachineSetAndPlay() {
        
        let start = AVAudioTime.now() + 0.25
        
        //each pattern
        for (index, drumPatterm) in pattern.enumerated() {
            let beats = numberOfBeats % 16
            
            DispatchQueue.main.async {
                if drumPatterm.drumBeatPattern.beatPattern[beats]{
                    let indexPath = IndexPath(row: index, column: beats)
                    NotificationCenter.default.post(name: .drumMachinePatternAnimation, object: DrumMachinePatternAnimationInfo(indexPath: indexPath, startTime: start))
                    drumPatterm.filePlayer.play(at: start)
                }
            }
        }
        
        numberOfBeats += 1
    }
    
    func mixerPlayDrumMachine() {
        let mixerBpm = MixerManger.manger.metronome.tempo
        timer = Timer.scheduledTimer(timeInterval: (60 * 4 / 8)/mixerBpm, target: self, selector: #selector(drumMachineSetAndPlayAtMixer), userInfo: nil, repeats: true)
    }
    
    @objc func drumMachineSetAndPlayAtMixer() {
        
        let start = AVAudioTime.now() + 0.25
        
        //each pattern
        for (index, drumPatterm) in pattern.enumerated() {
            let beats = numberOfBeats % 16
            
            DispatchQueue.main.async {
                if drumPatterm.drumBeatPattern.beatPattern[beats]{
                    let indexPath = IndexPath(row: index, column: beats)
                    NotificationCenter.default.post(name: .drumMachinePatternAnimation, object: DrumMachinePatternAnimationInfo(indexPath: indexPath, startTime: start))
                    drumPatterm.filePlayer.play(at: start)
                }
            }
        }
        
        numberOfBeats += 1
    }
    
    func stopPlayingDrumMachine() {
        DispatchQueue.main.async {[weak self] in
            guard let strongSelf = self else { fatalError() }
            strongSelf.numberOfBeats = 0
            strongSelf.timer.invalidate()
            for drumPatterm in strongSelf.pattern {
                drumPatterm.filePlayer.stop()
            }
        }
        
    }
    
    func pauseDrumMachine() {
        
        DispatchQueue.main.async {[weak self] in
            guard let strongSelf = self else { fatalError() }
            //strongSelf.numberOfBeats = 0
            strongSelf.timer.invalidate()
            for drumPatterm in strongSelf.pattern {
                drumPatterm.filePlayer.pause()
            }
        }
    }
    
}

extension DrumMachineManger {
    
    func creatCoreData(withType: DrumType, drumBeatPattern: DrumBeatPattern, fileIndex: Int) {
        let patternIndex = pattern.count - 1
        let moc = StorageManager.sharedManager.persistentContainer.viewContext
        let newPattern = DrumMachinePatternCoreData(context: moc)
        newPattern.seq = Int32(patternIndex)
        newPattern.sampleFileName = pattern[patternIndex].fileName
        newPattern.drumTypeRawValue = Int32(withType.rawValue)
        switch withType {
        case .classic:
            let classicFileNameArr = classicFileArr.map { $0.fileNamePlusExtension }
            guard let fileIndex = classicFileNameArr.firstIndex(of: pattern[patternIndex].fileName) else { fatalError() }
            newPattern.sampleFileIndex = Int32(fileIndex)
        case .hihats:
            let hihatsFileNameArr = hihatsFileArr.map { $0.fileNamePlusExtension }
            guard let fileIndex = hihatsFileNameArr.firstIndex(of: pattern[patternIndex].fileName) else { fatalError() }
            newPattern.sampleFileIndex = Int32(fileIndex)
        case .kicks:
            let kicksFileNameArr = kicksFileArr.map { $0.fileNamePlusExtension }
            guard let fileIndex = kicksFileNameArr.firstIndex(of: pattern[patternIndex].fileName) else { fatalError() }
            newPattern.sampleFileIndex = Int32(fileIndex)
        case .percussion:
            let percussionFileNameArr = percussionFileArr.map { $0.fileNamePlusExtension }
            guard let fileIndex = percussionFileNameArr.firstIndex(of: pattern[patternIndex].fileName) else { fatalError() }
            newPattern.sampleFileIndex = Int32(fileIndex)
        case .snares:
            let snaresFileNameArr = snaresFileArr.map { $0.fileNamePlusExtension }
            guard let fileIndex = snaresFileNameArr.firstIndex(of: pattern[patternIndex].fileName) else { fatalError() }
            newPattern.sampleFileIndex = Int32(fileIndex)
        }
        newPattern.drumTypeRawValue = Int32(withType.rawValue)
        newPattern.vol = pattern[patternIndex].equlizerAndPanner.busBooster.gain
        newPattern.pan = pattern[patternIndex].equlizerAndPanner.busPanner.pan
        newPattern.barOneBeatOne = pattern[patternIndex].drumBeatPattern.beatPattern[0]
        newPattern.barOneBeatTwo = pattern[patternIndex].drumBeatPattern.beatPattern[1]
        newPattern.barOneBeatThree = pattern[patternIndex].drumBeatPattern.beatPattern[2]
        newPattern.barOneBeatFour = pattern[patternIndex].drumBeatPattern.beatPattern[3]
        newPattern.barTwoBeatOne = pattern[patternIndex].drumBeatPattern.beatPattern[4]
        newPattern.barTwoBeatTwo = pattern[patternIndex].drumBeatPattern.beatPattern[5]
        newPattern.barTwoBeatThree = pattern[patternIndex].drumBeatPattern.beatPattern[6]
        newPattern.barTwoBeatFour = pattern[patternIndex].drumBeatPattern.beatPattern[7]
        newPattern.barThreeBeatOne = pattern[patternIndex].drumBeatPattern.beatPattern[8]
        newPattern.barThreeBeatTwo = pattern[patternIndex].drumBeatPattern.beatPattern[9]
        newPattern.barThreeBeatThree = pattern[patternIndex].drumBeatPattern.beatPattern[10]
        newPattern.barThreeBeatFour = pattern[patternIndex].drumBeatPattern.beatPattern[11]
        newPattern.barFourBeatOne = pattern[patternIndex].drumBeatPattern.beatPattern[12]
        newPattern.barFourBeatTwo = pattern[patternIndex].drumBeatPattern.beatPattern[13]
        newPattern.barFourBeatThree = pattern[patternIndex].drumBeatPattern.beatPattern[14]
        newPattern.barFourBeatFour = pattern[patternIndex].drumBeatPattern.beatPattern[15]
        StorageManager.sharedManager.fetchedOrderList.append(newPattern)
    }
}
