//
//  BuildingTableViewController.swift
//  CampusWalk
//
//  Created by Watson Li on 10/16/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit

protocol BuildingDelegate {
    func didChoose(building: Building)
}

class BuildingTableViewController: UITableViewController, InfoDelegate {
    
    let mapModel = MapModel.sharedInstance
    var delegate : BuildingDelegate?
    var showFavourite = false
    var completionBlock : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName:"TableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier:"CustomHeaderView")
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return mapModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapModel.numberOfRows(inSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuildingCell", for: indexPath)
        cell.textLabel?.text = mapModel.nameOfBuilding(atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomHeaderView") as! TableHeaderView
        headerView.sectionTitle.text = mapModel.titleFor(section: section)
        headerView.sectionTitle.textColor = UIColor.white
        headerView.contentView.backgroundColor = UIColor.darkGray
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if showFavourite{
            return 0
        }
        return 30.0
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return mapModel.sectionIndexTitles
    }
    
    @IBAction func toggleFavourite(_ sender: UIBarButtonItem) {
        showFavourite = !showFavourite
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if showFavourite{
            if !mapModel.buildingFor(indexPath: indexPath).favourite{
                return 0
            }
        }
        return 44.0
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var infoViewController : InfoViewController?
        
        switch segue.identifier! {
        case "InfoSegue":
            infoViewController = segue.destination as? InfoViewController
            
            let indexPath = tableView.indexPathForSelectedRow!
            let title = mapModel.nameOfBuilding(atIndexPath: indexPath)
            let image = mapModel.imageOfBuilding(atIndexPath: indexPath)
            infoViewController?.configureInfo(name: title, image: image)
            infoViewController?.delegate = self
        default:
            assert(false, "Unhandled Segue")
        }
    }
    
    //Mark Info delegate
    func okClicked() {
        let indexPath = tableView.indexPathForSelectedRow!
        if let delegate = delegate {
            delegate.didChoose(building: mapModel.buildingFor(indexPath: indexPath))
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        if let completionBlock = completionBlock {
            completionBlock()
        }
    }

}
