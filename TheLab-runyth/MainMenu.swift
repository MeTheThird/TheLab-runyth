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
    var levelsButton: ButtonNode!
    
    override func didMove(to view: SKView) {
        playButton = childNode(withName: "playButton") as! ButtonNode
        settingsButton = childNode(withName: "settingsButton") as! ButtonNode
        levelsButton = childNode(withName: "levelsButton") as! ButtonNode
        
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
        
        levelsButton.selectedHandler = { [unowned self] in
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
    }
}
