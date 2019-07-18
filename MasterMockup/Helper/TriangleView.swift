//
//  TriangleView.swift
//  MasterMockup
//
//  Created by michael gunawan on 18/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import UIKit

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
