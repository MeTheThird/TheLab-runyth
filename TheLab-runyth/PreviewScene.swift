//
//  PreviewScene.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/12/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import SpriteKit
import GameplayKit

class PreviewScene: SKScene {
    
    var playLevelButton: ButtonNode!
    var cameraNode: SKCameraNode!
    var finalDoor: SKSpriteNode!
    var moveRight: Bool = false
    var moveLeft: Bool = false
    
    override func didMove(to view: SKView) {
        playLevelButton = childNode(withName: "//playLevelButton") as! ButtonNode
        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        finalDoor = childNode(withName: "finalDoor") as! SKSpriteNode
        
        self.camera = cameraNode
        
        let longRightPress = UILongPressGestureRecognizer(target: self, action: #selector(self.respondToLongPressGesture))
        longRightPress.minimumPressDuration = 0.1
        view.addGestureRecognizer(longRightPress)
        
        
        playLevelButton.selectedHandler = {
            /* 1) Grab reference to our SpriteKit view */
            guard let skView = self.view as SKView! else {
                print("Could not get Skview")
                return
            }
            
            /* 2) Load Game scene */
            guard let scene = GameScene.level(GameScene.level) else {
                print("Could not make GameScene, check the name is spelled correctly")
                return
            }
            
            view.removeGestureRecognizer(longRightPress)
            
            /* Show debug */
            skView.showsPhysics = false
            skView.showsDrawCount = false
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* 4) Start game scene */
            skView.presentScene(scene)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if moveRight {
            if cameraNode.position.x < finalDoor.position.x + 12.5 - size.width / 2 {
                cameraNode.position.x += 10
            }
        }
        if moveLeft {
            if cameraNode.position.x > 0.0 {
                cameraNode.position.x -= 10
            }
        }
    }
    
    func respondToLongPressGesture(gesture: UIGestureRecognizer) {
        if let longPressGesture = gesture as? UILongPressGestureRecognizer {
            let gesturePos = longPressGesture.location(in: self.view)
            if gesturePos.x >= cameraNode.position.x {
                moveRight = true
                moveLeft = false
            } else if gesturePos.x < cameraNode.position.x {
                moveLeft = true
                moveRight = false
            }
            if longPressGesture.state == .ended {
                moveLeft = false
                moveRight = false
            }
        }
    }
}
