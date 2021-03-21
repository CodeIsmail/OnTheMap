//
//  ViewController.swift
//  OnTheMap
//
//  Created by Ismail on 27/02/2021.
//

import UIKit
import MapKit

class OnTheMapViewController: UIViewController, MKMapViewDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Properties
    var studentInfos: [StudentInformation]!{
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.studentInfos
    }
    var isPinExists = false
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ApiClient.getStudentInformation { (studentInfos, error) in
            self.updateStudentInfoList(studentInfos)
            self.populateMap()
        }
    }
    
    //MARK: Delegates
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let urlString = view.annotation?.subtitle!
            let urlToOpen = (urlString ?? "").validUrlString
            
            if !urlToOpen.canOpenUrl {
                showInvalidUrlAlert(message: "Invalid url")
                return
            }
            let url = URL(string: urlToOpen)!
            UIApplication.shared.open(url, options: [:]) { (isSuccess) in
                if !isSuccess {
                    self.showInvalidUrlAlert(message: "Failed to open url.")
                }
            }
            
        }
    }

    //MARK: Actions
    @IBAction func addLocationTapped(_ sender: Any) {
        let uniqueKey = ApiClient.Auth.key
        for studentInfo in studentInfos{
            if uniqueKey == studentInfo.uniqueKey {
                showPinExistsAlert(current: studentInfo)
                isPinExists = true
                break
            }
        }
        
        if !isPinExists {
            navigateToAddLocation(current: nil)
        }
    }
    @IBAction func refreshDataTapped(_ sender: Any) {
        ApiClient.getStudentInformation { (studentInfos, error) in
            self.updateStudentInfoList(studentInfos)
            self.populateMap()
        }
    }
}

//MARK: Utils Extension
extension OnTheMapViewController{
    
    func populateMap() {
        var annotations = [MKPointAnnotation]()

        for studentInfo in studentInfos {
            
            let lat = CLLocationDegrees(studentInfo.latitude)
            let long = CLLocationDegrees(studentInfo.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = studentInfo.firstName
            let last = studentInfo.lastName
            let mediaURL = studentInfo.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    func updateStudentInfoList(_ studentInfoList: [StudentInformation]){
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        appDelegate.studentInfos = studentInfoList
    }

    func showInvalidUrlAlert(message: String){
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func showPinExistsAlert(current studentInfo: StudentInformation){
        let alertVC = UIAlertController(title: "", message: "You have already posted a student location. Would like to override your current location?", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Override", style: .default){_ in
            
            self.navigateToAddLocation(current: studentInfo)
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func navigateToAddLocation(current: StudentInformation?){
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.toAddLocation) as! NewLocationViewController
        vc.studentInfo = current
        navigationController?.pushViewController(vc, animated: true)
    }
}
