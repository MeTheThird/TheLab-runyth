//
//  GameScene.swift
//  TheLab-runyth
//
//  Created by Aniruddha Madhusudan on 7/10/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import SpriteKit
import GameplayKit

enum heroMovingState {
    case phasing, reversingEverything, reversingOtherStuff, running
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var hero: SKSpriteNode!
    var cameraNode: SKCameraNode!
    var restartButton: ButtonNode!
    var movingDoorLayer: SKSpriteNode!
    var heroState: heroMovingState = .running
    var phaseCoolDown: CFTimeInterval = 5.0
    var phaseDuration: CFTimeInterval = 0.0
    var heroSpeed: CGFloat = 2.0
    static var level: Int = 1
    
    override func didMove(to view: SKView) {
        hero = childNode(withName: "//hero") as! SKSpriteNode
        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        restartButton = childNode(withName: "//restartButton") as! ButtonNode
        if let mDL = childNode(withName: "movingDoorLayer") as? SKSpriteNode {
            movingDoorLayer = mDL
        }
        
        self.camera = cameraNode
        physicsWorld.contactDelegate = self
        
        let targetX = hero.position.x
        cameraNode.position.x = targetX
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.respondToLongPressGesture))
        longPress.minimumPressDuration = 0.5
        view.addGestureRecognizer(longPress)
        
        restartButton.selectedHandler = {
            guard let scene = GameScene.level(GameScene.level) else {
                print("Bye scene?!?!?!?!?!?!?!?!?!?!?!?!?!?!?!?")
                return
            }
            scene.scaleMode = .aspectFit
            self.view!.presentScene(scene)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        switch heroState {
        case .phasing:
            hero.physicsBody?.categoryBitMask = 0
            hero.physicsBody?.collisionBitMask = 2147483648
            hero.physicsBody?.contactTestBitMask = 0
            hero.position.x += heroSpeed
            hero.alpha = 0.8
            phaseDuration += 1 / 60
        case .running:
            hero.alpha = 1.0
            hero.physicsBody?.categoryBitMask = 1
            hero.physicsBody?.collisionBitMask = 4294967295
            hero.physicsBody?.contactTestBitMask = 1
            hero.position.x += heroSpeed
        case .reversingOtherStuff:
            if movingDoorLayer != nil {
                for i in movingDoorLayer.children {
                    let door = i as! MovingObstacle
                    if let last = door.previousPosition.last {
                        door.position = last
                        door.previousPosition.removeLast()
                    }
                }
            }
        case .reversingEverything:
            heroState = .running
        }
        
        if phaseDuration >= 2.0 {
            heroState = .running
        }
        
        let targetX = hero.position.x
        cameraNode.position.x = targetX
        
        if movingDoorLayer != nil {
            for i in movingDoorLayer.children {
                let door = i as! MovingObstacle
                if heroState != .reversingEverything && heroState != .reversingOtherStuff {
                    door.previousPosition.append(door.position)
                }
                if door.previousPosition.count > 240 {
                    door.previousPosition.remove(at: 0)
                }
                if door.position.y > 0.0 {
                    door.position.y -= 1
                }
            }
        }
        
        phaseCoolDown += 1 / 60
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA: SKPhysicsBody = contact.bodyA
        let contactB: SKPhysicsBody = contact.bodyB
        
        guard let nodeAa = contactA.node, let nodeBb = contactB.node else { return }
        
        let nodeA = nodeAa as! SKSpriteNode
        let nodeB = nodeBb as! SKSpriteNode
        
        let categoryA = contactA.categoryBitMask
        let categoryB = contactB.categoryBitMask
        
        if categoryA == 1 && categoryB == 2 {
            nodeA.parent!.parent!.removeFromParent()
        } else if categoryA == 2 && categoryB == 1 {
            nodeB.parent!.parent!.removeFromParent()
        }
    }
    
    class func level(_ levelNumber: Int) -> GameScene? {
        guard let scene = GameScene(fileNamed: "Level_\(levelNumber)") else {
            return nil
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                heroState = .reversingEverything
            case UISwipeGestureRecognizerDirection.right:
                if phaseCoolDown >= 5.0 {
                    phaseDuration = 0.0
                    phaseCoolDown = 0.0
                    heroState = .phasing
                }
            case UISwipeGestureRecognizerDirection.up:
                self.physicsWorld.gravity = CGVector(dx: 0, dy: 9.8)
            case UISwipeGestureRecognizerDirection.down:
                self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
            default:
                break
            }
        }
    }
    
    func respondToLongPressGesture(gesture: UIGestureRecognizer) {
        
        var end: Bool = false
        
        if let longPressGesture = gesture as? UILongPressGestureRecognizer {
            
            if movingDoorLayer != nil {
                for i in movingDoorLayer.children {
                    let door = i as! MovingObstacle
                    if door.previousPosition.last == nil {
                        end = true
                    }
                }
            }
            
            if longPressGesture.state == .ended {
                print("All is lost")
                heroState = .running
            } else if longPressGesture.state == .began {
                heroState = .reversingOtherStuff
                print("PANIC")
            } else if end {
                heroState = .running
                print("Good, very good. I CAN FEEL YOUR ANGER!")
            }
        }
    }
    
}
