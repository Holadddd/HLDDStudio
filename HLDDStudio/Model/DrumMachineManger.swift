//
//  DrumMachineManger.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/21.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import AudioKit

enum DrumMachineStatus {
    
    enum LockOrientation {
        case landscape
        
        case portrait
    }
}

enum DrumType {
    
    case kicks
    
    case snares
    
    case hihats
    
    case percussion
    
    case classic
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
    
    var needDefaultPattern = true
    
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
    
    func creatPattern(withType: DrumType, fileIndex: Int){
        pattern.append(DrumMachinePattern(DrumBeatPattern: DrumBeatPattern(), drumType: withType, fileIndex: fileIndex))
        let patternCount = pattern.count
        drumMixer.connect(input: pattern[patternCount - 1].node, bus: patternCount - 1)
    }
    
    func changeDrumSample(atRow: Int, withType: DrumType, fileIndex: Int) {
        
        switch withType {
        case .classic:
            pattern[atRow].fileName = DrumMachineManger.manger.classicFileArr[fileIndex].fileNamePlusExtension
            pattern[atRow].filePlayer.load(audioFile: DrumMachineManger.manger.classicFileArr[fileIndex])
        case .hihats:
            pattern[atRow].fileName = DrumMachineManger.manger.hihatsFileArr[fileIndex].fileNamePlusExtension
            pattern[atRow].filePlayer.load(audioFile: DrumMachineManger.manger.hihatsFileArr[fileIndex])
        case .kicks:
            pattern[atRow].fileName = DrumMachineManger.manger.kicksFileArr[fileIndex].fileNamePlusExtension
            pattern[atRow].filePlayer.load(audioFile: DrumMachineManger.manger.kicksFileArr[fileIndex])
        case .percussion:
            pattern[atRow].fileName = DrumMachineManger.manger.snaresFileArr[fileIndex].fileNamePlusExtension
            pattern[atRow].filePlayer.load(audioFile: DrumMachineManger.manger.percussionFileArr[fileIndex])
        case .snares:
            pattern[atRow].fileName = DrumMachineManger.manger.snaresFileArr[fileIndex].fileNamePlusExtension
            pattern[atRow].filePlayer.load(audioFile: DrumMachineManger.manger.snaresFileArr[fileIndex])
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
    
}

