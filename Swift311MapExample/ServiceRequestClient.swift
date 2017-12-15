//
//  ServiceRequestClient.swift
//  Swift311MapExample
//
//  Created by Kaden, Joshua on 12/14/17.
//  Copyright © 2017 NYC DoITT. All rights reserved.
//

import Foundation

class ServiceRequestClient {
    private var isLoading: Bool = false
    
    func getServiceRequests(latitude: Double, longitude: Double, withinCircle: Int, completion: @escaping ([ServiceRequest]) -> Void) {
        if isLoading { return }
        isLoading = true
        
        // example url:
        // https://data.cityofnewyork.us/resource/erm2-nwe9.json?$where=within_circle(location,40.759211,-73.984638,353)%20and%20created_date%20%3E%20%272017-12-07%27
        
        // Convert values to formatted strings
        let latitudeString = String(format:"%f", latitude)
        let longitudeString = String(format:"%f", longitude)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        // (one week = 604,800 seconds)
        let dateString = dateFormatter.string(from: Date.init(timeIntervalSinceNow: -604_800))
        let whereClause = "within_circle(location,\(latitudeString),\(longitudeString),\(withinCircle)) and created_date > '\(dateString)'"

        // Build the url
        var components = URLComponents()
        components.scheme = "https"
        components.host = "data.cityofnewyork.us"
        components.path = "/resource/erm2-nwe9.json"
        components.queryItems = [URLQueryItem(name: "$where", value: whereClause)]
        guard let url = components.url else {
            print("invalid URL")
            completion([])
            return
        }
        
        // Load up the data and pass it to the completion closure.
        performTask(url: url) {
            serviceRequests in
            completion(serviceRequests)
            self.isLoading = false
        }
    }
    
    private func performTask(url: URL, completion: @escaping ([ServiceRequest]) -> Void) {
        let urlRequest = URLRequest(url: url)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard let responseData = data else {
                print("Error: did not receive data")
                completion([])
                return
            }
            guard error == nil else {
                print(error.debugDescription)
                completion([])
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let serviceRequests = try decoder.decode([ServiceRequest].self, from: responseData)
                completion(serviceRequests)
            } catch {
                print("error trying to convert data to JSON")
                print(error)
                completion([])
            }
        }
        task.resume()
    }
}
