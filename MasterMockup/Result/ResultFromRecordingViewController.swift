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
    
    //url lokasi recording yang baru direcord
    var audioFileName: URL!
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
    var comments:[String]=["SomePlaceholder","SomePlaceholder","SomePlaceholder"]
    var result:[String]=["Placeholder","Placeholder","Placeholder"]
    let indicator:[UIImage]=[#imageLiteral(resourceName: "Measure"),#imageLiteral(resourceName: "Measure"),#imageLiteral(resourceName: "Measure")]
    let cellTitle:[String] = ["Pacing","Filler Words","Intonation"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultCollectionView.delegate = self
        resultCollectionView.dataSource = self
        result[1] = "\(getFillerWordSum()) filler word found"
        print("fast avg wpm:",getFastAvgWpm())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let segueToAllRecord = segue.destination as? AllRecordViewController
        
        // Function to append to AllRecordViewController
        segueToAllRecord?.addRecord(name: String(numOfRecordsTemporary))
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

