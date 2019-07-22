//
//  OpenRecordingViewController.swift
//  MasterMockup
//
//  Created by Jesse Joseph on 15/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import UIKit
import Speech

class OpenRecordingViewController: UIViewController {
    @IBOutlet weak var resultPageControl: UIPageControl!
    @IBOutlet weak var resultCollectionView: UICollectionView!
    @IBOutlet weak var durationProgressBar: UIProgressView!
    
    @IBOutlet weak var playbackRecordingButton: UIButton!
    @IBOutlet weak var rightCountLabel: UILabel!
    @IBOutlet weak var leftCountLabel: UILabel!
    
    var numberOfRecordingThatWillBeOpened: Int = 0
    var isPlaying: Bool = false
    var bootingRecorderFile: Bool = false
    
    let image:UIImage = #imageLiteral(resourceName: "SiKaset")
    var comments:[String]=["SomePlaceholder","SomePlaceholder"]
    var result:[String]=["Placeholder","Placeholder"]
    let indicator:[UIImage]=[#imageLiteral(resourceName: "Measure"),#imageLiteral(resourceName: "Measure")]
    let cellTitle:[String] = ["Pacing","Filler Words"]
    
    var audioPlayer: AVAudioPlayer!
    let audioSession = AVAudioSession.sharedInstance()
    var rightCount: Int = 0
    var leftCount: Int = 0
    var end: Bool = false
    
    var fillerWordKey = [String]()
    var fillerWordValue = [Int]()
    
    var timer: Timer?
    
    override func viewDidLoad() {
        resultPageControl.numberOfPages = 2
        resultCollectionView.delegate = self
        resultCollectionView.dataSource = self
        
        resultCollectionView.layer.borderWidth = 1
        resultCollectionView.layer.borderColor = UIColor.black.cgColor
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let load = CoreDataHelper(appDelegate: appDelegate)
        var resultData:RecordingStruct? = load.getData(recordingName: "recording\(numberOfRecordingThatWillBeOpened)")
        if let data = resultData{
            self.result[0] = String(format: "%.2f WPM",data.averageWPM )
            resultCollectionView.delegate = self
            resultCollectionView.dataSource = self
            result[1] = "\(getFillerWordSum(fillerWordList: data.fillerWords)) filler word found"
            setWPMComment(wpmnum: data.averageWPM)
    //        bootingRecorderFile = false
    //        //MARK: TEST DI SINI
            let triangle = TriangleView(wpm: data.averageWPM)
            triangle.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 0)
            resultCollectionView.addSubview(triangle)
        }
        print("File recording\(numberOfRecordingThatWillBeOpened).m4a opened !!")
        durationProgressBar.transform = durationProgressBar.transform.scaledBy(x: 1, y: 3)
        loadAudio()
    }
    
    // sum dari fillerwordlist
    func getFillerWordSum(fillerWordList:[String:Int]) -> Int {
        var sumFillerWord = 0
        for word in fillerWordList {
            sumFillerWord += word.value
            fillerWordValue.append(word.value)
            fillerWordKey.append(word.key)
        }
        setFillerWordComment(fillerWordList:fillerWordList)
        return sumFillerWord
    }
    
    // set komentar untuk filler word
    func setFillerWordComment(fillerWordList:[String:Int]) {
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
    @IBAction func playbackRecordingButtonIsTapped(_ sender: Any) {
        
        if self.end == true {
            var right = Float(audioPlayer.duration)
            right.round(.up)
            self.rightCount = Int(right)
            self.leftCount = 0
            self.rightCountLabel.text = "- \(rightCount.asTimeStrings())"
            self.leftCountLabel.text = leftCount.asTimeStrings()
            durationProgressBar.setProgress(0.0, animated: false)
            self.end = false
        }
        if isPlaying == false {
            // GANTI GAMBAR BUTTON DI BAGIAN INI
            let image = UIImage(named: "PauseResult") as UIImage?
            playbackRecordingButton.setImage(image, for: .normal)
            audioPlayer.play()
            isPlaying = true
        } else {
            // GANTI GAMBAR BUTTON DI BAGIAN INI
            let image = UIImage(named: "PlayResult") as UIImage?
            playbackRecordingButton.setImage(image, for: .normal)
            audioPlayer.pause()
            isPlaying = false
        }
        setProgress()
    }
    
    func loadAudio(){
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording\(numberOfRecordingThatWillBeOpened).m4a")
        do {
            configureAudioSessionToSpeaker()
            try audioPlayer = AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer.volume = 1
            var rightCount = Float(audioPlayer.duration)
            rightCount.round(.up)
            self.rightCount = Int(rightCount)
            self.leftCount = 0
            rightCountLabel.text = "- \(self.rightCount.asTimeStrings())"
            leftCountLabel.text = self.leftCount.asTimeStrings()
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
            playbackRecordingButton.setImage(image, for: .normal)
            timer?.invalidate()
            timer = nil
            self.end = true
            isPlaying = false
        }
        
        self.rightCountLabel.text = "- \(rightCount.asTimeStrings())"
        self.leftCountLabel.text = leftCount.asTimeStrings()
        
        print("left count : ", self.leftCount.asTimeStrings())
        print("right count : ", self.rightCount.asTimeStrings())
        print("duration : ", duration)
        print("current time : ", currentTime)
        print("=========================")
    }
    
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
    
    // Function that gets path to the library
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

struct TimePart: CustomStringConvertible {
    var seconds = 0
    var minutes = 0
    var description: String {
        return String(format: "%02d:%02d", minutes, seconds) as String
    }
    
}

extension Int{
    func toTimePart() -> TimePart {
        let seconds = self
        var mins = 0
        var secs = seconds
        if seconds >= 60 {
            mins = Int(seconds / 60)
            secs = seconds - (mins * 60)
        }
        return TimePart(seconds: secs, minutes: mins)
    }
    
    func asTimeStrings() -> String {
        return toTimePart().description
    }
}

extension OpenRecordingViewController:UICollectionViewDelegate,UICollectionViewDataSource{
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
        self.resultPageControl.currentPage = indexPath.row
    }
}
