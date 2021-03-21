//
//  OnTheMapListViewController.swift
//  OnTheMap
//
//  Created by Ismail on 13/03/2021.
//

import UIKit

class OnTheMapListViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
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
    
    //MARK: Actions
    @IBAction func refreshTapped() {
        ApiClient.getStudentInformation { (studentInfos, error) in
            self.updateStudentInfoList(studentInfos)
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addLocationTapped() {
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
    
    //MARK: Utils
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

//MARK: Delegates
extension OnTheMapListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.tableCell)!
        
        let studentInfo = studentInfos[indexPath.row]
        
        cell.textLabel?.text = "\(studentInfo.firstName) \(studentInfo.lastName)"
        cell.detailTextLabel?.text = studentInfo.mediaURL
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex =  indexPath.row
        let studentInfo = studentInfos[selectedIndex]
        
        let urlToOpen = studentInfo.mediaURL.validUrlString
        
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
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}


