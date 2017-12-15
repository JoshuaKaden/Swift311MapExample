//
//  DetailViewController.swift
//  Swift311MapExample
//
//  Created by Kaden, Joshua on 12/15/17.
//  Copyright © 2017 NYC DoITT. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    var serviceRequest: ServiceRequest?
    
    private let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.font = UIFont.systemFont(ofSize: 18)
        if let serviceRequest = serviceRequest {
            textView.text = render(serviceRequest: serviceRequest)
        }
        view.addSubview(textView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.frame = view.bounds
    }
    
    private func render(serviceRequest: ServiceRequest) -> String {
        var string = "Complaint Type:\n" + serviceRequest.complaintType + "\n\n"
        if let incidentAddress = serviceRequest.incidentAddress {
            string += "Incident Address:\n" + incidentAddress + "\n\n"
        }
        string += "Created:\n" + serviceRequest.createdDateString + "\n\n"
        string += "Status:\n" + serviceRequest.status + "\n\n"
        if let resolution = serviceRequest.resolutionDescription {
            string += "Resolution:\n" + resolution + "\n\n"
        }
        return string
    }
}
