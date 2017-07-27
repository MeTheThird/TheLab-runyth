//
//  TheShop.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/25/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import SpriteKit

class TheShop: SKScene {
    
    var phasingCharacter: SKSpriteNode!
    var phaseUpgradeButton: TheShopUpgradeButton!
    var timeUpgradeButton: TheShopUpgradeButton!
    var moneyLabel: SKLabelNode!
    var backButton: ButtonNode!
    var phasingAnimationSequence: SKAction! = nil
    var phasingCharInitialPosition: CGPoint! = nil
    static var managerOfCurrency = currencyManager()
    
    // add time reversal animation - maybe a falling securtiy door, and the hero comes in and reverses it?
    // Also, make the phasing SKAction better - currently it moves, then fades after it's done moving - because of sequence
    // Every level has a chance of containing a treasure chest - buy upgrades/spend money to increase chance - need super expensive/cool item that ppl want to buy - maybe have something that costs money and gives 100 coins every day a user logs on for the next 30 days
    // Increase price of upgrades - use label text
    
    override func didMove(to view: SKView) {
        phasingCharacter = childNode(withName: "phasingCharacter") as! SKSpriteNode
        phasingCharInitialPosition = phasingCharacter.position
        
        phaseUpgradeButton = childNode(withName: "phaseUpgradeButton") as! TheShopUpgradeButton
        timeUpgradeButton = childNode(withName: "timeUpgradeButton") as! TheShopUpgradeButton
        moneyLabel = childNode(withName: "moneyLabel") as! SKLabelNode
        backButton = childNode(withName: "backButton") as! ButtonNode
        
        phaseUpgradeButton.selectedHandler = {
            if TheShop.managerOfCurrency.currency >= 10 {
                if GameScene.phaseDurationMax < 2.0 {
                    GameScene.phaseDurationMax += 0.125
                    TheShop.managerOfCurrency.addToCurrency(amount: -10)
                    print("increased phase")
                } else {
                    print("NO PHASE UPGRADE FOR YOU!!!")
                }
            } else {
                print("YOUR LIFESTYLE'S HIIIIIIGH, BUT YOUR FUNDS ARE LOOOOOOW :(")
            }
        }
        
        timeUpgradeButton.selectedHandler = {
            if TheShop.managerOfCurrency.currency >= 10 {
                if GameScene.framesBack < 180 {
                    GameScene.framesBack += 5
                    TheShop.managerOfCurrency.addToCurrency(amount: -10)
                    print("Greater time abilities hath been granted to thee.")
                } else {
                    print("THOU SHALT NOT OBTAIN TIME ABILITIES MORE POWERFUL THAN MINE!!!")
                }
            } else {
                print("YOUR LIFESTYLE'S HIIIIIIGH, BUT YOUR FUNDS ARE LOOOOOOW :(")
            }
        }
        
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
        
        phasingAnimationSequence = SKAction.sequence([SKAction.move(to: CGPoint(x: phasingCharacter.position.x + 100, y: phasingCharacter.position.y), duration: 1), SKAction.fadeAlpha(to: 0.2, duration: 1), SKAction.move(to: phasingCharInitialPosition, duration: 1), SKAction.fadeAlpha(to: 1.0, duration: 1)])
    }
    
    override func update(_ currentTime: TimeInterval) {
        if phasingCharacter.alpha >= 1.0 {
            phasingCharacter.run(phasingAnimationSequence)
            phasingCharacter.alpha = 0.9
        }
        
        moneyLabel.text = "\(TheShop.managerOfCurrency.currency)"
    }
}
