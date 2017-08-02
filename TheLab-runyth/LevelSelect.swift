//
//  LevelSelect.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/11/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import SpriteKit

class LevelSelect: SKScene {
    
    /* UI Connections */
    var levelSelectButtonLayer: SKSpriteNode!
    var backButton: noAlphaChangeButton!
    var numOfLevels = 13
    static var beatenLevelManager = levelBeatManager()
    static var previousFileName: String = "MainMenu"
    
    
    override func didMove(to view: SKView) {
        levelSelectButtonLayer = childNode(withName: "levelSelectButtonLayer") as! SKSpriteNode
        backButton = childNode(withName: "backButton") as! noAlphaChangeButton
        
        print(numOfLevels)
        
        for i in 1...numOfLevels {
            if !LevelSelect.beatenLevelManager.beatenLevels.contains(levelBeat(levelNum: i, treasureCollected: nil)) {
                // display lock on level -- after new buttons and stuff
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
        
        for a in levelSelectButtonLayer.children {
            let button = a as! LevelSelectButton
            button.selectedHandler = { [unowned self, unowned button] in
                print(LevelSelect.beatenLevelManager.lastLevelBeatenNumber)
                if LevelSelect.beatenLevelManager.beatenLevels.contains(levelBeat(levelNum: button.number, treasureCollected: nil)) || button.number == LevelSelect.beatenLevelManager.lastLevelBeatenNumber + 1 {
                    self.loadGame(level: button.number)
                }
            }
        }
        
    }
    
    func loadGame(level: Int) {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = GameScene.levelPreview(level) else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        GameScene.level = level
        LevelSelect.previousFileName = "Level_\(level)"
        
        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
}
