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
    var movingCeilingDoorLayer: SKSpriteNode!
    var levelRealScene: SKScene!
//    var moveRight: Bool = false
//    var moveLeft: Bool = false
    
    override func didMove(to view: SKView) {
        levelRealScene = GameScene.level(GameScene.level)!.scene
        playLevelButton = childNode(withName: "//playLevelButton") as! ButtonNode
        cameraNode = childNode(withName: "cameraNodePreview") as! SKCameraNode
        physicsWorld.speed = 0
        self.camera = cameraNode
        
        for node in levelRealScene.children {
            if let sprite = node as? SKSpriteNode {
                sprite.removeFromParent()
                self.addChild(sprite)
            }
        }
        finalDoor = childNode(withName: "finalDoor") as! SKSpriteNode
        if let mDL = childNode(withName: "movingCeilingDoorLayer") as? SKSpriteNode {
            movingCeilingDoorLayer = mDL
            for node in movingCeilingDoorLayer.children {
                let arrow = SKSpriteNode(texture: SKTexture(imageNamed: "arrow.png"))
                self.addChild(arrow)
                arrow.zRotation = -CGFloat.pi / 2
                arrow.position = CGPoint(x: movingCeilingDoorLayer.convert(node.position, to: self).x, y: 0)
            }
        }
        
//        let longRightPress = UILongPressGestureRecognizer(target: self, action: #selector(self.respondToLongPressGesture))
//        longRightPress.minimumPressDuration = 0.1
//        view.addGestureRecognizer(longRightPress)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.respondToPanGesture))
        panGesture.minimumNumberOfTouches = 1
        view.addGestureRecognizer(panGesture)
        
        playLevelButton.selectedHandler = { [unowned self] in
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
            
            view.gestureRecognizers?.removeAll()
            
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
//        if moveRight {
//            if cameraNode.position.x < finalDoor.position.x + 12.5 - size.width / 2 {
//                cameraNode.position.x += 10
//            }
//        }
//        if moveLeft {
//            if cameraNode.position.x > 0.0 {
//                cameraNode.position.x -= 10
//            }
//        }
    }
    
    func respondToPanGesture(gesture: UIGestureRecognizer) {
        if let gestureOfPan = gesture as? UIPanGestureRecognizer {
            let targetX = cameraNode.position.x - 0.03*gestureOfPan.velocity(in: self.view!).x
            let x = clamp(value: targetX, lower: 0, upper: finalDoor.position.x + 12.5 - size.width / 2)
            cameraNode.position.x = x
        }
    }
    
//    func respondToLongPressGesture(gesture: UIGestureRecognizer) {
//        if let longPressGesture = gesture as? UILongPressGestureRecognizer {
//            let gesturePos = longPressGesture.location(in: self.view)
//            if gesturePos.x >= cameraNode.position.x {
//                moveRight = true
//                moveLeft = false
//            } else if gesturePos.x < cameraNode.position.x {
//                moveLeft = true
//                moveRight = false
//            }
//            if longPressGesture.state == .ended {
//                moveLeft = false
//                moveRight = false
//            }
//        }
//    }
}
