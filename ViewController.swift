//
//  ViewController.swift
//  InClass13
//
//  Created by Smith, Reginald on 4/24/19.
//  Copyright © 2019 Smith, Reginald. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

class ViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var destinationLat:CLLocationDegrees?
    var destinationLong:CLLocationDegrees?
    var destinationName:String?
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var currentLoc: UILabel!
    @IBOutlet weak var tripDestination: UILabel!
    @IBOutlet weak var tripTime: UILabel!
    @IBOutlet weak var tripDistance: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        enableBasicLocationServices()
         
        self.mapView.delegate = self
        
        if destinationLat != nil {
            createRoute()
        }
    }

    func enableBasicLocationServices() {
        self.locationManager.delegate = self
        print("Called")
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            //disableMyLocationBasedFeatures()
            print("Restricted access.")
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            //Enable location features
            print("Location features are on")
            self.setupForLocationUpdates()
            break
        }
    }
    
    func setupForLocationUpdates(){
        print("Set up was called")
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 30 //in meters
        
        self.locationManager.startUpdatingLocation()
    }
    
    @IBAction func getDirections(_ sender: Any) {
        performSegue(withIdentifier: "toPlace", sender: self)
    }
    
    func createRoute() {
         self.mapView.clear()
         let origin = "\((locationManager.location?.coordinate.latitude)!),\((locationManager.location?.coordinate.longitude)!)"
         let destination = "\((destinationLat)!),\((destinationLong)!)"
         let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyCjQlEN9SKDCtC30zy7grp-lyhPjEv792Q"
         
         AF.request(url).responseJSON { response in
            //print(response.value!)
            let data = response.result.value as! [String: Any]
            let routes = data["routes"] as! [[String:Any]]
            print(data)
            //code for creating the boundary once the destination is selected.
            let boundary = routes[0]["bounds"] as! [String:Any]
            let ne = boundary["northeast"] as! [String:Any]
            let sw = boundary["southwest"] as! [String:Any]
            let neCoords = CLLocationCoordinate2D(latitude: ne["lat"] as! CLLocationDegrees, longitude: ne["lng"] as! CLLocationDegrees)
            let swCoords = CLLocationCoordinate2D(latitude: sw["lat"] as! CLLocationDegrees, longitude: sw["lng"] as! CLLocationDegrees)
            
            let bounds = GMSCoordinateBounds(coordinate: neCoords, coordinate: swCoords)
            let camera = self.mapView.camera(for: bounds, insets: UIEdgeInsets())
            self.mapView.camera = camera!
            
            //code for displaying the distance and trip time.
            let legs = routes[0]["legs"] as! [[String:Any]]
            let distance = legs[0]["distance"] as! [String:Any]
            let travelTime = legs[0]["duration"] as! [String:Any]
            self.tripDistance.text = distance["text"] as? String
            self.tripTime.text = travelTime["text"] as? String
            
            self.tripDestination.text = legs[0]["end_address"] as? String
            self.currentLoc.text = legs[0]["start_address"] as? String
            
            let startCoords = legs[0]["start_location"] as! [String:Any] //contain the lat and long for the starting and ending locations.
            let destCoords = legs[0]["end_location"] as! [String:Any]
            
            let destMarker = GMSMarker()
            destMarker.position = CLLocationCoordinate2DMake((destCoords["lat"] as! CLLocationDegrees), destCoords["lng"] as! CLLocationDegrees)
            destMarker.title = "Destination"
            destMarker.map = self.mapView //creates a marker for the destination.
            
            let startMaker = GMSMarker()
            startMaker.position = CLLocationCoordinate2DMake((startCoords["lat"] as! CLLocationDegrees), startCoords["lng"] as! CLLocationDegrees)
            startMaker.title = "Start"
            startMaker.map = self.mapView //creates a marker for the starting location.
         
             for route in routes {
                let routeOverviewPolyline = route["overview_polyline"] as! [String:Any]
                let points = routeOverviewPolyline["points"] as! String
                let path = GMSPath.init(fromEncodedPath: points)
                
                let polyline = GMSPolyline(path: path)
                polyline.strokeColor = .blue
                polyline.strokeWidth = 2.0
                polyline.map = self.mapView
             }
         }//Code to be used to create the line directing the user to their location, currently only makes a straight line.
    }
    
    @IBAction func clearMap(_ sender: Any) {
        self.mapView.clear()
        self.tripDestination.text = ""
        self.currentLoc.text = ""
        self.tripDistance.text = ""
        self.tripTime.text = ""
    }
    
    
    @IBAction func myUnwindFunction(unwindSegue: UIStoryboardSegue) {
        createRoute()
    }
}

extension ViewController: CLLocationManagerDelegate, GMSMapViewDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            //disableMyLocationBasedFeatures()
            break
            
        case .authorizedWhenInUse:
            //enableMyWhenInUseFeatures()
            setupForLocationUpdates()
            print("Location manager called")
            break
            
        case .notDetermined, .authorizedAlways:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 14)
        self.mapView.camera = camera
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!, (locationManager.location?.coordinate.longitude)!)
        marker.title = "My Location"
        marker.snippet = "Me"
        marker.map = self.mapView
        
        print("My location is \(location!)")
    }
}

