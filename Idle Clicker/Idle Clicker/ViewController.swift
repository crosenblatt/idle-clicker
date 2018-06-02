//
//  ViewController.swift
//  Idle Clicker
//
//  Created by Christopher Rosenblatt on 5/31/18.
//  Copyright © 2018 crosenblatt. All rights reserved.
//

import UIKit
import os.log

class ViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var cookieCounter: UILabel!
    @IBOutlet weak var cookieButton: UIButton!
    @IBOutlet weak var cpcLabel: UILabel!
    @IBOutlet weak var cpsLabel: UILabel!
    @IBOutlet weak var upgradeOneButton: UIButton!
    @IBOutlet weak var upgradeTwoButton: UIButton!
    
    //MARK: Properties
    var player:Player?
    var upgradeOne:Upgrade?
    var upgradeTwo:Upgrade?
    var timer = Timer()
    var saveTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load
        if loadPlayer() != nil {
            player = loadPlayer()
        } else {
            player = Player(cps: 0, cpc: 0.1, totalCookies: 0, upgradesOwned: [Int](repeatElement(0, count: 2)))
        }
        
        updateCPC()
        updateCPS()
        
        upgradeOne = Upgrade(cps: 0.0, cpc: 1.0, price: 2.0)
        upgradeTwo = Upgrade(cps: 1.0, cpc: 0.0, price: 5.0)
        
        upgradeOneButton.tag = 1
        upgradeTwoButton.tag = 2
        
        upgradeOneButton.addTarget(self, action: #selector(upgradePurchased), for: UIControlEvents.touchUpInside)
        upgradeTwoButton.addTarget(self, action: #selector(upgradePurchased), for: UIControlEvents.touchUpInside)
        
        //Start Timers
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTotal), userInfo: nil, repeats: true)
        
        saveTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(savePlayer), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: IBActions and Button Taps
    @IBAction func cookieClick(_ sender: Any) {
        player!.totalCookies! += player!.cpc!
        cookieCounter.text = "\(player!.totalCookies!) Cookies"
    }
    
    @IBAction func resetAction(_ sender: Any) {
        player = Player(cps: 0, cpc: 0.1, totalCookies: 0, upgradesOwned: [Int](repeating: 0, count: 2))
        updateTotal()
        updateCPS()
        updateCPC()
    }
    
    //Purchase an Upgrade
    @objc func upgradePurchased(sender: UIButton) {
        switch sender.tag {
        case 1:
            if player!.totalCookies! >= upgradeOne!.cost! {
                player!.upgradesOwned![0] += 1
                player!.cpc! += upgradeOne!.cpcBoost!
                player!.totalCookies! -= upgradeOne!.cost!
                updateTotal()
                updateCPC()
            } else {
                break
            }
        case 2:
            if player!.totalCookies! >= upgradeTwo!.cost! {
                print("before: \(player!.totalCookies!)")
                player!.upgradesOwned![1] += 1
                player!.cps! += upgradeTwo!.cpsBoost!
                player!.totalCookies! -= upgradeTwo!.cost!
                print("after: \(player!.totalCookies!)")
                updateTotal()
                updateCPS()
            } else {
                break
            }
        default:
            print("it broke")
        }
    }
    
    //MARK: Update Labels
    @objc func updateTotal() {
        player!.totalCookies! += player!.cps!
        cookieCounter!.text = "\(player!.totalCookies!) Cookies"
    }
    
    func updateCPC() {
        cpcLabel!.text = "\(player!.cpc!) CPC"
    }
    
    func updateCPS() {
        cpsLabel!.text = "\(player!.cps!) CPS"
    }
    
    //MARK: Save and Load
    @objc private func savePlayer() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(player!, toFile: Player.ArchiveURL.path)
        
        if isSuccessfulSave {
            print("saved")
        } else {
            print("save failed")
        }
    }
    
    private func loadPlayer() -> Player? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Player.ArchiveURL.path) as? Player
    }
}

//MARK: Extra Classes
class Player: NSObject, NSCoding {
    var cps:Float?
    var cpc:Float?
    var totalCookies:Float?
    var upgradesOwned:[Int]?
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("player")
    
    init(cps: Float, cpc: Float, totalCookies: Float, upgradesOwned: [Int]) {
        self.cps = cps
        self.cpc = cpc
        self.totalCookies = totalCookies
        self.upgradesOwned = upgradesOwned
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(cps, forKey: "cps")
        aCoder.encode(cpc, forKey: "cpc")
        aCoder.encode(totalCookies, forKey: "totalCookies")
        aCoder.encode(upgradesOwned, forKey: "upgradesOwned")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.cps = aDecoder.decodeObject(forKey: "cps") as? Float
        self.cpc = aDecoder.decodeObject(forKey: "cpc") as? Float
        self.totalCookies = aDecoder.decodeObject(forKey: "totalCookies") as? Float
        self.upgradesOwned = aDecoder.decodeObject(forKey: "upgradesOwned") as? [Int]
        super.init()
    }
}

class Upgrade {
    var cpsBoost:Float?
    var cpcBoost:Float?
    var cost:Float?
    
    init(cps: Float, cpc: Float, price: Float) {
        cpsBoost = cps
        cpcBoost = cpc
        cost = price
    }
}
