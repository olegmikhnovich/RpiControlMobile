//
//  Extentions.swift
//  RpiControl Mobile
//
//  Created by Oleg Mikhnovich on 27/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import UIKit
import Foundation

extension String {
    func matches(pattern regex: String) -> [String] {
        do {
            let src = self as String
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: src, range: NSRange(src.startIndex..., in: src))
            return results.map { String(src[Range($0.range, in: src)!]) }
        } catch let error {
            print("Invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

extension UIBarButtonItem {
    var isHidden: Bool {
        get {
            return tintColor == UIColor.clear
        }
        set(hide) {
            if hide {
                isEnabled = false
                tintColor = UIColor.clear
            } else {
                isEnabled = true
                tintColor = nil
            }
        }
    }
}

extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devicesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellDeviceIdentifier")!
        let device = devicesList[indexPath.row]
        cell.textLabel?.text = "\(device.getName())@\(device.getIP())"
        cell.detailTextLabel?.text = device.getType() + "\n" + device.getOS()
        return cell
    }
}

