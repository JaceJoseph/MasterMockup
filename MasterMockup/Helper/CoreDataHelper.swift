//
//  CoreDataHelper.swift
//  MasterMockup
//
//  Created by michael gunawan on 18/07/19.
//  Copyright © 2019 Jesse Joseph. All rights reserved.
//

import Foundation
import CoreData
class CoreDataHelper{
    var dicts: [NSManagedObject] = []
    var res: [NSManagedObject] = []
    var appDelegate: AppDelegate!
    var managedContext : NSManagedObjectContext!
    init(appDelegate:AppDelegate?) {
        self.appDelegate = appDelegate
        self.managedContext =
            appDelegate?.persistentContainer.viewContext
    }
    func insertData(data:RecordingStruct)->Bool{
        do{
            let entity =
                NSEntityDescription.entity(forEntityName: "Recording",
                                           in: managedContext)!
            
            let dicc = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
            dicc.setValue("\(data.fillerWords)", forKeyPath: "fillerWords")
            dicc.setValue("\(data.recordingName)", forKey: "recordingName")
            dicc.setValue(data.averageWPM, forKey: "averageWPM")
            do {
                try managedContext.save()
                dicts.append(dicc)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                return false
            }
            return true
        }catch{
            return false
        }
    }
    
    func getData(recordingName:String)->RecordingStruct?{
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Recording")
        fetchRequest.predicate = NSPredicate(format: "recordingName == %@", recordingName)
        do {
            res = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
        let fillerwords = res.first?.value(forKey: "fillerWords") as! String
        let name = res.first?.value(forKey: "recordingName") as! String
        let wpm = res.first?.value(forKey: "averageWPM") as! Double
        let stringToParse = fillerwords.replacingOccurrences(of: "[", with: "{").replacingOccurrences(of: "]", with: "}")
        if stringToParse != "{:}"{
            let dict = convertToDictionary(text: stringToParse)
            return RecordingStruct(averageWPM: wpm, recordingName: name, fillerWords: dict!)
        }else{
            return RecordingStruct(averageWPM: wpm, recordingName: name, fillerWords: [String:Int]())
        }
    }
    
    func convertToDictionary(text: String) -> [String: Int]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Int]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
