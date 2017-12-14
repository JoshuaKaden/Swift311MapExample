//
//  ServiceRequest.swift
//  Swift311MapExample
//
//  Created by Kaden, Joshua on 12/14/17.
//  Copyright © 2017 NYC DoITT. All rights reserved.
//

import Foundation

struct ServiceRequest: Codable {
    let complaintType: String
    let incidentAddress: String?
    let createdDateString: String
    let status: String
    let resolutionDescription: String
    let latitudeString: String
    let longitudeString: String
    
    private enum CodingKeys : String, CodingKey {
        case complaintType = "complaint_type"
        case incidentAddress = "incident_address"
        case createdDateString = "created_date"
        case status
        case resolutionDescription = "resolution_description"
        case latitudeString = "latitude"
        case longitudeString = "longitude"
    }
}
