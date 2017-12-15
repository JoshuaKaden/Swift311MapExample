//
//  ServiceRequestPin.swift
//  Swift311MapExample
//
//  Created by Kaden, Joshua on 12/15/17.
//  Copyright © 2017 NYC DoITT. All rights reserved.
//

import MapKit

class ServiceRequestPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var subtitle: String? { return serviceRequest.subtitle }
    var title: String? { return serviceRequest.title }

    let serviceRequest: ServiceRequest
    
    var pinTintColor: UIColor {
        switch serviceRequest.status {
        case "Open":
            return .green
        case "Assigned", "Pending":
            return .purple
        case "Closed":
            return .red
        default:
            return .darkGray
        }
    }
    
    init?(serviceRequest: ServiceRequest) {
        self.serviceRequest = serviceRequest
    
        guard
            let latitude = Double(serviceRequest.latitudeString),
            let longitude = Double(serviceRequest.longitudeString)
        else {
            return nil
        }
        
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
