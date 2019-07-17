//
//  AllRecordViewController.swift
//  MasterMockup
//
//  Created by Jesse Joseph on 15/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import UIKit

class AllRecordViewController: UIViewController {

    var numberOfAllRecords: Int = 0
    var listOfRecording = [String]()
    
    @IBOutlet weak var allRecordTableView: UITableView!
    let dummyTitle = ["Title1","Title2"]
    let dummySubtitle = ["Subtitle1","Subtitle2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allRecordTableView.delegate = self
        allRecordTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    // Fungsi untuk menambah record yang akan di gunakan di 
    func addRecord(name: String) {
        listOfRecording.append(name)
    }

}

extension AllRecordViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selector = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "allRecordsCell") as! RecordListTableViewCell
        
        cell.setUI(title: dummyTitle[selector], subtitle: dummySubtitle[selector])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "allRecordsToResult", sender: self)
    }
}
