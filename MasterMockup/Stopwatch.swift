//
//  Stopwatch.swift
//  MasterMockup
//
//  Created by Tommy Rachmat on 17/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import Foundation

class Stopwatch {
    private var startTime : NSDate?
    private var current : TimeInterval = 0
    private var pauseTime : TimeInterval = 0
    var elapsedTime: TimeInterval{
        if let startTime = self.startTime{
            return -startTime.timeIntervalSinceNow - current
        }
        else {
            return 0
        }
    }
    
    var isRunning: Bool{
        return startTime != nil
    }
        
    func start() {
        startTime = NSDate()
    }
        
    func stop() {
        startTime = nil
    }
    
    func pause() {
        pauseTime = startTime!.timeIntervalSinceNow + current
        current = 0
    }
    
    func resume() {
        startTime = nil
        startTime = NSDate()
        current = pauseTime
    }
    
}
