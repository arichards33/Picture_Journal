//
//  Entry.swift
//  Picture Journal
//
//  Created by Alex Richards on 4/28/18.
//  Copyright © 2018 Alex Richards. All rights reserved.
//

import Foundation


struct Entry: Codable {
    var photoURL: String?
//    var photo: UIImage?
    var date: Date?
    var lat: Double?
    var long: Double?
    var text: String?
    var tags: String?
    var arrayIndex: Int?
    var currentTemp: Int?
    var uuid = UUID()
}

struct ImageSaved: Codable {
    var imageData: Data?
}
