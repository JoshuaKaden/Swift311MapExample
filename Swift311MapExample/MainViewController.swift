//
//  MainViewController.swift
//  Swift311MapExample
//
//  Created by Kaden, Joshua on 12/14/17.
//  Copyright © 2017 NYC DoITT. All rights reserved.
//

import UIKit
import MapKit

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

    private lazy var arViewController: ARViewController = {
        guard let arViewController = viewControllers?[2] as? ARViewController else {
            assertionFailure("Unexpected view controller hierarchy")
            return ARViewController()
        }
        return arViewController
    }()
    
    private let client = ServiceRequestClient()
    private let locationManager = CLLocationManager()
    fileprivate var userLocation: CLLocation?
    fileprivate var withinCircle: Int = 400
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapViewController.delegate = self
        arViewController.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.requestWhenInUseAuthorization()
    }
    
    fileprivate func loadData(latitude: Double, longitude: Double, withinCircle: Int) {
        client.getServiceRequests(latitude: latitude, longitude: longitude, withinCircle: withinCircle) {
            serviceRequests in
            self.mapViewController.serviceRequests = serviceRequests
            self.listViewController.serviceRequests = serviceRequests
            if self.arViewController.isViewLoaded {
                self.arViewController.serviceRequests = serviceRequests
            }
        }
    }
}

// MARK: - ARViewControllerDelegate

extension MainViewController: ARViewControllerDelegate {
    func requestData() {
        guard let userLocation = userLocation else { return }
        let latitude = Double(userLocation.coordinate.latitude)
        let longitude = Double(userLocation.coordinate.longitude)
        loadData(latitude: latitude, longitude: longitude, withinCircle: withinCircle)
    }
}

// MARK: - CLLocationManagerDelegate

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Implementing this method is required
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation = location
            mapViewController.userLocation = userLocation
            arViewController.userLocation = userLocation
        }
    }
}

extension MainViewController: MapViewControllerDelegate {
    func didChangeRegion(latitude: Double, longitude: Double, withinCircle: Int) {
        if withinCircle <= 1000 {
            self.withinCircle = withinCircle
        } else {
            self.withinCircle = 1000
        }
        loadData(latitude: latitude, longitude: longitude, withinCircle: self.withinCircle)
    }
}
