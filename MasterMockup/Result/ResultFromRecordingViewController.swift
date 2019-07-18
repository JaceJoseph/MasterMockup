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
    
    @IBOutlet weak var playbackButton: UIButton!
    
    //url lokasi recording yang baru direcord
    var audioFileName: URL!
    var audioFileNumber: String!
    //list of struct berisi semua live wpm dan time nya
    var listOfLiveWPMs:[liveWPMInfo]=[liveWPMInfo]()
    //audio engine utk recognition wpm akurat
    let audioEngine = AVAudioEngine()
    // Pencatatan Number of Records (DATA INI TIDAK DITAMPILKAN DI SINI, PERANTARA KE HALAMAN ALL RECORDS)
    var numOfRecordsTemporary: Int = 0
    // list filler word
    var fillerWordList = [String: Int]()
    var fillerWordKey = [String]()
    var fillerWordValue = [Int]()
    
    let image:UIImage = #imageLiteral(resourceName: "SiKaset")
    var isPlaying: Bool = false
    var bootingRecorderFile: Bool = false
    
    var audioPlayer: AVAudioPlayer!
    let audioSession = AVAudioSession.sharedInstance()
    
    var comments:[String]=["SomePlaceholder","SomePlaceholder"]
    var result:[String]=["Placeholder","Placeholder"]
    let indicator:[UIImage]=[#imageLiteral(resourceName: "bar wpm"),#imageLiteral(resourceName: "Measure")]
    let cellTitle:[String] = ["Pacing","Filler Words"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var wpm:Double = getFastAvgWpm()
        if(wpm.isNaN){
            wpm = 0
        }
        var saveResults = CoreDataHelper(appDelegate: UIApplication.shared.delegate as? AppDelegate)
        saveResults.insertData(data: RecordingStruct(averageWPM: wpm, recordingName: audioFileNumber, fillerWords: fillerWordList))
        self.result[0] = String(format: "%.2f WPM",wpm )
        resultCollectionView.delegate = self
        resultCollectionView.dataSource = self
        result[1] = "\(getFillerWordSum()) filler word found"
        print("fast avg wpm:",getFastAvgWpm())
        //print("fast avg wpm:",getFastAvgWpm())
        print(numOfRecordsTemporary)
        
        bootingRecorderFile = false
        //MARK: TEST DI SINI
        let triangle = TriangleView(wpm: getFastAvgWpm())
        triangle.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 0)
        resultCollectionView.addSubview(triangle)
        // SET USER DEFAULT APABILA INGIN DI SAVE (SAAT INI PASTI DI SAVE)
        let defaults = UserDefaults.standard
        var nameRecordingArray = defaults.object(forKey:"nameArray") as? [String] ?? [String]()
        nameRecordingArray.append("Recording\(numOfRecordsTemporary)")
        defaults.set(nameRecordingArray, forKey: "nameArray")
        
    }
    
    @IBAction func playbackButtonIsTapped(_ sender: Any) {
        if bootingRecorderFile == false {
            let audioFilename = audioFileName
            do{
                configureAudioSessionToSpeaker()
                try audioPlayer = AVAudioPlayer(contentsOf: audioFilename!)
                audioPlayer.volume = 1
                
            }catch{}
        }
        else {
            if isPlaying == false {
                // GANTI GAMBAR BUTTON DI BAGIAN INI
                let image = UIImage(named: "PauseResult") as UIImage?
                playbackButton.setImage(image, for: .normal)
                audioPlayer.play()
                isPlaying = true
            }
            else {
                // GANTI GAMBAR BUTTON DI BAGIAN INI
                let image = UIImage(named: "PlayResult") as UIImage?
                playbackButton.setImage(image, for: .normal)
                audioPlayer.pause()
                isPlaying = false
            }
        }
        
        bootingRecorderFile = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let segueToAllRecord = segue.destination as? AllRecordViewController
        
        // Function to append to AllRecordViewController
        segueToAllRecord?.addRecord(name: String(numOfRecordsTemporary))
        print("Record added with \(numOfRecordsTemporary)")
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

}
extension ResultFromRecordingViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pacingCell", for: indexPath) as! PacingCollectionViewCell
        let selector = indexPath.row
        cell.setCell(title: cellTitle[selector], image: image, comment: comments[selector], result: result[selector], indicator: indicator[selector])
        
        if selector == 1 {
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.resultPageController.currentPage = indexPath.row
    }
}
