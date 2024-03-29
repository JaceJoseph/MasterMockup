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
    var timeLabelOfRecording = [String]()
    
    @IBOutlet weak var allRecordTableView: UITableView!
    let dummyTitle = ["Title1","Title2"]
    let dummySubtitle = ["Subtitle1","Subtitle2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allRecordTableView.delegate = self
        allRecordTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        // USER DEFAULT (SUDAH DI SAVE DARI ResultFromRecordViewController
        let defaults = UserDefaults.standard
        listOfRecording = defaults.object(forKey:"nameArray") as? [String] ?? [String]()
        timeLabelOfRecording = defaults.object(forKey: "timeArray") as? [String] ?? [String]()
        
        
        print("ALL RECORD LOADED")
        
        // TODO: DEBUGGING SAJA, NANTI DI DELETE BAGIAN INI
        for _ in listOfRecording {
            print(listOfRecording)
        }
        
        self.allRecordTableView.reloadData()
    }
    
    // Fungsi untuk menambah record yang akan di gunakan di ResultFromRecordingViewController
    func addRecord(name: String) {
        listOfRecording.append(name)
        
        print("Appended !!!!!!")
    }
    
    func addTimeRecord(time: String) {
        timeLabelOfRecording.append(time)
    }

}

extension AllRecordViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfRecording.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let selector = indexPath.row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "allRecordsCell")
        
        let listRecordingName = cell!.contentView.viewWithTag(70) as! UILabel
        let listRecordingSubName = cell?.contentView.viewWithTag(71) as! UILabel
        
        listRecordingName.text = listOfRecording[indexPath.row]
        print(indexPath.row)
        print(listOfRecording)
        print(timeLabelOfRecording)
        listRecordingSubName.text = timeLabelOfRecording[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        numberOfAllRecords = indexPath.row + 1
        performSegue(withIdentifier: "allRecordsToResult", sender: self)
        
        print("You select row \(numberOfAllRecords), Tryin to open recording\(numberOfAllRecords).m4a")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allRecordsToResult"{
            guard let result = segue.destination as? OpenRecordingViewController else {return}
            result.numberOfRecordingThatWillBeOpened = numberOfAllRecords
            
        }
    }
    
}
