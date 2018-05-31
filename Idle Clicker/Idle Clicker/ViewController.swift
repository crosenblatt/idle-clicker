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
    
    //MARK: Properties
    var player:Player?
    var upgradeOne:Upgrade?
    var upgradeTwo:Upgrade?
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player = Player()
        print("player loaded")
        upgradeOne = Upgrade(cps: 0.0, cpc: 1.0, price: 2)
        upgradeTwo = Upgrade(cps: 1.0, cpc: 0.0, price: 5)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTotal), userInfo: nil, repeats: true)
        print("timer started")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: IBActions
    @IBAction func cookieClick(_ sender: Any) {
        player!.totalCookies! += player!.cpc!
        cookieCounter.text = "\(player!.totalCookies!) Cookies"
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
    
    init() {
        cps = 0
        cpc = 0.1
        totalCookies = 0
    }
}

class Upgrade {
    var cpsBoost:Float?
    var cpcBoost:Float?
    var cost:Int?
    
    init(cps: Float, cpc: Float, price: Int) {
        cpsBoost = cps
        cpcBoost = cpc
        cost = price
    }
}
