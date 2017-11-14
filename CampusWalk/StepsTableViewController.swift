//
//  StepsTableViewController.swift
//  CampusWalk
//
//  Created by Watson Li on 10/23/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit

class StepsTableViewController: UITableViewController {

    var completionBlock : (() -> Void)?
    var directions = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        if let completionBlock = completionBlock {
            completionBlock()
        }
    }

    func configureInfo(forSteps steps: [String]) {
        self.directions = steps
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directions.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath)

        cell.textLabel?.text = directions[indexPath.row]
        return cell
    }

}
