//
//  ViewController.swift
//  Idle Clicker
//
//  Created by Christopher Rosenblatt on 5/31/18.
//  Copyright © 2018 crosenblatt. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load
        player = Player()
        
        upgradeOne = Upgrade(cps: 0.0, cpc: 1.0, price: 2.0)
        upgradeTwo = Upgrade(cps: 1.0, cpc: 0.0, price: 5.0)
        
        upgradeOneButton.tag = 1
        upgradeTwoButton.tag = 2
        
        upgradeOneButton.addTarget(self, action: #selector(upgradePurchased), for: UIControlEvents.touchUpInside)
        upgradeTwoButton.addTarget(self, action: #selector(upgradePurchased), for: UIControlEvents.touchUpInside)
        
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTotal), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: IBActions and Button Taps
    @IBAction func cookieClick(_ sender: Any) {
        player!.totalCookies! += player!.cpc!
        cookieCounter.text = "\(player!.totalCookies!) Cookies"
    }
    
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
    
}

//MARK: Extra Classes
class Player {
    var cps:Float?
    var cpc:Float?
    var totalCookies:Float?
    var upgradesOwned:[Int]?
    
    init() {
        cps = 0
        cpc = 0.1
        totalCookies = 0
        upgradesOwned = [Int](repeating: 0, count: 2)
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
