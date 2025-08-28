//
//  Item.swift
//  iosda-c6-frontend
//
//  Created by Kevin Christian on 28/08/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
