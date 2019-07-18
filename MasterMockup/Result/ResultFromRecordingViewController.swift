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
    
    var audioFileName: URL!
    var listOfLiveWPMs:[liveWPMInfo]=[liveWPMInfo]()
    
    // Pencatatan Number of Records (DATA INI TIDAK DITAMPILKAN DI SINI, PERANTARA KE HALAMAN ALL RECORDS)
    var numOfRecordsTemporary: Int = 0
    var isPlaying: Bool = false
    var bootingRecorderFile: Bool = false
    
    var audioPlayer: AVAudioPlayer!
    let audioSession = AVAudioSession.sharedInstance()
    
    let image:UIImage = #imageLiteral(resourceName: "SiKaset")
    let comments:[String]=["SomePlaceholder","SomePlaceholder","SomePlaceholder"]
    let result:[String]=["Placeholder","Placeholder","Placeholder"]
    let indicator:[UIImage]=[#imageLiteral(resourceName: "Measure"),#imageLiteral(resourceName: "Measure"),#imageLiteral(resourceName: "Measure")]
    let cellTitle:[String] = ["Pacing","Filler Words","Intonation"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultCollectionView.delegate = self
        resultCollectionView.dataSource = self
        print(numOfRecordsTemporary)
        
        bootingRecorderFile = false
        
        // SET USER DEFAULT APABILA INGIN DI SAVE (SAAT INI PASTI DI SAVE)
        let defaults = UserDefaults.standard
        var nameRecordingArray = defaults.object(forKey:"nameArray") as? [String] ?? [String]()
        nameRecordingArray.append("Recording\(numOfRecordsTemporary)")
        defaults.set(nameRecordingArray, forKey: "nameArray")
        
    }
    
    @IBAction func playbackButtonIsTapped(_ sender: Any) {
        if bootingRecorderFile == false {
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording\(numOfRecordsTemporary).m4a")
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
        }
    }
    
    // Function that gets path to the library
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.resultPageController.currentPage = indexPath.row
    }
}

