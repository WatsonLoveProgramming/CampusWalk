//
//  MapModel.swift
//  CampusWalk
//
//  Created by Watson Li on 10/16/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class Building : NSObject, MKAnnotation {
    let title : String?
    let photo : String?
    let coordinate : CLLocationCoordinate2D
    var favourite = false
    
    init(title: String, photo: String, coordinate:CLLocationCoordinate2D) {
        self.title = title
        self.photo = photo
        self.coordinate = coordinate
    }
    
    var mapItem : MKMapItem {
        get {let placeMark = MKPlacemark(coordinate: coordinate)
            return MKMapItem(placemark: placeMark) }
    }
    
}


struct BuildingKeys {
    static let name = "name"
    static let photo = "photo"
    static let latitude = "latitude"
    static let longitude = "longitude"
}

typealias BuildingData = [String:[Building]]
typealias BuildingImage = [String:UIImage]

class MapModel {
    
    static let sharedInstance = MapModel()
    fileprivate let buildings : BuildingData
    fileprivate let buildingKeys : [String]
    let allBuildings : [Building]
    var userImages : BuildingImage
    
    // Centered in downtown State College
    let initialLocation = CLLocation(latitude: 40.794978, longitude: -77.860785)
    
    fileprivate init() {
        userImages = BuildingImage()
        var _allBuildings = [Building]()
        var _buildings = BuildingData()

        let filepath = Bundle.main.path(forResource: "buildings", ofType: "plist")
        let contents  = NSArray(contentsOfFile: filepath!) as! [[String:Any]]
        
        for dictionary in contents {
            let coordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(dictionary[BuildingKeys.latitude]! as! CGFloat), longitude: CLLocationDegrees(dictionary[BuildingKeys.longitude]! as! CGFloat))
            let aBuilding =  Building.init(title: (dictionary[BuildingKeys.name]! as! String),
                                     photo: dictionary[BuildingKeys.photo]! as! String,
                                     coordinate: coordinate)
            _allBuildings.append(aBuilding)
            
            let firstLetter = aBuilding.title?.firstLetter()!
            if _buildings[firstLetter!]?.append(aBuilding) == nil {
                _buildings[firstLetter!] = [aBuilding]
            }
            
        }
        
        allBuildings = _allBuildings.sorted(by: { s1, s2 in s1.title! < s2.title! })
        
        buildings = _buildings
        buildingKeys =  Array(buildings.keys).sorted()
        
    }
        
    var numberOfBuildings : Int {get {return allBuildings.count}}
    
    var numberOfSections : Int {get {return buildingKeys.count}}
    
    var sectionIndexTitles : [String] {get {return buildingKeys}}

    func numberOfRows(inSection section:Int) -> Int {
        let key = buildingKeys[section]
        return (buildings[key]?.count)!
    }
    
    func buildingFor(indexPath:IndexPath) -> Building {
        let key = buildingKeys[indexPath.section]
        let buildingArray = buildings[key]!
        return buildingArray[indexPath.row]
    }
    
    func nameOfBuilding(atIndexPath indexPath:IndexPath) -> String {
        return buildingFor(indexPath: indexPath).title!
    }
    
    func titleFor(section:Int) -> String {
        return buildingKeys[section]
    }
    
    func imageOfBuilding(atIndexPath indexPath:IndexPath) -> UIImage {
        if let image = userImages[nameOfBuilding(atIndexPath: indexPath)]{
            return image
        }
        
        if let photoName = buildingFor(indexPath: indexPath).photo{
            if !photoName.isEmpty{
                return UIImage(named: photoName)!
            }
        }
        return UIImage(named: "not-available")!
    }
}

