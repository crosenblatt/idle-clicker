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

class LeaderboardViewController: UIViewController {
    @IBOutlet weak var number1: UILabel!
    @IBOutlet weak var number2: UILabel!
    @IBOutlet weak var number3: UILabel!
    @IBOutlet weak var number4: UILabel!
    @IBOutlet weak var number5: UILabel!
    @IBOutlet weak var number6: UILabel!
    @IBOutlet weak var number7: UILabel!
    @IBOutlet weak var number8: UILabel!
    @IBOutlet weak var number9: UILabel!
    @IBOutlet weak var number10: UILabel!
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
    var data = [String:Int]()
    var dataArray = [String](repeating: "CJR 0", count: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Firebase Configuration
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        ref = Database.database().reference()
        
        databaseHandle = ref?.child("users").observe(.value, with: { (snapshot) in
            
            let lvl = snapshot.value as? Int
            let name = snapshot.key as? String
            
            if let aName = name {
                self.data[aName] = lvl
                self.loadBoard()
            }
        })
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goHome(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func loadBoard() {
        for (name, lvl) in data {
            self.dataArray += ["\(name) \(lvl)"]
        }
        
        number1.text = dataArray[0]
        number2.text = dataArray[1]
        number3.text = dataArray[2]
        number4.text = dataArray[3]
        number5.text = dataArray[4]
        number6.text = dataArray[5]
        number7.text = dataArray[6]
        number8.text = dataArray[7]
        number9.text = dataArray[8]
        number10.text = dataArray[9]
        
        print(self.dataArray)
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
