//
//  ResultTableViewController.swift
//  MasterMockup
//
//  Created by Haris Shobaruddin Roabbni on 15/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import UIKit
import Speech

class ResultTableViewController: UITableViewController {
    
    var audioFileName: URL!
    var listOfLiveWPMs:[liveWPMInfo]=[liveWPMInfo]()
    
    //wpm result
    var wpmValue: Double = 0
    var wpmResult: String = ""
    var WPMDescription: String = ""
    
    //filler word result
    var detectedFiller: Double = 0
    var fillerWordResult: String = ""
    var fillerWordDescription: String = ""
    
    //intonation result
    var intonationResult: String = ""
    var intonationDescription: String = ""
    
    // Pencatatan Number of Records (DATA INI TIDAK DITAMPILKAN DI SINI, PERANTARA KE HALAMAN AWAL)
    var numOfRecordsTemporary: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set Result Here
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 2
        } else if section == 1 {
            return 2
        }else{
            return 1
        }
    }
    
//addon untuk wpm
    //check permision transcribe voice
    func setupTranscribingPermission() {
        print("requestTranscribePermissions")
        SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Good to go!")
                    self.transcribeAudio()
                }
            }
        }
    }
    //transcribe audio
    func transcribeAudio() {
        print("transcribeAudio")
        // bikin recognizer baru, dan set locale
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        let request = SFSpeechURLRecognitionRequest(url: self.audioFileName)
        
        // mulai recognition
        recognizer?.recognitionTask(with: request) { [unowned self] (result, error) in
            // abort if we didn't get any transcription back
            guard let result = result else {
                print("error")
                return
            }
            
            // kalau dapat hasil
            if result.isFinal {
                // dapatin best transcription
                let ans = result.bestTranscription.formattedString
                //seperate by space utk dapatin word count
                let listString = ans.components(separatedBy: " ")
                print("words:",listString.count)
                print("wpm:",self.calculateWPM(numberOfWords: listString.count))
                print("=============================")
            }
        }
    }
    
    //calculate words per minute(ini utk average)
    func calculateWPM(numberOfWords: Int) -> Double{
        let asset = AVURLAsset(url: self.audioFileName)
        let audioDuration = asset.duration
        let audioDurationSeconds = CMTimeGetSeconds(audioDuration)
        print("duration:",audioDurationSeconds,"seconds")
        return (((Double(numberOfWords)) / (Double(audioDurationSeconds))) * 60)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dataVC = segue.destination as? ViewController else {return}
        dataVC.add(name: String(numOfRecordsTemporary))
        
    }

}
