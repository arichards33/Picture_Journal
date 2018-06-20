//
//  CloudKitManager.swift
//  Picture Journal
//
//  Created by Alex Richards on 4/26/18.
//  Copyright © 2018 Alex Richards. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

open class CloudKitManager {
    
    //MARK: - Properties
    open static let shared = CloudKitManager()
    
    let container: CKContainer = CKContainer.default()
    let publicDB: CKDatabase = CKContainer.default().publicCloudDatabase
    let privateDB: CKDatabase = CKContainer.default().privateCloudDatabase
    
    var userRecordID: CKRecordID?
    var entriesReturned: NSMutableArray?
    
    private init(){}
    
    open func getUserRecordID(complete: @escaping (CKRecordID?, NSError?) -> ()) {
        container.fetchUserRecordID(){
            recordID, error in
            
            if error != nil {
                print("Manager: \(error!.localizedDescription)")
                complete(nil, error as NSError?)
            } else {
                print("got record: \(recordID?.recordName ?? "")")
                complete(recordID, nil)
            }
        }
    }
    
    open func getRecordID(complete: @escaping (CKRecordID?, NSError?) -> ()) {
        container.fetchUserRecordID(){
            recordID, error in
            
            if error != nil {
                print("Manager: \(error!.localizedDescription)")
                complete(nil, error as NSError?)
            } else {
                print("got record: \(recordID?.recordName ?? "")")
                complete(recordID, nil)
            }
        }
    }
    
    open func getUserIdentity(complete: @escaping (String?, NSError?) -> ()) {
        container.requestApplicationPermission(.userDiscoverability) { (status, error) in
            if status == .denied, error == nil {
                complete("Not authorized", nil)
            }
            
            self.container.fetchUserRecordID {(record, error) in
                if error != nil{
                    print(error!.localizedDescription)
                    complete(nil, error as NSError?)
                } else {
                    self.container.discoverUserIdentity(withUserRecordID: record!, completionHandler: { (userID, error) in
                        let userName = (userID?.nameComponents?.givenName)!  + " " + (userID?.nameComponents?.familyName)!
                        print ("CK User Name: \(userName)")
                        complete (userName, nil)
                    })
                }
            }
        }
    }
    
    func getEntries() {
        print("here")
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "Entry", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(entries, error) -> Void in
            if let error = error {
                print("Error"  + error.localizedDescription)
                return
            }
            for entry in entries! {
                print(entry)
                self.entriesReturned?.add(entry)
            }
        })
    }
    

    func saveEntry(entry: Entry) {
        let record = CKRecord(recordType: "Entry")
        record.setValue(entry.text, forKey: "text")
        record.setValue(entry.lat, forKey: "latitude")
        record.setValue(entry.long, forKey: "longitude")
        record.setValue(entry.tags, forKey: "tags")
        record.setValue(entry.currentTemp, forKey: "temp")
        record.setValue(entry.photoURL, forKey: "URL")
        record.setValue(entry.date, forKey: "date")
        
        
        
        let photoURL = URL(fileURLWithPath: entry.photoURL!)
        let photoData = try! Data(contentsOf: photoURL)
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp.jpg")
        try! photoData.write(to: tempURL, options: NSData.WritingOptions.atomicWrite)
        
        let photo = CKAsset(fileURL: tempURL)
        record.setValue(photo, forKey: "photoAsset")
        
        let ident = entry.uuid.description
        record.setValue(ident, forKey: "uuid")
        privateDB.save(record) { (record, error) in
            if let error = error {
                print(error)
                return
            }
       
            
            print(record.debugDescription)
            
            
            
            
        }
        
    }

    func deleteEntry(entry: CKRecord) {
        
        
        privateDB.delete(withRecordID: entry.recordID, completionHandler: {recordID, error in
            NSLog("OK or \(String(describing: error))")
        })
        
    }
    
    func getEntryByURL(entry: Entry){
        let predicate = NSPredicate(format: "photoURL == %@", entry.photoURL!)
        let query = CKQuery(recordType: "Entry", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) {(records, error) -> Void in
            if let error = error {
                print(error)
            }
            for record in records! {
            let record = record
                print(record["text"] as! String)
                
            }
        }
    }
    
    func syncEntries(){
        let localFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("pictureJournalEntry")
        getEntries()
        
        do {
            try FileManager.default.removeItem(at: localFile)
            print("FILE REMOVED")
        } catch let error as NSError {
            print(error)
        }
        
        entriesReturned?.write(to: localFile, atomically: true)
    }
    
    
    
    func registerSilentSubscriptionsWithIdentifier(_ identifier: String) {
       
        let notificationInfo = CKNotificationInfo()
        
        let subscription = CKQuerySubscription(recordType: "Entry",
                                               predicate: NSPredicate(value: true),
                                               subscriptionID: identifier,
                                               options: [.firesOnRecordCreation])
        subscription.notificationInfo = notificationInfo
        CKContainer.default().privateCloudDatabase.save(subscription, completionHandler: ({returnRecord, error in
            if let err = error {
                print("subscription failed \(err.localizedDescription)")
            } else {
                print("subscription set up")
            }
        }))
    }
    
    /// Register a generic Alert subscription so that we can send push notifications for
    /// free
    func registerSilentAlertSubscription() {
        let identifier = "alert"
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        
        let subscription = CKQuerySubscription(recordType: "Entry",
                                               predicate: NSPredicate(value: true),
                                               subscriptionID: identifier,
                                               options: [.firesOnRecordCreation])
        subscription.notificationInfo = notificationInfo
        CKContainer.default().privateCloudDatabase.save(subscription,
                                                       completionHandler: ({returnRecord, error in
                                                        if let err = error {
                                                            print("ALERT: subscription failed \(err.localizedDescription)")
                                                        } else {
                                                            print("ALERT: subscription set up")
                                                        }
                                                       }))
    }
    
    func registerSilentAlertSubscriptionDelete() {
        let identifier = "alert"
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        
        let subscription = CKQuerySubscription(recordType: "Entry",
                                               predicate: NSPredicate(value: true),
                                               subscriptionID: identifier,
                                               options: [.firesOnRecordDeletion])
        subscription.notificationInfo = notificationInfo
        CKContainer.default().privateCloudDatabase.save(subscription,
                                                        completionHandler: ({returnRecord, error in
                                                            if let err = error {
                                                                print("ALERT: subscription failed \(err.localizedDescription)")
                                                            } else {
                                                                print("ALERT: subscription set up")
                                                            }
                                                        }))
    }
    

    
    
    
    
    
}
