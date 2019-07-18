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
    
    @IBOutlet weak var playbackRecordingButton: UIButton!
    
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
    
    var fillerWordKey = [String]()
    var fillerWordValue = [Int]()
    
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
    //        bootingRecorderFile = false
    //        //MARK: TEST DI SINI
            let triangle = TriangleView(wpm: data.averageWPM)
            triangle.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 0)
            resultCollectionView.addSubview(triangle)
        }
        print("File recording\(numberOfRecordingThatWillBeOpened).m4a opened !!")
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
    
    @IBAction func playbackRecordingButtonIsTapped(_ sender: Any) {
        
        if bootingRecorderFile == false {
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording\(numberOfRecordingThatWillBeOpened).m4a")
            do{
                configureAudioSessionToSpeaker()
                try audioPlayer = AVAudioPlayer(contentsOf: audioFilename)
                audioPlayer.volume = 1
                
            }catch{}
        }
        else {
            if isPlaying == false {
                // GANTI GAMBAR BUTTON DI BAGIAN INI
                let image = UIImage(named: "PauseResult") as UIImage?
                playbackRecordingButton.setImage(image, for: .normal)
                audioPlayer.play()
                isPlaying = true
            }
            else {
                // GANTI GAMBAR BUTTON DI BAGIAN INI
                let image = UIImage(named: "PlayResult") as UIImage?
                playbackRecordingButton.setImage(image, for: .normal)
                audioPlayer.pause()
                isPlaying = false
            }
        }
        
        bootingRecorderFile = true
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

extension OpenRecordingViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pacingCell", for: indexPath) as! PacingCollectionViewCell
        let selector = indexPath.row
        
        cell.setCell(title: cellTitle[selector], image: image, comment: comments[selector], result: result[selector], indicator: indicator[selector])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.resultPageControl.currentPage = indexPath.row
    }
}
