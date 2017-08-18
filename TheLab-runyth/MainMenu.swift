//
//  MainMenu.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/24/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    
    var playButton: noAlphaChangeButton!
    var theShopButton: noAlphaChangeButton!
    var bonusLayer: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        playButton = childNode(withName: "playButton") as! noAlphaChangeButton
        theShopButton = childNode(withName: "theShopButton") as! noAlphaChangeButton
        bonusLayer = childNode(withName: "bonusLayer") as! SKSpriteNode
        
        LevelSelect.beatenLevelManager.beatenLevels.removeAll()
        
        LevelSelect.beatenLevelManager.lastLevelBeatenNumber = 0
        
        if LevelSelect.beatenLevelManager.beatenLevels.contains(levelBeat(levelNum: 21, treasureCollected: nil)) {
            bonusLayer.alpha = 1.0
        }
        
        playButton.selectedHandler = { [unowned self] in
            guard let skView = self.view as SKView! else {
                print("Could not get Skview")
                return
            }
            
            guard let scene = LevelSelect(fileNamed: "LevelSelect") else {
                print("no level select...")
                return
            }
            
            scene.scaleMode = .aspectFit
            skView.presentScene(scene)
        }
        
        theShopButton.selectedHandler = { [unowned self] in
            guard let skView = self.view as SKView! else {
                print("Could not get Skview")
                return
            }
            
            guard let scene = GameScene(fileNamed: "TheShop") else {
                print("NO SHOP! WHAT AN INSULT! but seriously, there's no place to splurge :(")
                return
            }
            
            scene.scaleMode = .aspectFit
            skView.presentScene(scene)
        }
    }
}
