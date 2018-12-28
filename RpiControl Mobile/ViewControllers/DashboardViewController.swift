//
//  ViewController.swift
//  RpiControl Mobile
//
//  Created by Oleg Mikhnovich on 27/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var devicesTableView: UITableView!
    @IBOutlet weak var scanProgress: UIActivityIndicatorView!
    @IBOutlet weak var scanButton: UIBarButtonItem!
    
    var devicesList: [Device] = []
    var device: Device?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.devicesTableView.dataSource = self
        self.devicesTableView.delegate = self
    }
    
    public func getDevice() -> Device? {
        return self.device
    }

    @IBAction func scanBtn(_ sender: Any) {
        scanProgress.isHidden = false
        scanButton.isHidden = true
        let backgroundQueue = DispatchQueue.global(qos: .background)
        backgroundQueue.async {
            let search = SearchDevices()
            self.devicesList = search.getDevices()
            DispatchQueue.main.async {
                self.devicesTableView.reloadData()
                self.scanProgress.isHidden = true
                self.scanButton.isHidden = false
            }
        }
    }
    
    func showWarnAlert(title: String, info: String) {
        let alertController = UIAlertController(title: title, message: info, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(actionOK)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "openControlPanelSeque") {
            if sender != nil {
                let dev = sender as! Device
                let controller = segue.destination as! ControlPanelViewController
                controller.setDevice(device: dev)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = devicesList[indexPath.row]
        let alertController = UIAlertController(
            title: "Connecto to \(item.getName())@\(item.getIP())",
            message: "Provide valid credentials.",
            preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { (textField : UITextField) -> Void in
            textField.placeholder = "Login"
        }
        alertController.addTextField { (textField : UITextField) -> Void in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (result : UIAlertAction) -> Void in
            print("Cancel")
        }
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            let login = alertController.textFields?[0].text ?? ""
            let password = alertController.textFields?[1].text ?? ""
            
            let connection = ConnectionAgent(address: item.getIP())
            if connection.isConnected {
                let pkg = "\(login)\n\(password)"
                if let resp = connection.sendMessage(package: Package(header: "auth", content: pkg)) {
                    if resp.getHeader() == "auth" && resp.getContent() == "true" {
                        self.performSegue(withIdentifier: "openControlPanelSeque", sender: item)
                    } else {
                        self.showWarnAlert(title: "Error", info: "Invalid username or password!")
                    }
                } else {
                    self.showWarnAlert(title: "Error", info: "An error occurred while sending a request.")
                }
            } else {
                self.showWarnAlert(title: "Client was disconnected!", info: "Try again later...")
            }
            connection.dispose()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
 
}

