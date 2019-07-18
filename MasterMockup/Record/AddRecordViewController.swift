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
    
    let watch = Stopwatch()
    var timer:Timer?
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var pauseRecordButton: UIButton!
    @IBOutlet weak var resumeRecordButton: UIButton!
    
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    
    //untuk record m4a
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioFileName: URL!
    var audioFileNumber: String!
    // Add on Tommy
    var numberOfRecords: Int = 0
    var isRecording: Bool = false
    // Add on Tommy
    
    // list filler word
    var detectedFillerWord: [String:Int] = [:]
    var listedFillerWord = ["so", "like", "I mean", "you know", "ok", "so basicly", "OK", "literaly"]
    
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
    //var transcribe:Bool = true
    
    @objc func updateElapsedTimeLabel(timer: Timer) {
        if watch.isRunning {
            let minutes = Int(watch.elapsedTime/60)
            let seconds = Int(watch.elapsedTime.truncatingRemainder(dividingBy: 60))
            let tenOfSeconds = Int((watch.elapsedTime * 10).truncatingRemainder(dividingBy: 10))
            elapsedTimeLabel.text = String(format: "%02d:%02d.%d", minutes, seconds, tenOfSeconds)
        }
        else {
            timer.invalidate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Inisialisasi UserDefault
        if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int {
            numberOfRecords = number
        }
        
        // Resume dan Pause button tidak dapat di tekan apabila belum mulai recording
        resumeRecordButton.isEnabled = false
        pauseRecordButton.isEnabled = false
        
        // Status awal recording
        isRecording = false
        
    }

    @IBAction func recordButtonIsTapped(_ sender: Any) {
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateElapsedTimeLabel(timer:)), userInfo: nil, repeats: true)
        
        pauseRecordButton.isEnabled = true
        resumeRecordButton.isEnabled = false
        
        // GANTI GAMBAR BUTTON DI BAGIAN INI
        let image = UIImage(named: "Stop Button") as UIImage?
        recordButton.setImage(image, for: .normal)
        recordButton.isEnabled = true
        
        if isRecording == false {
            startRecording()
            watch.start()
            print("AWAL RECORD")
        }
        else {
            stopTranscribing()
            watch.stop()
            saveRecording()
            print("SELESAI RECORD")
            
            performSegue(withIdentifier: "toResult", sender: self)
        }
        
        // Status recording menjadi True
        isRecording = true
    }
    
    @IBAction func pauseRecordButtonIsTapped(_ sender: Any) {
        stopTranscribing()
        pauseRecordButton.isEnabled = false
        resumeRecordButton.isEnabled = true
        
        watch.pause()
        timer?.invalidate()
        
        pauseRecording()
        isRecording = true
    }
    
    
    @IBAction func resumeRecordButtonIsTapped(_ sender: Any) {
        print("resumed")
        pauseRecordButton.isEnabled = true
        resumeRecordButton.isEnabled = false
        watch.resume()
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateElapsedTimeLabel(timer:)), userInfo: nil, repeats: true)
        //watch.start()
        
        print("try enabling live transcribe")
        liveTranscribe()
        print("success enabling live transcribe")
        resumeRecording()
        isRecording = true
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
        audioFileNumber = "recording\(numberOfRecords)"
        
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
        liveTranscribe()
    }
    
    func liveTranscribe(){
        DispatchQueue.global(qos: .userInteractive).async {
            self.setupTranscribingPermission()
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
                    print("numofwords:",numOfWords)
                    print("prev word count:",self.previousWordCount)
                    print("num of words till next wpm check:",(numOfWords - self.previousWordCount),"/",self.checkLiveWPMEvery)
                    if ((numOfWords - self.previousWordCount) >= self.checkLiveWPMEvery){
                        let currentLiveWPM = self.calculateLiveWPM(numberOfAddedWords: (numOfWords - self.previousWordCount))
                        print("current wpm:\(currentLiveWPM)")
                        self.listOfLiveWPMs.append(liveWPMInfo(wpmValue: Double(currentLiveWPM), timeTaken: self.previousTime!))
                        self.previousWordCount = numOfWords
                    }
                    
                    // detecting filler word
                    let word = bestString.components(separatedBy: " ")
                    let newWord = word.last!
                    var lastWord = ""
                    if numOfWords == 1 {
                        lastWord = word[0]
                    }else{
                        lastWord = word[numOfWords - 2]
                    }
                    let comparedWord = "\(lastWord) \(newWord)"
                    for word in self.listedFillerWord {
                        if newWord == word {
                            if self.detectedFillerWord["\(newWord)"] == nil{
                                self.detectedFillerWord["\(newWord)"] = 1
                            }else{
                                self.detectedFillerWord["\(newWord)"] = self.detectedFillerWord["\(newWord)"]! + 1
                            }
                            
                        } else if comparedWord == word {
                            if self.detectedFillerWord["\(comparedWord)"] == nil{
                                self.detectedFillerWord["\(comparedWord)"] = 1
                            }else{
                                self.detectedFillerWord["\(comparedWord)"] = self.detectedFillerWord["\(comparedWord)"]! + 1
                            }
                        }
                    }
                    print("filler Word List: \(self.detectedFillerWord)")
                }else{
                    print(error)
                }
            })
        }
    }
    
    func stopTranscribing(){
        print("stop transcribing")
        self.audioEngine.stop()
        self.recognitionTask?.cancel()
        self.audioEngine.inputNode.removeTap(onBus: 0)
        self.previousWordCount = 0
    }
    
//resume recording
    func resumeRecording(){
        audioRecorder.record()
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
    
//addon untuk wpm, temporary disini utk testing
    //check permision transcribe voice
    func setupTranscribingPermission() {
        print("requestTranscribePermissions")
        SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Good to go!")
                }
            }
        }
    }
    
    //haris - transferdata ke result tabel
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResult"{
            stopTranscribing()
            guard let result = segue.destination as? ResultFromRecordingViewController else {return}
            result.audioFileName = self.audioFileName
            result.listOfLiveWPMs = self.listOfLiveWPMs
            result.audioFileNumber = self.audioFileNumber
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
        print("calculating live wpm")
        let timeNow = DispatchTime.now()
        let nanoTime = timeNow.uptimeNanoseconds - previousTime!.uptimeNanoseconds
        previousTime = timeNow
        let timeInterval = Double(nanoTime) / 1_000_000_000
        print("duration: \(timeInterval) seconds")
        print("added words:",Double(numberOfAddedWords))
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
