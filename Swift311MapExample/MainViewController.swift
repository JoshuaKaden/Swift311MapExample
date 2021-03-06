//
//  MainViewController.swift
//  Swift311MapExample
//
//  Created by Kaden, Joshua on 12/14/17.
//  Copyright © 2017 NYC DoITT. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    private lazy var mapViewController: MapViewController = {
        guard
            let navigationController = viewControllers?[0] as? UINavigationController,
            let mapViewController = navigationController.topViewController as? MapViewController
        else {
            assertionFailure("Unexpected view controller hierarchy")
            return MapViewController()
        }
        return mapViewController
    }()
    
    private lazy var listViewController: ListViewController = {
        guard
            let navigationController = viewControllers?[1] as? UINavigationController,
            let listViewController = navigationController.topViewController as? ListViewController
        else {
            assertionFailure("Unexpected view controller hierarchy")
            return ListViewController()
        }
        return listViewController
    }()

    private let client = ServiceRequestClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewController.delegate = self
    }
}

extension MainViewController: MapViewControllerDelegate {
    func didChangeRegion(latitude: Double, longitude: Double, withinCircle: Int) {
        let maxxedCircle: Int
        if withinCircle > 750 {
            maxxedCircle = 750
        } else {
            maxxedCircle = withinCircle
        }
        client.getServiceRequests(latitude: latitude, longitude: longitude, withinCircle: maxxedCircle) {
            serviceRequests in
            self.mapViewController.serviceRequests = serviceRequests
            self.listViewController.serviceRequests = serviceRequests
        }
    }
}
