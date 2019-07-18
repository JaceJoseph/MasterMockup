//
//  OpenRecordingViewController.swift
//  MasterMockup
//
//  Created by Jesse Joseph on 15/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import UIKit

class OpenRecordingViewController: UIViewController {
    @IBOutlet weak var resultPageControl: UIPageControl!
    @IBOutlet weak var resultCollectionView: UICollectionView!
    
    let image:UIImage = #imageLiteral(resourceName: "SiKaset")
    let comments:[String]=["SomePlaceholder","SomePlaceholder"]
    let result:[String]=["Placeholder","Placeholder"]
    let indicator:[UIImage]=[#imageLiteral(resourceName: "Measure"),#imageLiteral(resourceName: "Measure")]
    let cellTitle:[String] = ["Pacing","Filler Words",]

    override func viewDidLoad() {
        resultPageControl.numberOfPages = 2
        resultCollectionView.delegate = self
        resultCollectionView.dataSource = self
        
        resultCollectionView.layer.borderWidth = 1
        resultCollectionView.layer.borderColor = UIColor.black.cgColor
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
