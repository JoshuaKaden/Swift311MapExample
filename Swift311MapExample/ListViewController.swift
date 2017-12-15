//
//  ListViewController.swift
//  Swift311MapExample
//
//  Created by Kaden, Joshua on 12/14/17.
//  Copyright © 2017 NYC DoITT. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    var serviceRequests: [ServiceRequest]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        view.addSubview(tableView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

extension ListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let dequeued = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell = dequeued
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            cell.accessoryType = .disclosureIndicator
        }
        
        if let serviceRequests = serviceRequests {
            let serviceRequest = serviceRequests[indexPath.row]
            cell.textLabel?.text = serviceRequest.title
            cell.detailTextLabel?.text = serviceRequest.subtitle
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let serviceRequests = serviceRequests else { return 0 }
        return serviceRequests.count
    }
}
