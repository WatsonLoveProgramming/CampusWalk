//
//  MapViewController.swift
//  CampusWalk
//
//  Created by Watson Li on 10/16/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, BuildingDelegate, CLLocationManagerDelegate, NavigationDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var ETALabel: UILabel!
    @IBOutlet weak var directionScrollView: UIScrollView!
    @IBOutlet weak var stepView: UIView!
    @IBOutlet weak var toggleNaviButton: UIButton!
    
    let mapModel = MapModel.sharedInstance
    let spanDelta = 0.01
    let naviDelta = 0.008
    let locationManager = CLLocationManager()
    var pathCoordinates = [CLLocationCoordinate2D]()
    var userPolyline : MKPolyline?
    var favourates = [Building]()
    var lastChosen : MKAnnotation?
    var lastRoute : MKPolyline?
    var showFavourite : Bool?
    var showNavigation : Bool?
    var directions = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        centerMapAt(location: mapModel.initialLocation)
        mapView.mapType = .standard
        showFavourite = false
        showNavigation = false
        stepView.isHidden = true
        toggleNaviButton.isHidden = true
        directionScrollView.isUserInteractionEnabled = true
        directionScrollView.isPagingEnabled = true
        directionScrollView.backgroundColor = UIColor.lightGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .notDetermined, .denied:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                mapView.showsUserLocation = true
                locationManager.startUpdatingLocation()
                locationManager.startMonitoringVisits()
            default:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringVisits()
        default:
            mapView.showsUserLocation = false
            locationManager.stopUpdatingLocation()
            locationManager.stopMonitoringVisits()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newCoordinates = locations.map {$0.coordinate}
        pathCoordinates.append(contentsOf: newCoordinates)
        
        if let polyline = userPolyline {
            mapView.remove(polyline)
        }
        
        userPolyline = MKPolyline(coordinates: pathCoordinates, count: pathCoordinates.count)
        mapView.add(userPolyline!)
        
    }
    
    func  centerMapAt(location: CLLocation) {
        let center = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        mapView.region = MKCoordinateRegion(center: center, span: span)
    }
    
    @IBAction func currentLocation(_ sender: UIButton) {
        centerMapAt(location: locationManager.location!)
    }
    
    @IBAction func toggleNavigation(_ sender: UIButton) {
        stepView.isHidden = showNavigation! ? false : true
        let title = showNavigation! ? "Hide Navigation" : "Show Navigation"
        toggleNaviButton.setTitle(title, for: .normal)
        showNavigation = !showNavigation!
    }
    
    @IBAction func switchMapType(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "Select a map type", message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "standard", style: .default) { (action:UIAlertAction) in
            self.mapView.mapType = .standard
        }
        let action2 = UIAlertAction(title: "satellite", style: .default) { (action:UIAlertAction) in
            self.mapView.mapType = .satellite
        }
        let action3 = UIAlertAction(title: "hybrid", style: .default) { (action:UIAlertAction) in
            self.mapView.mapType = .hybrid
        }
        let action4 = UIAlertAction(title: "Cancel", style: .cancel)

        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(action3)
        actionSheet.addAction(action4)

        self.present(actionSheet, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "BuildingSegue":
            let buildingViewController = segue.destination as! BuildingTableViewController
            buildingViewController.delegate = self
            buildingViewController.completionBlock = {self.dismiss(animated: true, completion: nil)}
        case "NavigationSegue":
            let navigationViewController = segue.destination as! NavigationViewController
            navigationViewController.delegate = self
            navigationViewController.completionBlock = {self.dismiss(animated: true, completion: nil)}
        case "FullStepsSegue":
            let stepsTableViewController = segue.destination as! StepsTableViewController
            stepsTableViewController.completionBlock = {self.dismiss(animated: true, completion: nil)}
            stepsTableViewController.configureInfo(forSteps: directions)
            
        default:
            assert(false, "Unhandled Segue")
        }
    }
    
    
    //MARK: MapView Delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case is MKPolyline:
            let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            polylineRenderer.strokeColor = .blue
            polylineRenderer.lineWidth = 2.0
            return polylineRenderer
            
        default:
            assert(false, "Unhandled Renderer")
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is Building:
            return annotationView(forBuilding: annotation as! Building)
        default:
            return nil
        }
    }
    
    //configure annotationView
    func annotationView(forBuilding building:Building) -> MKAnnotationView {
        let identifier = "Building"
        var view : MKPinAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView  {
            dequeuedView.annotation = building
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: building, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.animatesDrop = true
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        view.pinTintColor = building.favourite ? UIColor.red : UIColor.blue

        return view
    }
    
    //configurate calloutAccessory
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        switch view.annotation {
        case is Building:
            callOutFor(building: view.annotation as! Building)
        default:
            return
        }
    }
    
    func callOutFor(building: Building) {
        let actionSheet = UIAlertController(title: building.title, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "Add to Favourate", style: .default) { (action:UIAlertAction)  in
            self.favourates.append(building)
            building.favourite = true
        }
        
        let action2 = UIAlertAction(title: "Remove Favourite", style: .default) { (action:UIAlertAction) in
            if building.favourite{
                self.favourates = self.favourates.filter { $0 != building }
                building.favourite = false
            }
        }
        
        let action3 = UIAlertAction(title: "Remove Pin", style: .default) { (action:UIAlertAction) in
            self.mapView.removeAnnotation(building)
        }
        
        let action4 = UIAlertAction(title: "Cancel", style: .cancel)

        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(action3)
        actionSheet.addAction(action4)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func toggleFavourites(_ sender: UIBarButtonItem) {
        mapView.removeAnnotations(mapView.annotations)

        if !showFavourite!{
            mapView.addAnnotations(favourates)
            sender.title = "Hide Favourite"
        }else{
            mapView.removeAnnotations(favourates)
            sender.title = "Favourite"
        }
        showFavourite = !showFavourite!
    }
    
    //MARK: StepsTableView Delegate
    func dismissSteps() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: navigationView Delegate
    func dismissNavigation(from: String, to: String) {
        direction(from: from, to: to)
        self.stepView.isHidden = false
        toggleNaviButton.isHidden = false
        dismiss(animated: true, completion: nil)
    }
    
    func direction(from: String, to: String)  {
        guard mapView.showsUserLocation else {return}
        
        if let lastRoute = self.lastRoute{
            mapView.remove(lastRoute)
            self.directions.removeAll()
            for view in self.directionScrollView.subviews {
                view.removeFromSuperview()
            }
        }
        
        let request = MKDirectionsRequest()
        let source = mapModel.allBuildings.filter { $0.title == from}
        let destination = mapModel.allBuildings.filter { $0.title == to}
        let currentLocation = MKMapItem.forCurrentLocation()
        request.destination = (to == "User Location") ? currentLocation : destination[0].mapItem
        request.source = (from == "User Location") ? currentLocation : source[0].mapItem
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            guard error == nil else {print(error?.localizedDescription ?? "Error"); return}
            
            if let route = response?.routes[0] {
                self.lastRoute = route.polyline
                
                self.mapView.add(route.polyline)

                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                let date = Date(timeInterval: route.expectedTravelTime, since: Date())
                self.ETALabel.text = formatter.string(from: date)
                
                for step in route.steps{
                    self.directions.append(step.instructions)
                }
                
                let stepsCount = self.directions.count
                let size = self.directionScrollView.bounds.size
                let contentSize = CGSize(width: CGFloat(stepsCount)*size.width, height: size.height)
                self.directionScrollView.contentSize = contentSize
                
                for i in 0..<stepsCount {
                    self.addLabel(atIndex: i)
                }
                
            }
        }
    }
    
    func addLabel(atIndex i: Int){
        let size = self.directionScrollView.bounds.size
        let xOffset = CGFloat(i) * size.width
        let origin = CGPoint(x: xOffset, y: 0.0)
        let frame = CGRect(origin: origin, size: size)
        let pageView = UIView(frame: frame)
        
        let labelFrame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        let label = UILabel(frame: labelFrame)
        label.text = self.directions[i]
        label.textAlignment = .center
        
        pageView.addSubview(label)
        self.directionScrollView.addSubview(pageView)
    }
    
    //MARK: tableView Delegate
    func didChoose(building: Building) {
        dismiss(animated: true) {
            self.locateBuilding(building: building)
        }
    }
    
    func locateBuilding(building: Building) {
        if let lastChosen = self.lastChosen as? Building{
            if !lastChosen.favourite{
                mapView.removeAnnotation(lastChosen)
            }
        }
        
        lastChosen = building
        mapView.addAnnotation(building)
        
        let span = MKCoordinateSpan(latitudeDelta: naviDelta, longitudeDelta: naviDelta)
        let region = MKCoordinateRegion(center: building.coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    
}


