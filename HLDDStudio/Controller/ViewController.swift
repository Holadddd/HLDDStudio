//
//  ViewController.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/7.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import G3GridView
import AVKit
import AudioKit


class ViewController: UIViewController {
    
    var plugInArr:[HLDDStudioPlugIn] = [HLDDStudioPlugIn(plugIn: .reverb, byPass: false)]
    
    let mic = AKMicrophone()
    
    var bus1Node: AKNode?
    
    let metronome = AKMetronome()
    
    var filePlayer = AKPlayer()
    
    var allInputSource: [AKNode] = []
    
    let mixer = AKMixer()
    
    @IBOutlet var mixerView: MixerView!
    
    weak var cellTableView: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        mixerView.delegate = self
        mixerView.datasource = self
        
        mixerView.trackGridView.delegate = self
        mixerView.trackGridView.dataSource = self
        //set clean input
        bus1Node = mic
        AudioKit.output = mixer
        try? AudioKit.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        mixerView.inputDeviceTextField.text = AudioKit.inputDevice?.deviceID
    }
    
}

extension ViewController: MixerDelegate {
    
    
    
    func didSelectInputDevice(_ deviceID: DeviceID) {
        
        guard let inputDeviceArr = AudioKit.inputDevices else { fatalError() }
        for device in inputDeviceArr {
            if device.deviceID == deviceID {
                let result = Result{try AudioKit.setInputDevice(device)}
                switch result {
                case .success():
                    print("Set \(device.deviceID) As InputDevice")
                    //??????why
                    try? AudioKit.setInputDevice(device)
                case .failure(let error):
                    print(error)
                }
            }
        }
        
    }
    
    func metronomeSwitch(isOn: Bool) {
        
        switch isOn {
        case true:
            
            try? AudioKit.stop()
            mixer.connect(input: metronome, bus: 0)
            try? AudioKit.start()
            
        case false:
            
            try? AudioKit.stop()
            mixer.disconnectInput(bus: 0)
            try? AudioKit.start()
            
        }
        
    }
    
    func metronomeBPM(bpm: Int) {
        metronome.tempo = Double(bpm)
    }
    
    func stopAudioPlayer() {
        print("StopPlayer")
        metronome.stop()
    }
    
    func playingAudioPlayer() {
        print("playingPlayer")
        metronome.start()
        //for each player play
    }
    
    func resumeAudioPlayer() {
        print("ResumePlayer")
    }
    
    func startRecordAudioPlayer(frombar start: Int, tobar stop: Int) {
        print(start, stop)
    }
    
    func stopRecord() {
        print("stoprecord")
        
    }
    
}

extension ViewController: MixerDatasource {
    
    func currentInputDevice() -> DeviceID {
        
        guard let inputDeviceID = AudioKit.inputDevice?.deviceID else {return "NO INPUT"}
        
        return inputDeviceID
    }
    
    
    func nameOfInputDevice() -> [String] {
        var inputDevieNameArr: [DeviceID] = []
        
        guard let inputDeviceArr = AudioKit.inputDevices else { fatalError() }
        
        for inputDevice in inputDeviceArr {
            inputDevieNameArr.append(inputDevice.deviceID)
        }
        
        return inputDevieNameArr
    }
    
}

extension ViewController: GridViewDelegate {
    
}

extension ViewController: GridViewDataSource {
    func numberOfColumns(in gridView: GridView) -> Int {
        return 1
    }
    
    func gridView(_ gridView: GridView, numberOfRowsInColumn column: Int) -> Int {
        return 3
    }
    
    func gridView(_ gridView: GridView, cellForRowAt indexPath: IndexPath) -> GridViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = mixerView.trackGridView.dequeueReusableCell(withReuseIdentifier: "IOGridViewCell", for: indexPath) as? IOGridViewCell else { fatalError() }
            cell.delegate = self
            cell.datasource = self
            cell.backgroundColor = .red
            return cell
        case 1:
            //need set tableView
            guard let cell = mixerView.trackGridView.dequeueReusableCell(withReuseIdentifier: "PlugInGridViewCell", for: indexPath) as? PlugInGridViewCell else { fatalError() }
            cellTableView = cell.tableView
            cell.tableView.delegate = self
            cell.tableView.dataSource = self
            return cell
        case 2:
            guard let cell = mixerView.trackGridView.dequeueReusableCell(withReuseIdentifier: "FaderGridViewCell", for: indexPath) as? FaderGridViewCell else { fatalError() }
            cell.backgroundColor = .green
            return cell
        default:
            return GridViewCell()
        }
    }
    
    func gridView(_ gridView: GridView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 50
        case 1:
            return (mixerView.bounds.height-50)/2
        case 2:
            return (mixerView.bounds.height-50)/2
        default:
            return 0
        }
    }
    
    func gridView(_ gridView: GridView, widthForColumn column: Int) -> CGFloat {
        return mixerView.bounds.width
    }
    
}

extension ViewController: UITableViewDelegate {
    //將資料傳到 plugIn 的 VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? PlugInViewController else { return }
        controller.plugInArr = plugInArr
        controller.delegate = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PlugInTableViewSegue", sender: nil)
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return plugInArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlugInTableViewCell") as? PlugInTableViewCell else{ fatalError() }
        let plugIn = plugInArr[indexPath.row]
        cell.plugInLabel.text = "\(plugIn.plugIn.self)"
        cell.bypassButton.isSelected = plugIn.byPass
        cell.delegate = self
        return cell
        
    }
    
}

extension ViewController: PlugInViewControllerDelegate {
    //this change is come from pluginVC
    func plugInReverbBypass(indexPathAtPlugInArr indexPath: IndexPath) {
        plugInArr[indexPath.row].byPass = !plugInArr[indexPath.row].byPass
        cellTableView?.reloadData()
    }
    
}

extension ViewController: PlugInTableViewCellDelegate{
    
    func bypassPlugin(_ cell: PlugInTableViewCell) {
        
        guard let indexPath = cellTableView?.indexPath(for: cell) else{ return }
        //set data as bypass
        plugInArr[indexPath.row].byPass = !plugInArr[indexPath.row].byPass

    }
    
}

extension ViewController: IOGridViewCellDelegate {
    
    func didSelectInputSource(inputSource: String) {
        let currentDevice = currentInputDevice()
        let fileInDevice = getFileFromDevice()
        
        if inputSource == currentDevice {
            print("InputDeviceAsInputMixerSource:\(currentDevice)")
            //take the mic node after plugin
            guard let micNode = bus1Node else { fatalError() }
            //connect with mixer to do callBack before playing
            //使用 mixer bus 1 as input
            try? AudioKit.stop()
            mixer.disconnectInput(bus: 2)
            mixer.connect(input: micNode, bus: 1)
            try? AudioKit.start()
            return
            
        } else {
            //disconnect on bus 1 (mic bus)
            try? AudioKit.stop()
            mixer.disconnectInput(bus: 1)
            try? AudioKit.start()
            
            for fileName in fileInDevice{
                if fileName == inputSource {
                    //set the file as mixer input
                    let result = Result{ try AKAudioFile(readFileName: fileName, baseDir: .documents)}
                    
                    switch result {
                    case .success(let file):
                        filePlayer = AKPlayer(audioFile: file)
                        try? AudioKit.stop()
                        mixer.connect(input: filePlayer, bus: 2)
                        try? AudioKit.start()
                        return
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            // do error handle
            print(inputSource)
            print("dont use")
        }
    }
    
}

extension ViewController: IOGridViewCellDatasource {
    
    func inputSource() -> [String] {
        var fileInDeviceNameArr = getFileFromDevice()
        guard let currentInputDevice = AudioKit.inputDevice?.deviceID else { fatalError() }
        fileInDeviceNameArr.insert(currentInputDevice, at: 0)
        return fileInDeviceNameArr
    }
    
    func getFileFromDevice() -> [String] {
        let path = NSHomeDirectory() + "/Documents"
        
        var fileNameArr: [String] = []
        let result = Result{try FileManager.default.contentsOfDirectory(atPath: path)}
        switch result {
        case .success(let fileArr):
            fileNameArr = fileArr
        case .failure(let error):
            print(error)
        }
        return fileNameArr
    }
}

