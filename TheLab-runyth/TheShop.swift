//
//  TheShop.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/25/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import SpriteKit

class TheShop: SKScene {
    
    var moneyLabel: SKLabelNode!
    var backButton: ButtonNode!
    static var managerOfCurrency = currencyManager()
    
    // logo = char phasing? (no animation for the logo) - 0.2 alpha, 0.6, 1.0???
    // Every level has a chance of containing a treasure chest - buy upgrades/spend money to increase chance - need super expensive/cool item that ppl want to buy - maybe have something that costs money and gives 100 coins every day a user logs on for the next 30 days
    // super expensive price: 3333 - buy new char? - also have requirements on the level number that had to have been beaten
    // If treasure collected for a beaten level, halve the chance of treasure appearing - original: 5%, after beaten with treasure: 2.5%
    
    override func didMove(to view: SKView) {
        moneyLabel = childNode(withName: "moneyLabel") as! SKLabelNode
        backButton = childNode(withName: "backButton") as! ButtonNode
        
        backButton.selectedHandler = { [unowned self] in
            guard let skView = self.view as SKView! else {
                print("Could not get Skview")
                return
            }
            
            guard let scene = GameScene(fileNamed: "MainMenu") else {
                print("no Main menu... :(")
                return
            }
            
            scene.scaleMode = .aspectFit
            skView.presentScene(scene)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if moneyLabel.text != "\(TheShop.managerOfCurrency.currency)" {
            moneyLabel.text = "\(TheShop.managerOfCurrency.currency)"
        }
    }
}
