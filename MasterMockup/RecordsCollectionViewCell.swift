//
//  RecordsCollectionViewCell.swift
//  MasterMockup
//
//  Created by Jesse Joseph on 12/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import UIKit

class RecordsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellImage: UIImageView!
    
    func setUI(image:UIImage){
        cellImage.image = image
    }
    
}
