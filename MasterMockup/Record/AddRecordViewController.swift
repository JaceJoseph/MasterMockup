//
//  AddRecordViewController.swift
//  MasterMockup
//
//  Created by Jesse Joseph on 12/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import UIKit
import Speech

class AddRecordViewController: UIViewController {
    
    @IBOutlet weak var recordImage: UIImageView!
    @IBOutlet weak var recordButton: UISwitch!
    @IBOutlet weak var finishRecordButton: UIButton!
    
    //untuk record m4a
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioFileName: URL!
    
    // Add on Tommy
    var numberOfRecords: Int = 0
    // Add on Tommy
    
    //untuk live transcribe
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    //var startTime: DispatchTime?
    var previousTime: DispatchTime?
    let checkLiveWPMEvery:Int = 10
    var previousWordCount:Int = 0
    var listOfLiveWPMs:[liveWPMInfo]=[liveWPMInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Inisialisasi UserDefault
        if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int {
            numberOfRecords = number
        }
        
        // Finish record button tidak bisa di tekan
        finishRecordButton.isEnabled = false
        
    }
    
    @IBAction func recordButtonIsTapped(_ sender: UISwitch) {
        if sender.isOn == true{
            sender.isOn = false
            recordImage.layer.removeAllAnimations()
        }else if sender.isOn == false{
            sender.isOn = true
            recordImage.rotate360Degrees()
            startRecording()
            finishRecordButton.isEnabled = true
        }
    }
    
    @IBAction func finishRecordButtonIsTapped(_ sender: Any) {
        
        recordButton.setOn(false, animated: true)
        recordImage.layer.removeAllAnimations()
        saveRecording()
    }
    
//setup permission pengunaan mic
    func setupRecordingPermission(){
        self.recordingSession = AVAudioSession.sharedInstance()
        do{
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        //enable record button
                    }
                }
            }
        }catch{}
    }
    
//dapatin direcotry documents applikasi ini
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
//memulai recording
    func startRecording(){
        // Penomoran Recording
        numberOfRecords += 1
        
        //kasih nama ke recording filenya
        audioFileName = self.getDocumentsDirectory().appendingPathComponent("recording\(numberOfRecords).m4a")
        
        //setup setting recording
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        //coba record voice
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self as? AVAudioRecorderDelegate
            audioRecorder.record()
        } catch {}
        //live transcribe utk live wpm
        DispatchQueue.global(qos: .userInteractive).async {
            print("live recog")
            //self.startTime = DispatchTime.now()
            self.previousTime = DispatchTime.now()
            let node = self.audioEngine.inputNode
            let recordingFormat = node.outputFormat(forBus: 0)
            node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat){ buffer, _ in self.request.append(buffer)}
            
            self.audioEngine.prepare()
            do {
                try self.audioEngine.start()
                //self.startTime = DispatchTime.now()
                self.previousTime = DispatchTime.now()
            } catch {
                print(error)
            }
            
            guard let myRecognizer = SFSpeechRecognizer() else {
                return
            }
            if !myRecognizer.isAvailable{
                return
            }
            
            self.recognitionTask = self.speechRecognizer?.recognitionTask(with: self.request, resultHandler: { result, error in
                if let result = result {
                    let bestString = result.bestTranscription.formattedString
                    print(bestString)
                    let numOfWords = self.getNumberOfWords(words: bestString)
                    //calculate live wpm every checkLiveWPMEvery words spoken
                    if (numOfWords - self.previousWordCount) >= self.checkLiveWPMEvery{
                        let currentLiveWPM = self.calculateLiveWPM(numberOfAddedWords: numOfWords)
                        print("current wpm:\(currentLiveWPM)")
                        self.listOfLiveWPMs.append(liveWPMInfo(wpmValue: Int(currentLiveWPM), timeTaken: self.previousTime!))
                        self.previousWordCount = numOfWords
                    }
                }else{
                    print(error)
                }
            })
        }
    }
//pause recording
    func pauseRecording(){
        audioRecorder.pause()
    }
//stop recording tanpa save
    func stopRecording(){
        audioRecorder.stop()
        audioRecorder.deleteRecording()
        audioRecorder = nil
    }
//stop record dan save voice nya
    func saveRecording(){
        audioRecorder.stop()
        audioRecorder = nil
        
        // Menambah user default untuk number of recoring
        UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
    }
    
    //haris - transferdata ke result tabel
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResultSegue"{
            guard let result = segue.destination as? ResultTableViewController else {return}
            result.audioFileName = self.audioFileName
            result.listOfLiveWPMs = self.listOfLiveWPMs
            result.numOfRecordsTemporary = self.numberOfRecords
        }
    }
    
    //split string by space utk dapetin num of words
    func getNumberOfWords(words:String)->Int{
        let listString = words.components(separatedBy: " ")
        return listString.count;
    }
    
    //calculate live current wpm
    func calculateLiveWPM(numberOfAddedWords: Int) -> Double{
        let timeNow = DispatchTime.now()
        let nanoTime = timeNow.uptimeNanoseconds - previousTime!.uptimeNanoseconds
        previousTime = timeNow
        let timeInterval = Double(nanoTime) / 1_000_000_000
        print("duration: \(timeInterval) seconds")
        return (((Double(numberOfAddedWords)) / (Double(timeInterval))) * 60)
    }
}

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 3) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
