//
//  UIImage+ServiceRequest.swift
//  ThreeOneOne
//
//  Created by Kaden, Joshua on 12/7/15.
//  Copyright © 2015 NYC DoITT. All rights reserved.
//

import UIKit

extension UIImage {
    enum ServiceRequestIconName: String {
        // Image names of icons for a Service Request
        case
        AbandonedVehicle,
        BuildingGraffiti,
        DamagedTree,
        DirtyVacantLot,
        Driveway,
        FireHydrant,
        FoodPoisoning,
        HeatHotWater,
        HomelessAssistance,
        IllegalParking,
        MuniMeter,
        NewTree,
        Noise,
        ParksAndRecreation,
        RatCondition,
        Restaurant,
        Sidewalk,
        SnowOnRoadway,
        SnowOnSidewalk,
        Streetlight,
        StreetPothole,
        StreetSign,
        TaxiDriver,
        TaxiLostProperty,
        TrafficLight,
        Unknown
    }
    
    convenience init!(serviceRequestIconName: ServiceRequestIconName) {
        self.init(named: serviceRequestIconName.rawValue)
    }
    
    convenience init!(complaintType: String) {
        let serviceRequestIconName: ServiceRequestIconName
        switch complaintType {
        case "Derelict Vehicle":
            serviceRequestIconName = .AbandonedVehicle
        case "buildingGraffiti":
            serviceRequestIconName = .BuildingGraffiti
        case "damagedTree":
            serviceRequestIconName = .DamagedTree
        case "Dirty Conditions", "Request Large Bulky Item Collection", "Sanitation Condition":
            serviceRequestIconName = .DirtyVacantLot
        case "driveway":
            serviceRequestIconName = .Driveway
        case "fireHydrant":
            serviceRequestIconName = .FireHydrant
        case "foodPoisoning":
            serviceRequestIconName = .FoodPoisoning
        case "heatOrHotWater":
            serviceRequestIconName = .HeatHotWater
        case "homelessAssistance":
            serviceRequestIconName = .HomelessAssistance
        case "Illegal Parking":
            serviceRequestIconName = .IllegalParking
        case "muniMeter":
            serviceRequestIconName = .MuniMeter
        case "newTree":
            serviceRequestIconName = .NewTree
        case "Noise", "Noise - Residential", "Noise - Street/Sidewalk", "Noise - Commercial":
            serviceRequestIconName = .Noise
        case "parksAndRecreation":
            serviceRequestIconName = .ParksAndRecreation
        case "Rodent":
            serviceRequestIconName = .RatCondition
        case "restaurant":
            serviceRequestIconName = .Restaurant
        case "sidewalk":
            serviceRequestIconName = .Sidewalk
        case "snowOnRoadway":
            serviceRequestIconName = .SnowOnRoadway
        case "snowOnSidewalk":
            serviceRequestIconName = .SnowOnSidewalk
        case "Street Light Condition":
            serviceRequestIconName = .Streetlight
        case "Street Condition", "Highway Condition":
            serviceRequestIconName = .StreetPothole
        case "Street Sign - Missing":
            serviceRequestIconName = .StreetSign
        case "taxiDriver":
            serviceRequestIconName = .TaxiDriver
        case "taxiLostProperty":
            serviceRequestIconName = .TaxiLostProperty
        case "trafficLight":
            serviceRequestIconName = .TrafficLight
        default:
            serviceRequestIconName = .Unknown
        }
        
        self.init(serviceRequestIconName: serviceRequestIconName)
    }
}
