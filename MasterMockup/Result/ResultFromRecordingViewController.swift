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
    var audioFileNumber: String!
    //list of struct berisi semua live wpm dan time nya
    var listOfLiveWPMs:[liveWPMInfo]=[liveWPMInfo]()
    //audio engine utk recognition wpm akurat
    let audioEngine = AVAudioEngine()
    // Pencatatan Number of Records (DATA INI TIDAK DITAMPILKAN DI SINI, PERANTARA KE HALAMAN ALL RECORDS)
    var numOfRecordsTemporary: Int = 0
    
    var image:UIImage = #imageLiteral(resourceName: "SiKaset")
    var comments:[String]=["SomePlaceholder","SomePlaceholder","SomePlaceholder"]
    var result:[String]=["","Placeholder","Placeholder"]
    var indicator:[UIImage]=[#imageLiteral(resourceName: "Measure"),#imageLiteral(resourceName: "Measure"),#imageLiteral(resourceName: "Measure")]
    var cellTitle:[String] = ["Pacing","Filler Words","Intonation"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.result[0] = String(format: "%.2f WPM", getFastAvgWpm())
        resultCollectionView.delegate = self
        resultCollectionView.dataSource = self
        let triangle = TriangleView(wpm: 0)
        triangle.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 0)
        resultCollectionView.addSubview(triangle)
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
