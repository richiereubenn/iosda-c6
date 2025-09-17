//
//  AI.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 15/09/25.
//

import Foundation

struct ClassificationAI: Codable{
    let complaintDetail: String
    let classificationId: String
    
    private enum CodingKeys: String, CodingKey {
        case complaintDetail = "complaint_detail"
        case classificationId = "classification_id"
    }
}
