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

class DrumMachinePattern {
    
    var fileName: String
    
    var file: AKAudioFile!
    
    var filePlayer: AKPlayer!
    
    var drumType: DrumType
    
    var drumBeatPattern: DrumBeatPattern
    
    var equlizerAndPanner: FaderEqualizerAndPanner
    
    var node: AKBooster
    
    init(DrumBeatPattern: DrumBeatPattern, drumType: DrumType, fileName: String) {
        self.drumType = drumType
        self.drumBeatPattern = DrumBeatPattern
        
        self.fileName = fileName
        
        let fileResult = Result{try AKAudioFile(readFileName: fileName)}
        switch fileResult {
        case .success(let file):
            self.file = file
        case .failure(let error):
            print(error)
            print(DrumMachineError.noSuchFile)
        }
        
        self.filePlayer = AKPlayer(audioFile: self.file)
        
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
    
    var pattern: DrumBeatPattern = DrumBeatPattern()
    
}
