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
    var phaseUpgradeButton: ButtonNode!
    var timeUpgradeButton: ButtonNode!
    var phasingAnimationSequence: SKAction! = nil
    var phasingCharInitialPosition: CGPoint! = nil
    
    // add time reversal animation - maybe a falling securtiy door, and the hero comes in and reverses it?
    // Also, make the phasing SKAction better - currently it moves, then fades after it's done moving - because of sequence
    
    override func didMove(to view: SKView) {
        phasingCharacter = childNode(withName: "phasingCharacter") as! SKSpriteNode
        phasingCharInitialPosition = phasingCharacter.position
        
        phaseUpgradeButton = childNode(withName: "phaseUpgradeButton") as! ButtonNode
        timeUpgradeButton = childNode(withName: "timeUpgradeButton") as! ButtonNode
        
        phaseUpgradeButton.selectedHandler = {
            if GameScene.phaseDurationMax < 2.0 {
                GameScene.phaseDurationMax += 0.25
                print("increased phase")
            } else {
                print("NO PHASE UPGRADE FOR YOU!!!")
            }
        }
        
        timeUpgradeButton.selectedHandler = {
            if GameScene.framesBack < 180 {
                GameScene.framesBack += 10
                print("Greater time abilities hath been granted to thee.")
            } else {
                print("THOU SHALT NOT OBTAIN TIME ABILITIES MORE POWERFUL THAN MINE!!!")
            }
        }
        
        phasingAnimationSequence = SKAction.sequence([SKAction.move(to: CGPoint(x: phasingCharacter.position.x + 100, y: phasingCharacter.position.y), duration: 1), SKAction.fadeAlpha(to: 0.2, duration: 1), SKAction.move(to: phasingCharInitialPosition, duration: 1), SKAction.fadeAlpha(to: 1.0, duration: 1)])
    }
    
    override func update(_ currentTime: TimeInterval) {
        if phasingCharacter.alpha >= 1.0 {
            phasingCharacter.run(phasingAnimationSequence)
            phasingCharacter.alpha = 0.9
        }
    }
}
