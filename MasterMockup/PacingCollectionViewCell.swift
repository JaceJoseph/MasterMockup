//
//  PacingCollectionViewCell.swift
//  MasterMockup
//
//  Created by Jesse Joseph on 15/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import UIKit

class PacingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pacingLabelTitle: UILabel!
    @IBOutlet weak var pacingImage: UIImageView!
    @IBOutlet weak var pacingComments: UILabel!
    @IBOutlet weak var pacingResults: UILabel!
    @IBOutlet weak var pacingIndicator: UIImageView!
    
    func setCell(title:String, image:UIImage, comment:String,result:String,indicator:UIImage) {
        pacingLabelTitle.text = title
        pacingImage.image = image
        pacingComments.text = comment
        pacingResults.text = "Your Result: \(result)"
        pacingIndicator.image = indicator
        
    }
}
