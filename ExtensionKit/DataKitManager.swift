//
//  DataKitManager.swift
//  ExtensionKit
//
//  Created by Alex Richards on 5/1/18.
//  Copyright © 2018 Alex Richards. All rights reserved.
//

import Foundation
import CloudKit

/// To enable extension data sharing, we need to use an app group
let sharedAppGroup: String = "group.PictureJournal"

/// The key for our defaults storage
let favoritesKey: String = "Favorites"

//
// MARK: - DataKitManagerProtocol
//


/// A protocol that all our data storage methods will conform to so that we can
/// use a consistent API when accessing our data
protocol DataKitManager {
    func add(object anObject: NSObject)
    func reset()
    func currentList() -> NSMutableArray
}


//
// MARK: - Local DefaultsManager
//


/// Store NSUserDefaults in local defaults in app group suite;  Use
/// a singleton so that we can easily access the data across different
/// extension points
public class LocalDefaultsManager: DataKitManager {
    
    public static let sharedInstance = LocalDefaultsManager()
    let sharedDefaults: UserDefaults?
    var favorites: NSMutableArray?
    
    init() {
        sharedDefaults = UserDefaults(suiteName: sharedAppGroup)
        //print(sharedDefaults?.dictionaryRepresentation() as Any)
    }
    
    public func add(object anObject: NSObject) {
        let current: NSMutableArray = currentList()
        current.add(anObject)
        sharedDefaults?.set(current, forKey: favoritesKey)
        sharedDefaults?.synchronize()
        //print(currentList())
    }
    
    public func currentList() -> NSMutableArray {
        var current: NSMutableArray = []
        if let tempNames: NSArray = sharedDefaults?.array(forKey: favoritesKey) as NSArray? {
            current = tempNames.mutableCopy() as! NSMutableArray
        }
        return current
    }
    
    public func reset() {
        sharedDefaults?.set(NSMutableArray(), forKey: favoritesKey)
        sharedDefaults?.synchronize()
    }
}



