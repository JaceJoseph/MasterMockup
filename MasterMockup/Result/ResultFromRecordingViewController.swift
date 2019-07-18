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
    var isPlaying: Bool = false
    var bootingRecorderFile: Bool = false
    
    var audioPlayer: AVAudioPlayer!
    let audioSession = AVAudioSession.sharedInstance()
    
    var image:UIImage = #imageLiteral(resourceName: "SiKaset")
    var comments:[String]=["SomePlaceholder","SomePlaceholder","SomePlaceholder"]
    var result:[String]=["","Placeholder","Placeholder"]
    var indicator:[UIImage]=[#imageLiteral(resourceName: "Measure"),#imageLiteral(resourceName: "Measure"),#imageLiteral(resourceName: "Measure")]
    var cellTitle:[String] = ["Pacing","Filler Words","Intonation"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var wpm:Double = getFastAvgWpm()
        if(wpm.isNaN){
            wpm = 0
        }
        self.result[0] = String(format: "%.2f WPM",wpm )
        resultCollectionView.delegate = self
        resultCollectionView.dataSource = self
        //print("fast avg wpm:",getFastAvgWpm())
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
    
        //MARK: TEST DI SINI
        let triangle = TriangleView(wpm: getFastAvgWpm())
        triangle.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 0)
        resultCollectionView.addSubview(triangle)
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

class TriangleView : UIView {
    
    init(wpm:Double) {
        let max:Double = 340
        let width:Double = 15
        let min:Double = 13+(width/2)
        var val:Double = 0
        if wpm <= 0 || wpm.isNaN{
            val = min
        }else if wpm >= 270{
            val = max+min
        }else{
            val = (((wpm/270)*max)+min)
        }
        let frame = CGRect(x: val-(width/2), y: 215, width: width , height: 15)
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.maxY))
        context.closePath()
        
        context.setFillColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context.fillPath()
    }
}
