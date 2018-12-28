//
//  DeviceSettingsViewController.swift
//  RpiControl Mobile
//
//  Created by Oleg Mikhnovich on 27/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import UIKit

class DeviceSettingsViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var osLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var soundVolSlider: UISlider!
    
    private var device: Device?
    
    override func viewDidLoad() {
        let controlPanelInstance = self.parent as! ControlPanelViewController
        self.device = controlPanelInstance.getDevice()
        
        loadMyDeviceInfo()
        loadSoundVolumeInfo()
    }
    
    private func loadMyDeviceInfo() {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            if let res = connection.sendMessage(package: Package(header: "device-info", content: "...")) {
                if res.getHeader() == "device-info" {
                    let d = res.getContent().split(separator: "|")
                    if d.count == 4 {
                        nameLabel.text = "Name: \(String(d[0]))"
                        modelLabel.text = "Model: \(String(d[1]))"
                        osLabel.text = "OS: \(String(d[2]))"
                        tempLabel.text = "Temp: \(String(d[3]))"
                    }
                }
            }
        }
        connection.dispose()
    }
    
    private func loadSoundVolumeInfo() {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            if let res = connection.sendMessage(package: Package(header: "get-sound-volume", content: "...")) {
                if res.getHeader() == "get-sound-volume" {
                    soundVolSlider.value = Float(res.getContent()) ?? 0
                }
            }
        }
        connection.dispose()
    }
    
    private func showAlert(title: String, info: String) {
        let alertController = UIAlertController(title: title, message: info, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func freshDeviceInfo(_ sender: Any) {
        loadMyDeviceInfo()
    }
    
    @IBAction func changeSoundValue(_ sender: Any) {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            let soundValue = String(soundVolSlider.value)
            if let res = connection.sendMessage(package: Package(header: "set-sound-volume", content: soundValue)) {
                if res.getHeader() == "set-sound-volume" {
                    soundVolSlider.value = Float(res.getContent()) ?? 0
                }
            }
        }
        connection.dispose()
    }
    
    @IBAction func saveNewDeviceName(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Change device name",
            message: "Provide a new name.",
            preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { (textField : UITextField) -> Void in
            textField.placeholder = "Name"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (result : UIAlertAction) -> Void in
            print("Cancel change name.")
        }
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            let name = alertController.textFields?[0].text ?? ""
            
            guard let dev = self.device else { return }
            let connection = ConnectionAgent(address: dev.getIP())
            if connection.isConnected {
                if let res = connection.sendMessage(package: Package(header: "set-device-name", content: name)) {
                    if res.getHeader() == "set-device-name" { self.loadMyDeviceInfo() }
                }
            }
            connection.dispose()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func saveNewPassword(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Change your password",
            message: "Provide old and new passwords.",
            preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { (textField : UITextField) -> Void in
            textField.isSecureTextEntry = true
            textField.placeholder = "Old password"
        }
        
        alertController.addTextField { (textField : UITextField) -> Void in
            textField.isSecureTextEntry = true
            textField.placeholder = "New password"
        }
        
        alertController.addTextField { (textField : UITextField) -> Void in
            textField.isSecureTextEntry = true
            textField.placeholder = "Confirm new password"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (result : UIAlertAction) -> Void in
            print("Cancel change password.")
        }
        let okAction = UIAlertAction(title: "Send", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            let oldPwd = alertController.textFields?[0].text ?? ""
            let newPwd = alertController.textFields?[1].text ?? ""
            let confirmNewPwd = alertController.textFields?[2].text ?? ""
            
            if newPwd != confirmNewPwd {
                self.showAlert(title: "Error", info: "Passwords do not match.")
                return
            }
            guard let dev = self.device else { return }
            let connection = ConnectionAgent(address: dev.getIP())
            if connection.isConnected {
                let pkg = oldPwd + "|" + newPwd
                if let res = connection.sendMessage(package: Package(header: "set-new-password", content: pkg)) {
                    if res.getHeader() == "set-new-password" {
                        if res.getContent() == "true" {
                            self.showAlert(title: "Successful operation", info: "Your password was changed successfully.")
                        } else {
                            self.showAlert(title: "Unsuccessful operation", info: "Something went wrong. Try again later ...")
                        }
                    }
                }
            }
            connection.dispose()
          
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func rebootBtnClick(_ sender: Any) {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            let _ = connection.sendMessage(package: Package(header: "reboot-device", content: "..."))
        }
        connection.dispose()
        UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
    }
    
    @IBAction func shutdownBtnClick(_ sender: Any) {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            let _ = connection.sendMessage(package: Package(header: "shutdown-device", content: "..."))
        }
        connection.dispose()
        UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
    }
}
