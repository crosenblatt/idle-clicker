//
//  LeaderboardViewController.swift
//  Idle Clicker
//
//  Created by Christopher Rosenblatt on 6/20/18.
//  Copyright © 2018 crosenblatt. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
    var data = [String:Int]()
    var postData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Table View Setup
        tableView.delegate = self
        tableView.dataSource = self
        
        //Firebase Configuration
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        ref = Database.database().reference()
        
        databaseHandle = ref?.child("users").observe(.childAdded, with: { (snapshot) in
            let name = snapshot.key as String
            let lvl = snapshot.value as! Int
            
            self.postData.append("\(name) \(lvl)")
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goHome(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func loadBoard() {
        var i = 0
        for (name, lvl) in data {
            self.postData[i] = "\(name) \(lvl)"
            i += 1
        }
    }
    
    //Table View Stuff
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell")
        cell?.textLabel?.textColor = UIColor(white: 1.0, alpha: 1.0)
        cell?.textLabel?.textAlignment = NSTextAlignment.center
        cell?.textLabel?.text = postData[indexPath.row]
        
        return cell!
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
