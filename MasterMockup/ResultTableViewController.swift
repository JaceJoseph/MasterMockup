//
//  ResultTableViewController.swift
//  MasterMockup
//
//  Created by Haris Shobaruddin Roabbni on 15/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import UIKit

class ResultTableViewController: UITableViewController {
    
    //wpm result
    var wpmValue: Double = 0
    var wpmResult: String = ""
    var WPMDescription: String = ""
    
    //filler word result
    var detectedFiller: Double = 0
    var fillerWordResult: String = ""
    var fillerWordDescription: String = ""
    
    //intonation result
    var intonationResult: String = ""
    var intonationDescription: String = ""
    
    // Pencatatan Number of Records (DATA INI TIDAK DITAMPILKAN DI SINI, PERANTARA KE HALAMAN AWAL)
    var numOfRecordsTemporary: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set Result Here
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 2
        } else if section == 1 {
            return 2
        }else{
            return 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dataVC = segue.destination as? ViewController else {return}
        dataVC.add(name: String(numOfRecordsTemporary))
        
    }

}
