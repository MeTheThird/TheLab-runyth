//
//  WinScreen.swift
//  TheLabyrunth
//
//  Created by Aniruddha Madhusudan on 8/3/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import Foundation
import SpriteKit

class WinScreen: SKScene {
    
    var backButton: noAlphaChangeButton!
    
    override func didMove(to view: SKView) {
        backButton = childNode(withName: "//backButton") as! noAlphaChangeButton
        
        backButton.selectedHandler = { [unowned self] in
            guard let skView = self.view as SKView! else {
                print("Could not get Skview")
                return
            }
            
            guard let scene = GameScene(fileNamed: "LevelSelect") else {
                print("no Level Select... :(")
                return
            }
            
            scene.scaleMode = .aspectFit
            skView.presentScene(scene)
        }
    }
}
