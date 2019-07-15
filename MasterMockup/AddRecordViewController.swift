//
//  AddRecordViewController.swift
//  MasterMockup
//
//  Created by Jesse Joseph on 12/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import UIKit
//addon michael
import Speech
//addon michael done
class AddRecordViewController: UIViewController {

    @IBOutlet weak var recordImage: UIImageView!
    @IBOutlet weak var recordButton: UISwitch!
    
    //addon michael
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    //addon michael done
    
    //addon haris
    var WPMValue = Double()
    //addon harid done
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func recordButtonIsTapped(_ sender: UISwitch) {
        if sender.isOn == true{
            sender.isOn = false
            recordImage.layer.removeAllAnimations()
        }else if sender.isOn == false{
            sender.isOn = true
            recordImage.rotate360Degrees()
        }
    }
    
//addon michael gunawan //belum di attach ke button ya
    
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
        //kasih nama ke recording filenya
        let audioFilename = self.getDocumentsDirectory().appendingPathComponent("recording.m4a")
        //setup setting recording
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        //coba record voice
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self as? AVAudioRecorderDelegate
            audioRecorder.record()
        } catch {}
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
    }
//addon untuk wpm, temporary disini utk testing
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
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "id-ID"))
        let request = SFSpeechURLRecognitionRequest(url: self.getDocumentsDirectory().appendingPathComponent("recording.m4a"))
        
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
                self.WPMValue = self.calculateWPM(numberOfWords: listString.count)
            }
        }
    }
    //calculate words per minute(ini utk average)
    func calculateWPM(numberOfWords: Int) -> Double{
        let asset = AVURLAsset(url: self.getDocumentsDirectory().appendingPathComponent("recording.m4a"), options: nil)
        let audioDuration = asset.duration
        let audioDurationSeconds = CMTimeGetSeconds(audioDuration)
        print("duration:",audioDurationSeconds,"seconds")
        return (((Double(numberOfWords)) / (Double(audioDurationSeconds))) * 60)
    }
    //haris - transferdata ke result tabel
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResultSegue"{
            guard let result = segue.destination as? ResultTableViewController else {return}
            result.wpmValue = self.WPMValue
        }
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
