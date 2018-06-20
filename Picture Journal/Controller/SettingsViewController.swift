//
//  SettingsViewController.swift
//  Picture Journal
//
//  Created by Alex Richards on 4/27/18.
//  Copyright © 2018 Alex Richards. All rights reserved.
//

import UIKit
import CloudKit

class SettingsViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var syncData: UIButton!
    
    //MARK: - Properties
    let container: CKContainer = CKContainer.default()
    
    var userRecordID: CKRecordID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        getUserName()
    }
    
    //MARK: - User Data
    func getUserName() {
        loggedInUser()
        container.requestApplicationPermission(.userDiscoverability) { (status, error) in
            guard status == .granted, error == nil else {
                print("here")
                DispatchQueue.main.async {
                    self.name.text = "NOT AUTHORIZED"
                }
                return
            }
            
            // Get the user name
            self.container.discoverUserIdentity(withUserRecordID: self.userRecordID!, completionHandler: {
                (userID, error) in
                let userName = (userID?.nameComponents?.givenName)! + " " + (userID?.nameComponents?.familyName)!
                print("CK User Name: " + userName)
                DispatchQueue.main.async {
                    self.name.text = userName
                }
            })
        }
    }
    
    func loggedInUser(){
        container.fetchUserRecordID() {
            recordID, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if let recordID = recordID {
                    self.userRecordID = recordID
                }
            }
        }
    }
    
    //MARK: - Button Actions
    @IBAction func syncData(_ sender: UIButton) {
        let ckManager = CloudKitManager.shared
        ckManager.syncEntries()
        
    }
    
}
