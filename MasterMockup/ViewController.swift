//
//  ViewController.swift
//  MasterMockup
//
//  Created by Jesse Joseph on 12/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let dummyArray:[UIImage] = [#imageLiteral(resourceName: "VinylA"),#imageLiteral(resourceName: "VinylC"),#imageLiteral(resourceName: "VinylD"),#imageLiteral(resourceName: "VinylB")]
    let dummyTitle:[String]=["Recording 1","Recording 2"]
    let dummySubtitle:[String]=["Subtitle 1","Subtitle2"]

    @IBOutlet weak var recordsPageDot: UIPageControl!
    @IBOutlet weak var recordsCollectionView: UICollectionView!
    @IBOutlet weak var recordsTableView: UITableView!
    
    override func viewDidLoad() {
        recordsPageDot.numberOfPages = dummyArray.count
        recordsCollectionView.delegate = self
        recordsCollectionView.dataSource = self
        
        recordsTableView.delegate = self
        recordsTableView.dataSource = self
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }

}

extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if dummyArray.isEmpty == true{
            return 1
        }else{
            return dummyArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row:UIImage
        
        if dummyArray.isEmpty == false{
            row = dummyArray[indexPath.row]
        }else{
            row = #imageLiteral(resourceName: "Vinyl Only")
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recordsCell", for: indexPath) as! RecordsCollectionViewCell
        cell.setUI(image: row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.recordsPageDot.currentPage = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "resultSegue", sender: self)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameSize = collectionView.frame.size
        return CGSize(width: frameSize.width - 10, height: frameSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dummyTitle.isEmpty == false{
            return dummyTitle.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var row:[String] = []
        if dummyTitle.isEmpty == false{
            row.append(contentsOf: [dummyTitle[indexPath.row],dummySubtitle[indexPath.row]])
        }else{
            row.append(contentsOf: ["There is no recoding","-"])
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordsListCell") as! RecordListTableViewCell
        
        cell.setUI(title: row[0], subtitle: row[1])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "resultSegue", sender: self)
    }
    
}
