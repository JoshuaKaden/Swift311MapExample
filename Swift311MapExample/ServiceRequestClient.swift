//
//  ServiceRequestClient.swift
//  Swift311MapExample
//
//  Created by Kaden, Joshua on 12/14/17.
//  Copyright © 2017 NYC DoITT. All rights reserved.
//

import Foundation

class ServiceRequestClient {
    
    /**
     Obtains 311 data in a circle around a latitude and longitude, and passes an array of ServiceRequest objects to the completion closure.
     
     - Parameter latitude: The latitude of the circle's center
     - Parameter longitude: The longitude of the circle's center
     - Parameter withinCircle: The radius of the circle in meters
     */
    func getServiceRequests(latitude: Double, longitude: Double, withinCircle: Int, completion: @escaping ([ServiceRequest]) -> Void) {
        // Build the URL.
        guard let url = buildURL(latitude: latitude, longitude: longitude, withinCircle: withinCircle) else {
            print("invalid URL")
            completion([])
            return
        }
        
        // Load up the data, decode it, and pass it to the completion closure.
        obtainData(url: url) {
            [weak self]
            data in
            
            guard
                let data = data,
                let serviceRequests = self?.decode(data: data)
            else {
                completion([])
                return
            }
            
            completion(serviceRequests)
        }
    }
    
    /**
     Builds a URL that can be used to obtain 311 data in a circle around a latitude and longitude.
     
     This URL uses the [SODA](https://dev.socrata.com/docs/queries/ "Queries using SODA") function [within_circle](https://dev.socrata.com/docs/functions/within_circle.html "within_circle(...)").
     
     The finished URL string will resemble:
     
     `https://data.cityofnewyork.us/resource/erm2-nwe9.json?$where=within_circle(location,40.759211,-73.984638,353) and created_date > '2017-12-07'`
     
     - Parameter latitude: The latitude of the circle's center
     - Parameter longitude: The longitude of the circle's center
     - Parameter withinCircle: The radius of the circle in meters
     */
    private func buildURL(latitude: Double, longitude: Double, withinCircle: Int) -> URL? {
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
        return components.url
    }
    
    private func obtainData(url: URL, completion: @escaping (Data?) -> Void) {
        let urlRequest = URLRequest(url: url)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard
                let data = data,
                error == nil
            else {
                print("Error: did not receive data")
                completion(nil)
                return
            }
            
            completion(data)
        }
        task.resume()
    }
    
    private func decode(data: Data) -> [ServiceRequest]? {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([ServiceRequest].self, from: data)
        } catch {
            print("error trying to convert data to JSON")
            print(error)
            return nil
        }
    }
}
