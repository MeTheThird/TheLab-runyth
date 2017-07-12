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
    var play1: ButtonNode!
    var play2: ButtonNode!
//    var play3: ButtonNode!
//    var play4: ButtonNode!
//    var play5: ButtonNode!
//    var play6: ButtonNode!
//    var play7: ButtonNode!
//    var play8: ButtonNode!
    
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        /* Set UI connections */
        play1 = self.childNode(withName: "play1") as! ButtonNode
        play2 = self.childNode(withName: "play2") as! ButtonNode
//        play3 = self.childNode(withName: "play3") as! ButtonNode
//        play4 = self.childNode(withName: "play4") as! ButtonNode
//        play5 = self.childNode(withName: "play5") as! ButtonNode
//        play6 = self.childNode(withName: "play6") as! ButtonNode
//        play7 = self.childNode(withName: "play7") as! ButtonNode
//        play8 = self.childNode(withName: "play8") as! ButtonNode
        
        play1.selectedHandler = {
            self.loadGame(level: 1)
        }
        play2.selectedHandler = {
            self.loadGame(level: 2)
        }
//        play3.selectedHandler = {
//            self.loadGame(level: 3)
//        }
//        play4.selectedHandler = {
//            self.loadGame(level: 4)
//        }
//        play5.selectedHandler = {
//            self.loadGame(level: 5)
//        }
//        play6.selectedHandler = {
//            self.loadGame(level: 6)
//        }
//        play7.selectedHandler = {
//            self.loadGame(level: 7)
//        }
//        play8.selectedHandler = {
//            self.loadGame(level: 8)
//        }
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
        
        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
}
