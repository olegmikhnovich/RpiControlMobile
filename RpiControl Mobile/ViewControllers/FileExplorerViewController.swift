//
//  FileExplorerViewController.swift
//  RpiControl Mobile
//
//  Created by Oleg Mikhnovich on 27/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import UIKit

class FileExplorerViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var filesTableView: UITableView!
    
    private var device: Device?
    private let homeFolder: String = "/home/pi"
    private var currentFolder: String = ""
    
    var filesList: [UserFile] = []
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        let controlPanelInstance = self.parent as! ControlPanelViewController
        self.device = controlPanelInstance.getDevice()
        
        self.currentFolder = homeFolder
        
        filesTableView.delegate = self
        filesTableView.dataSource = self
        
        initFreshControl()
        
        DispatchQueue.main.async {
            self.loadDirectory(directory: self.currentFolder)
        }
    }
    
    private func initFreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading ...")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        filesTableView.addSubview(refreshControl)
    }
    
    @objc func refresh(sender: AnyObject) {
        refreshBegin(newtext: "Refresh",
                     refreshEnd: {(x:Int) -> () in
                        self.filesTableView.reloadData()
                        self.refreshControl.endRefreshing()
        })
    }
    
    func refreshBegin(newtext: String, refreshEnd: @escaping (Int) -> ()) {
        let queue = DispatchQueue.global(qos: .utility)
        queue.async {
            self.loadDirectory(directory: self.currentFolder)
            sleep(1)
            DispatchQueue.main.async {
                refreshEnd(0)
            }
        }
    }
    
    @IBAction func backBtnClick(_ sender: Any) {
        if self.currentFolder == self.homeFolder { return }
        var rawPath = currentFolder.split(separator: "/")
        if let _ = rawPath.popLast() {
            self.currentFolder = "/" + rawPath.joined(separator: "/")
            DispatchQueue.main.async {
                self.loadDirectory(directory: self.currentFolder)
            }
        }
    }
    
    @IBAction func homeBtnClick(_ sender: Any) {
        DispatchQueue.main.async {
            self.loadDirectory(directory: self.homeFolder)
        }
    }
    
    private func loadDirectory(directory: String) {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            if let res = connection.sendMessage(package: Package(header: "get-dir", content: directory)) {
                if res.getHeader() == "get-dir" {
                    let data = res.getContent().split(separator: "^")
                    filesList.removeAll()
                    for d in data {
                        filesList.append(UserFile(raw: String(d)))
                    }
                    self.currentFolder = directory
                }
            }
        }
        connection.dispose()
        DispatchQueue.main.async {
            self.filesTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = filesList[indexPath.row]
        if item.getType() == item.dirType {
            self.currentFolder += "/" + item.getName()
            DispatchQueue.main.async {
                self.loadDirectory(directory: self.currentFolder)
            }
        }
    }
}
