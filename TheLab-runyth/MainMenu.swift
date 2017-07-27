//
//  MainMenu.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/24/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    var playButton: ButtonNode!
    var settingsButton: ButtonNode!
    var theShopButton: ButtonNode!
    
    override func didMove(to view: SKView) {
        playButton = childNode(withName: "playButton") as! ButtonNode
        settingsButton = childNode(withName: "settingsButton") as! ButtonNode
        theShopButton = childNode(withName: "theShopButton") as! ButtonNode
        
        playButton.selectedHandler = { [unowned self] in
            guard let skView = self.view as SKView! else {
                print("Could not get Skview")
                return
            }
            
            guard let scene = GameScene(fileNamed: "LevelSelect") else {
                print("no level select...")
                return
            }
            
            scene.scaleMode = .aspectFit
            skView.presentScene(scene)
        }
        
        settingsButton.selectedHandler = {
            print("TEEHEE")
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
