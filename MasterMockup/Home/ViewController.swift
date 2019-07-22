//
//  ViewController.swift
//  MasterMockup
//
//  Created by Jesse Joseph on 12/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let dummyArray:[UIImage] = [#imageLiteral(resourceName: "cassette"),#imageLiteral(resourceName: "cassette copy 3"),#imageLiteral(resourceName: "cassette copy"),#imageLiteral(resourceName: "cassette copy 2"),#imageLiteral(resourceName: "cassette copy 4"),#imageLiteral(resourceName: "cassettewhite")]
    let dummyFavTitle:[String]=["Recording 1","Recording 2","Recording3"]
    let dummyFavSubtitle:[String]=["Subtitle 1","Subtitle2","Subtitle3"]
    
    // Variable Penampung untuk record dari ResultTableViewController
    var recordTitle: [String] = []

    
    @IBOutlet weak var recordsTableView: UITableView!
    
    override func viewDidLoad() {
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
        if dummyFavTitle.isEmpty == false{
            return dummyFavTitle.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var row:[String] = []
        if dummyFavTitle.isEmpty == false{
            row.append(contentsOf: [dummyFavTitle[indexPath.row],dummyFavSubtitle[indexPath.row]])
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "resultSegue", sender: self)
        
        // create the alert
        let alert = UIAlertController(title: "Announcement", message: "This feature is still under development", preferredStyle: UIAlertController.Style.alert)
        
        // Add action
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // Show the alert
        self.present(alert,animated: true, completion: nil)
    }
    
    // Function to append
    func add(name: String) {
        recordTitle.append(name)
    }
    
}
