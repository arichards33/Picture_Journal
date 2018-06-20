//
//  SaveEntries.swift
//  Picture Journal
//
//  Created by Alex Richards on 4/28/18.
//  Copyright © 2018 Alex Richards. All rights reserved.
//

import Foundation
import CloudKit

class SaveEntries {
    
    static let shared = SaveEntries()
    var oldEntries = NSMutableArray()
    let localFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("pictureJournalEntry")
    

    func checkForFile() -> Bool {
        var isFile: Bool = false
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let pathComponent = url.appendingPathComponent("pictureJournalEntry")
        if FileManager.default.fileExists(atPath: (pathComponent?.path)!) {
           isFile = true
        }
        return isFile
    }
    
    func writeToFile(entry: Data){
        print("FILE PATH: \(localFile)")
        if NSMutableArray(contentsOf: localFile) != nil {
            oldEntries = NSMutableArray(contentsOf: localFile)!
    
            do {
                try FileManager.default.removeItem(at: localFile)
                print("FILE REMOVED")
            } catch let error as NSError {
                print(error)
            }
        }
     
        oldEntries.add(entry)
        oldEntries.write(to: localFile, atomically: true)
    }
    
    func readFromFile() -> NSMutableArray {
        let readEntries = NSMutableArray(contentsOf: localFile)
        return readEntries!
    }
    
    func editEntry(entry: Entry) {
        oldEntries = NSMutableArray(contentsOf: localFile)!
        do {
            try FileManager.default.removeItem(at: localFile)
            print("FILE REMOVED")
        } catch let error as NSError {
            print(error)
        }
        print("START COUNT: \(oldEntries.count)")
        oldEntries.removeObject(at: entry.arrayIndex!)
        print("NEW COUNT: \(oldEntries.count)")
        oldEntries.write(to: localFile, atomically: true)
    }
    
    func searchEntries(){
        
    }

}
