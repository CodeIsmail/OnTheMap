//
//  ConfirmNewLocationViewController.swift
//  OnTheMap
//
//  Created by Ismail on 15/03/2021.
//

import UIKit
import MapKit

class ConfirmNewLocationViewController: UIViewController {

    //MARK: Outlet
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Properties
    var studentIdToUpdate: String!
    var locationRequest: AddLocationRequest!
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        addLocationOnMap(locationRequest.latitude, locationRequest.longitude)
    }
    
    //MARK: Actions
    @IBAction func actionSubmitNewLocation(_ sender: Any) {
        
        if studentIdToUpdate != nil {
            //update student location
            ApiClient.updateLocationRequest(userId: studentIdToUpdate, requestBody: locationRequest) { (response, error) in
                
                if error != nil{
                    self.showErrorAlert(message: error?.localizedDescription ?? "Failed to update student", completion: nil)
                    return
                }
            
                self.navigateToHomeScreen()
            }
        }else{
            //new student location
            ApiClient.addLocationRequest(requestBody: locationRequest) { (response, error) in
                if error != nil {
                    self.showErrorAlert(message: error?.localizedDescription ?? "Error posting new location.", completion: nil)
                    return
                }
                self.navigateToHomeScreen()
            }
        }
    }
    
    @IBAction func cancel(){
        self.navigateToHomeScreen()
    }
    
    //MARK: Utils
    func addLocationOnMap(_ latitude: Double, _ longitude: Double){
        
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
    }
    
    func navigateToHomeScreen(){
        navigationController?.popToRootViewController(animated: true)
    }
    
    func showErrorAlert(message: String, completion: (() -> Void)?){
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: completion)
    }
    
}

//MARK: Delegates
extension ConfirmNewLocationViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
