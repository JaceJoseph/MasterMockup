//
//  ResultFromRecordingViewController.swift
//  MasterMockup
//
//  Created by Jesse Joseph on 17/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import UIKit

class ResultFromRecordingViewController: UIViewController {
    
    @IBOutlet weak var cassetteImage: UIImageView!
    @IBOutlet weak var resultCollectionView: UICollectionView!
    @IBOutlet weak var resultPageController: UIPageControl!
    
    
    var audioFileName: URL!
    var listOfLiveWPMs:[liveWPMInfo]=[liveWPMInfo]()
    
    // Pencatatan Number of Records (DATA INI TIDAK DITAMPILKAN DI SINI, PERANTARA KE HALAMAN ALL RECORDS)
    var numOfRecordsTemporary: Int = 0
    
    let image:UIImage = #imageLiteral(resourceName: "SiKaset")
    let comments:[String]=["SomePlaceholder","SomePlaceholder","SomePlaceholder"]
    let result:[String]=["Placeholder","Placeholder","Placeholder"]
    let indicator:[UIImage]=[#imageLiteral(resourceName: "Measure"),#imageLiteral(resourceName: "Measure"),#imageLiteral(resourceName: "Measure")]
    let cellTitle:[String] = ["Pacing","Filler Words","Intonation"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultCollectionView.delegate = self
        resultCollectionView.dataSource = self
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

