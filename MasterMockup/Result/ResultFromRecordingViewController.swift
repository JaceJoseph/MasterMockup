//
//  ResultFromRecordingViewController.swift
//  MasterMockup
//
//  Created by Jesse Joseph on 17/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import UIKit
import Speech

class ResultFromRecordingViewController: UIViewController {
    
    @IBOutlet weak var cassetteImage: UIImageView!
    @IBOutlet weak var resultCollectionView: UICollectionView!
    @IBOutlet weak var resultPageController: UIPageControl!
    @IBOutlet weak var durationProgressBar: UIProgressView!
    
    @IBOutlet weak var playbackButton: UIButton!
    @IBOutlet weak var rightCountLabel: UILabel!
    @IBOutlet weak var leftCountLabel: UILabel!
    
    //url lokasi recording yang baru direcord
    var audioFileName: URL!
    var audioFileNumber: String!
    
    //list of struct berisi semua live wpm dan time nya
    var listOfLiveWPMs:[liveWPMInfo]=[liveWPMInfo]()
    
    //audio engine utk recognition wpm akurat
    let audioEngine = AVAudioEngine()
    
    // Pencatatan Number of Records (DATA INI TIDAK DITAMPILKAN DI SINI, PERANTARA KE HALAMAN ALL RECORDS)
    var numOfRecordsTemporary: Int = 0
    var timeLabelRecordingTemporary: String = ""
    
    // list filler word
    var fillerWordList = [String: Int]()
    var fillerWordKey = [String]()
    var fillerWordValue = [Int]()
    
    let image:UIImage = #imageLiteral(resourceName: "SiKaset")
    var isPlaying: Bool = false
    var bootingRecorderFile: Bool = false
    
    var audioPlayer: AVAudioPlayer!
    let audioSession = AVAudioSession.sharedInstance()
    var rightCount: Int = 0
    var leftCount: Int = 0
    var end: Bool = false
    
    var comments:[String]=["SomePlaceholder","SomePlaceholder"]
    var result:[String]=["Placeholder","Placeholder"]
    let indicator:[UIImage]=[#imageLiteral(resourceName: "bar wpm"),#imageLiteral(resourceName: "Measure")]
    let cellTitle:[String] = ["Pacing","Filler Words"]
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var wpm:Double = getFastAvgWpm()
        if(wpm.isNaN){
            wpm = 0
        }
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let saveResults = CoreDataHelper(appDelegate: appDelegate)
        saveResults.insertData(data: RecordingStruct(averageWPM: wpm, recordingName: audioFileNumber, fillerWords: fillerWordList))
        self.result[0] = String(format: "%.2f WPM",wpm )
        setWPMComment(wpmnum: wpm)
        resultCollectionView.delegate = self
        resultCollectionView.dataSource = self
        result[1] = "\(getFillerWordSum()) filler word found"
        print("fast avg wpm:",getFastAvgWpm())
        
        //print("fast avg wpm:",getFastAvgWpm())
        print(numOfRecordsTemporary)
        print(timeLabelRecordingTemporary)
        print("List Filler Word: ", fillerWordList)
        
        bootingRecorderFile = false
        
        //MARK: TEST DI SINI
        let triangle = TriangleView(wpm: getFastAvgWpm())
        triangle.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 0)
        resultCollectionView.addSubview(triangle)
        
        // SET USER DEFAULT APABILA INGIN DI SAVE (SAAT INI PASTI DI SAVE)
        let defaults = UserDefaults.standard
        var nameRecordingArray = defaults.object(forKey:"nameArray") as? [String] ?? [String]()
        var timeRecordingArray = defaults.object(forKey: "timeArray") as? [String] ?? [String]()
        
        nameRecordingArray.append("Recording\(numOfRecordsTemporary)")
        timeRecordingArray.append(timeLabelRecordingTemporary)
        
        defaults.set(nameRecordingArray, forKey: "nameArray")
        defaults.set(timeRecordingArray, forKey: "timeArray")
        
        durationProgressBar.transform = durationProgressBar.transform.scaledBy(x: 1, y: 3)
        loadAudio()
        
    }
    
    @IBAction func playbackButtonIsTapped(_ sender: Any) {
        if self.end == true {
            var right = Float(audioPlayer.duration)
            right.round(.up)
            self.rightCount = Int(right)
            self.leftCount = 0
            self.rightCountLabel.text = "- \(rightCount.asTimeString())"
            self.leftCountLabel.text = leftCount.asTimeString()
            durationProgressBar.setProgress(0.0, animated: false)
            self.end = false
        }
        if isPlaying == false {
            // GANTI GAMBAR BUTTON DI BAGIAN INI
            let image = UIImage(named: "PauseResult") as UIImage?
            playbackButton.setImage(image, for: .normal)
            audioPlayer.play()
            isPlaying = true
        } else {
            // GANTI GAMBAR BUTTON DI BAGIAN INI
            let image = UIImage(named: "PlayResult") as UIImage?
            playbackButton.setImage(image, for: .normal)
            audioPlayer.pause()
            isPlaying = false
        }
        setProgress()
    }
    
    func loadAudio(){
        let audioFilename = audioFileName
        do {
            configureAudioSessionToSpeaker()
            try audioPlayer = AVAudioPlayer(contentsOf: audioFilename!)
            audioPlayer.volume = 1
            var rightCount = Float(audioPlayer.duration)
            rightCount.round(.up)
            self.rightCount = Int(rightCount)
            self.leftCount = 0
            rightCountLabel.text = "- \(self.rightCount.asTimeString())"
            leftCountLabel.text = self.leftCount.asTimeString()
            print("rounded : ", rightCount)
        } catch {
            
        }
    }
    
    func setProgress() {
        if isPlaying == false {
            timer?.invalidate()
            timer = nil
            print("paused")
        }else{
            timer = Timer.scheduledTimer(timeInterval: 0.01,
                                         target: self,
                                         selector: #selector(updateAudioProgressBar),
                                         userInfo: nil,
                                         repeats: true)
            timer = Timer.scheduledTimer(timeInterval: 0.1,
                                         target: self,
                                         selector: #selector(updateDurationLabel),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    @objc func updateAudioProgressBar(){
        if audioPlayer.isPlaying
        {
            // Update progress
            let currentTime = Float(audioPlayer.currentTime)
            let duration = Float(audioPlayer.duration)
            durationProgressBar.setProgress(currentTime/duration, animated: true)
        }
    }
    
    @objc func updateDurationLabel() {
        var duration = Float(audioPlayer.duration)
        var currentTime = Float(audioPlayer.currentTime)
        currentTime.round(.up)
        duration.round(.up)
        
        self.rightCount = Int(duration) - Int(currentTime == 0 ? duration : currentTime)
        self.leftCount = Int(duration) - rightCount
        
        if self.rightCount == 0 {
            self.rightCount = 0
            let image = UIImage(named: "PlayResult") as UIImage?
            playbackButton.setImage(image, for: .normal)
            timer?.invalidate()
            timer = nil
            self.end = true
            isPlaying = false
        }
        
        self.rightCountLabel.text = "- \(rightCount.asTimeString())"
        self.leftCountLabel.text = leftCount.asTimeString()
        
        print("left count : ", self.leftCount.asTimeString())
        print("right count : ", self.rightCount.asTimeString())
        print("duration : ", duration)
        print("current time : ", currentTime)
        print("=========================")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let segueToAllRecord = segue.destination as? AllRecordViewController
        
        // Function to append to AllRecordViewController
        segueToAllRecord?.addRecord(name: String(numOfRecordsTemporary))
        segueToAllRecord?.addTimeRecord(time: timeLabelRecordingTemporary)
        segueToAllRecord?.allRecordTableView.reloadData()
        
        print("=====================================")
        print("Record added with \(numOfRecordsTemporary)")
        print("Time Label : \(timeLabelRecordingTemporary)")
    }
    
    // Configure Iphone's Speaker (Bottom Speaker)
    func configureAudioSessionToSpeaker(){
    do {
        try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        try audioSession.setActive(true)
        print("Successfully configured audio session (SPEAKER-Bottom).", "\nCurrent audio route: ",audioSession.currentRoute.outputs)
    } catch let error as NSError {
        print("#configureAudioSessionToSpeaker Error \(error.localizedDescription)")
        // Configure Iphone's Speaker (Bottom Speaker)
        func configureAudioSessionToSpeaker(){
            do {
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                try audioSession.setActive(true)
                print("Successfully configured audio session (SPEAKER-Bottom).", "\nCurrent audio route: ",audioSession.currentRoute.outputs)
            } catch let error as NSError {
                print("#configureAudioSessionToSpeaker Error \(error.localizedDescription)")
                }
            }
        }
    }
    
    //sum dari semua total wpm dibagi jumblah wpm utk average
    func getFastAvgWpm()->Double{
        var totalWPM:Double = 0
        let wpmCount:Int = listOfLiveWPMs.count
        for wpmInfo in listOfLiveWPMs{
            totalWPM += wpmInfo.wpmValue
        }
        return Double(totalWPM/Double(wpmCount))
    }
    
    // sum dari fillerwordlist
    func getFillerWordSum() -> Int {
        var sumFillerWord = 0
        for word in fillerWordList {
            sumFillerWord += word.value
            fillerWordValue.append(word.value)
            fillerWordKey.append(word.key)
        }
        setFillerWordComment()
        return sumFillerWord
    }
    
    // set komentar untuk filler word
    func setFillerWordComment() {
        var dumy = ""
        var finalComment = ""
        if fillerWordKey.count == 0 {
            comments[1] = "Great ! there is no filler word we hear from your presentation"
        }else{
            for word in fillerWordList {
                dumy = "\(word.key) : \(word.value)"
                if finalComment == ""{
                    finalComment = dumy
                }else{
                    finalComment = "\(finalComment) \n \(dumy)"
                }
            }
            comments[1] = finalComment
        }
    }
    
    func setWPMComment(wpmnum:Double){
        if(wpmnum<=100){
            comments[0]="You did good, but it was a bit slow, try speaking faster!";
        }else if(wpmnum>100 && wpmnum<170){
            comments[0]="You did get, your pacing is on the spot, keep it up";
        }else if(wpmnum >= 170){
            comments[0]="You did good, but it was a bit fast, try speaking slower!";
        }
    }

}

struct TimeParts: CustomStringConvertible {
    var seconds = 0
    var minutes = 0
    var description: String {
        return String(format: "%02d:%02d", minutes, seconds) as String
    }
    
}

extension Int{
    func toTimeParts() -> TimeParts {
        let seconds = self
        var mins = 0
        var secs = seconds
        if seconds >= 60 {
            mins = Int(seconds / 60)
            secs = seconds - (mins * 60)
        }
        return TimeParts(seconds: secs, minutes: mins)
    }
    
    func asTimeString() -> String {
        return toTimeParts().description
    }
}

extension ResultFromRecordingViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pacingCell", for: indexPath) as! PacingCollectionViewCell
        let selector = indexPath.row
        
        if selector == 1 {
            cell.setCell(title: cellTitle[selector], image: image, comment: comments[selector], result: result[selector], indicator: UIImage())
        }else{
            cell.setCell(title: cellTitle[selector], image: image, comment: comments[selector], result: result[selector], indicator: indicator[selector])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.resultPageController.currentPage = indexPath.row
    }
}
