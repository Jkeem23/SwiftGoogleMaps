//
//  PlaceAutocompleteViewController.swift
//  InClass13
//
//  Created by Smith, Reginald on 4/24/19.
//  Copyright © 2019 Smith, Reginald. All rights reserved.
//

import UIKit
import GooglePlaces
import Alamofire

class PlaceAutocompleteViewController: UIViewController {
    
    @IBOutlet weak var destination: UITextField!
    var lat:CLLocationDegrees?
    var long:CLLocationDegrees?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func userTyping(_ sender: Any) {
        destination.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindSegue" {
            print("Unwinding")
            let vc = segue.destination as! ViewController
            vc.destinationLat = self.lat
            vc.destinationLong = self.long
            print(vc.destinationLong!)
        }
    }
}

extension PlaceAutocompleteViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        destination.text = place.name
        lat = place.coordinate.latitude
        long = place.coordinate.longitude
        dismiss(animated: true, completion: nil)//dismisses when a location is selected
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
