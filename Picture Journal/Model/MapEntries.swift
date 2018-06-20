//
//  MapEntries.swift
//  Picture Journal
//
//  Created by Alex Richards on 5/2/18.
//  Copyright © 2018 Alex Richards. All rights reserved.
//

import Foundation
import MapKit


public final class MapEntries: NSObject, MKAnnotation, Codable {
  
    public let coordinate: CLLocationCoordinate2D
    public var title: String?
    
    
    //  MARK: Initialization
    public init(coordinate: CLLocationCoordinate2D, title: String) {
        self.title = title
        self.coordinate = coordinate
    }
}

//  MARK: CLLocationCoordinate2D + Codable
extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(latitude)
        try container.encode(longitude)
    }
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.init()
        latitude = try container.decode(Double.self)
        longitude = try container.decode(Double.self)
    }
}
