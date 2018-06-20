//
//  TempData.swift
//  Picture Journal
//
//  Created by Alex Richards on 5/1/18.
//  Copyright © 2018 Alex Richards. All rights reserved.
//

import Foundation

struct Weather: Codable {
    var currently: Items?

}

struct Items: Codable {
    var temperature: Double?
}
