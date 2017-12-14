//
//  MainViewController.swift
//  Swift311MapExample
//
//  Created by Kaden, Joshua on 12/14/17.
//  Copyright © 2017 NYC DoITT. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    private let client = ServiceRequestClient()
    private let defaultLatitude: Double = 40.759211
    private let defaultLongitude: Double = -73.984638
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        client.getServiceRequests(latitude: defaultLatitude, longitude: defaultLongitude, withinCircle: 350) {
            serviceRequests in
            serviceRequests.map { print($0) }
        }
    }
}
