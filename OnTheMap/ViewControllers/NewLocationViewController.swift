//
//  NewLocationViewController.swift
//  OnTheMap
//
//  Created by Ismail on 13/03/2021.
//

import UIKit
import MapKit

class NewLocationViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mediaUrlTextView: UITextField!
    
    //MARK: Property
    var studentInfo: StudentInformation!
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Populate views with existing data.
        if studentInfo != nil {
            mediaUrlTextView.text = studentInfo.mediaURL
            addressTextField.text = studentInfo.mapString
        }
        
    }
    
    //MARK: Actions
    @IBAction func actionSubmitAddress(_ sender: Any) {
        
        let mediaUrl:String = mediaUrlTextView.text!
        let address: String = addressTextField.text!
        if address.isEmpty || mediaUrl.isEmpty {
            let message = "\(address.isEmpty ? "Address":"Link") field is empty."
            showErrorAlert(message: message)
            return
        }
        setSearchAddress(true)
        getCoordinate(addressString: address) { (coordinate, error) in
            self.setSearchAddress(false)
            if error != nil{
                self.showErrorAlert(message: error?.localizedDescription ?? "Failed to get location.") {
                }
                return
            }
            let requestBody = AddLocationRequest(uniqueKey: ApiClient.Auth.key, firstName: "Ismail", lastName: "Ibrahim", mapString: address, mediaURL: mediaUrl, latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.navigateToConfirmNewLocation(locationRequest: requestBody)
            
        }
    }

    //MARK: Util
    func showErrorAlert(message: String, completion: (() -> Void)? = nil){
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: completion)
    }
    
    private func getCoordinate( addressString : String,
            completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                        
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
                
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    private func navigateToConfirmNewLocation(locationRequest: AddLocationRequest) {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.toComfirmNewLocation) as! ConfirmNewLocationViewController
        vc.locationRequest = locationRequest
        if studentInfo != nil {
            vc.studentIdToUpdate = studentInfo.objectId
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setSearchAddress(_ isSearching: Bool) {
        if isSearching {
            progressIndicator.startAnimating()
        }else{
            progressIndicator.stopAnimating()
        }
        setUIState(!isSearching)
    }
    
    func setUIState(_ isLoading: Bool){
        submitButton.isEnabled = isLoading
        addressTextField.isEnabled = isLoading
        mediaUrlTextView.isEnabled = isLoading
    }
}
