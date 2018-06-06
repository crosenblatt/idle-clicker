//
//  ViewController.swift
//  Idle Clicker
//
//  Created by Christopher Rosenblatt on 5/31/18.
//  Copyright © 2018 crosenblatt. All rights reserved.
//

import UIKit
import os.log
import AVFoundation

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
    var popPlayer:AVAudioPlayer!
    var purchasePlayer:AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Background Image
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Blue.jpg")!)
        
        //Load
        if loadPlayer() != nil {
            player = loadPlayer()
        } else {
            player = Player(cps: 0, cpc: 0.1, totalCookies: 0, upgradesOwned: [Int](repeatElement(0, count: 2)))
        }
        
        //Set Labels
        updateCPC()
        updateCPS()
        
        //Set Upgrades
        upgradeOne = Upgrade(cps: 0.0, cpc: 1.0, price: 2.0)
        upgradeTwo = Upgrade(cps: 1.0, cpc: 0.0, price: 5.0)
        
        upgradeOneButton.tag = 1
        upgradeTwoButton.tag = 2
        
        upgradeOneButton.addTarget(self, action: #selector(upgradePurchased), for: UIControlEvents.touchUpInside)
        upgradeTwoButton.addTarget(self, action: #selector(upgradePurchased), for: UIControlEvents.touchUpInside)
        
        //Sound Loading
        let popURL = Bundle.main.url(forResource: "PopSound", withExtension: "flac")
        do {
            popPlayer = try AVAudioPlayer(contentsOf: popURL!)
            popPlayer.prepareToPlay()
        } catch let error as NSError {
            print(error.debugDescription)
        }
        
        let purchaseURL = Bundle.main.url(forResource: "Purchase", withExtension: "wav")
        do {
            purchasePlayer = try AVAudioPlayer(contentsOf: purchaseURL!)
            purchasePlayer.prepareToPlay()
        } catch let error as NSError {
            print(error.debugDescription)
        }
        
        //Start Timers
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTotal), userInfo: nil, repeats: true)
        saveTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(savePlayer), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: IBActions and Button Taps
    @IBAction func cookieClick(_ sender: Any) {
        //Play Sound
        popPlayer.play()
        
        //Animate Button
        UIView.animate(withDuration: 0.05, animations: {
            self.cookieButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.05) {
                self.cookieButton.transform = CGAffineTransform.identity
            }
        })
        
        //Update Label
        player!.totalCookies! += player!.cpc!
        cookieCounter.text = "\(player!.totalCookies!) Cookies"
    }
    
    //Reset Button
    @IBAction func resetAction(_ sender: Any) {
        //Warning
        let alert = UIAlertController(title: "Are you sure you want to reset?", message: "All progress will be lost. This is irreversible.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: resetConfirmed))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Save Button
    @IBAction func saveAction(_ sender: Any) {
        savePlayer()
        let alert = UIAlertController(title: "Progress Saved", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Reset Player
    func resetConfirmed(alert: UIAlertAction!) {
        player = Player(cps: 0, cpc: 0.1, totalCookies: 0, upgradesOwned: [Int](repeating: 0, count: 2))
        updateTotal()
        updateCPS()
        updateCPC()
        savePlayer()
    }
    
    //Purchase an Upgrade
    @objc func upgradePurchased(sender: UIButton) {
        //Play Sound
        purchasePlayer.play()
        
        //Update stats based on which button was clicked
        switch sender.tag {
        case 1:
            if player!.totalCookies! >= upgradeOne!.cost! {
                player!.upgradesOwned![0] += 1
                player!.cpc! += upgradeOne!.cpcBoost!
                player!.totalCookies! -= upgradeOne!.cost!
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
        //Update total based on CPS
        player!.totalCookies! += player!.cps!
        cookieCounter!.text = String(format: "%.1f Cookies", player!.totalCookies!)
        
        //Enable or Disable Labels
        if player!.totalCookies! < upgradeOne!.cost! {
            upgradeOneButton.isEnabled = false
        } else {
            upgradeOneButton.isEnabled = true
        }
        
        if player!.totalCookies! < upgradeTwo!.cost! {
            upgradeTwoButton.isEnabled = false
        } else {
            upgradeTwoButton.isEnabled = true
        }
    }
    
    //Update CPC Label
    func updateCPC() {
        cpcLabel!.text = "\(player!.cpc!) CPC"
    }
    
    //Update CPS Label
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
