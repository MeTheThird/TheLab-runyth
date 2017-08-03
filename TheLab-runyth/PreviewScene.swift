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
    
    var playLevelButton: noAlphaChangeButton!
    var backButton: noAlphaChangeButton!
    var cameraNode: SKCameraNode!
    var finalDoor: SKSpriteNode!
    var treasure: SKSpriteNode!
    var instructionsLabel: SKLabelNode!
    var buttonTapLabel: SKLabelNode!
    var levelRealScene: SKScene!
    
    override func didMove(to view: SKView) {
        guard let theRealGameScene = GameScene.level(GameScene.level) else {
            print("NO NEXT LEVEL FOR YOU!!!")
            return
        }
        levelRealScene = theRealGameScene.scene
        playLevelButton = childNode(withName: "//playLevelButton") as! noAlphaChangeButton
        backButton = childNode(withName: "//backButton") as! noAlphaChangeButton
        cameraNode = childNode(withName: "cameraNodePreview") as! SKCameraNode
        instructionsLabel = childNode(withName: "instructionsLabel") as! SKLabelNode
        buttonTapLabel = childNode(withName: "buttonTapLabel") as! SKLabelNode
        
        physicsWorld.speed = 0
        self.camera = cameraNode
        
        if GameScene.level != 1 {
            instructionsLabel.isHidden = true
            buttonTapLabel.isHidden = true
        }
        
        for node in self.children {
            if let sprite = node as? SKSpriteNode {
                sprite.removeFromParent()
            }
        }
        
        for node in levelRealScene.children {
            if let sprite = node as? SKSpriteNode {
                if node.name != "forShow" {
                    sprite.removeFromParent()
                    self.addChild(sprite)
                }
            }
        }
        
        finalDoor = childNode(withName: "finalDoor") as! SKSpriteNode
        if let movingCeilingDoorLayer = childNode(withName: "movingCeilingDoorLayer") as? SKSpriteNode {
            for node in movingCeilingDoorLayer.children {
                if node.name != "dummyDoor" {
                    node.position.y -= 75
                    let arrow = SKSpriteNode(texture: SKTexture(imageNamed: "arrow.png"))
                    self.addChild(arrow)
                    arrow.zRotation = -CGFloat.pi / 2
                    arrow.position = CGPoint(x: movingCeilingDoorLayer.convert(node.position, to: self).x, y: 0)
                }
            }
        }
        if let movingGroundDoorLayer = childNode(withName: "movingGroundDoorLayer") as? SKSpriteNode {
            for node in movingGroundDoorLayer.children {
                node.position.y += 75
                let arrow = SKSpriteNode(texture: SKTexture(imageNamed: "arrow.png"))
                self.addChild(arrow)
                arrow.zRotation = CGFloat.pi / 2
                arrow.position = CGPoint(x: movingGroundDoorLayer.convert(node.position, to: self).x, y: 0)
            }
        }
        
        if GameScene.level > 7 {
            treasure = childNode(withName: "treasure") as! SKSpriteNode
            treasure.alpha = 1.0
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.respondToPanGesture))
        panGesture.minimumNumberOfTouches = 1
        view.addGestureRecognizer(panGesture)
        
        playLevelButton.selectedHandler = { [unowned self, unowned view] in
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
            GameScene.startLogged = false
            
            /* Show debug */
            skView.showsPhysics = false
            skView.showsDrawCount = false
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* 4) Start game scene */
            skView.presentScene(scene)
        }
        
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
    
    func respondToPanGesture(gesture: UIGestureRecognizer) {
        if let gestureOfPan = gesture as? UIPanGestureRecognizer {
            let targetX = cameraNode.position.x - 0.03*gestureOfPan.velocity(in: self.view!).x
            let x = clamp(value: targetX, lower: 0, upper: finalDoor.position.x + 12.5 - size.width / 2)
            cameraNode.position.x = x
        }
    }
}
