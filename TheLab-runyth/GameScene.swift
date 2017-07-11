//
//  GameScene.swift
//  TheLab-runyth
//
//  Created by Aniruddha Madhusudan on 7/10/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import SpriteKit
import GameplayKit

func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}

enum heroMovingState {
    case phasing, reversingEverything, reversingOtherStuff, running
}

enum timeMovingState {
    case forward, backward
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var grav = CGVector()
    var hero: SKSpriteNode!
    var heroPrevPos = [CGPoint]()
    var heroPrevState = [heroMovingState]()
    var previousGravity = [CGVector]()
    var cameraNode: SKCameraNode!
    var restartButton: ButtonNode!
    var pauseButton: ButtonNode!
    var playButton: ButtonNode!
    var nextButton: ButtonNode!
    var movingDoorLayer: SKSpriteNode!
    var finalDoor: SKSpriteNode!
    var heroState: heroMovingState = .running
    var timeState: timeMovingState = .forward
    var phaseCoolDown: CFTimeInterval = 0.0
    var phaseDuration: CFTimeInterval = 0.0
    var timeCoolDown: CFTimeInterval = 0.0
    var heroSpeed: CGFloat = 2.0
    var end: Bool = false
    static var level: Int = 1
    
    override func didMove(to view: SKView) {
        hero = childNode(withName: "//hero") as! SKSpriteNode
        finalDoor = childNode(withName: "finalDoor") as! SKSpriteNode
        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        restartButton = childNode(withName: "//restartButton") as! ButtonNode
        pauseButton = childNode(withName: "//pauseButton") as! ButtonNode
        playButton = childNode(withName: "//playButton") as! ButtonNode
        nextButton = childNode(withName: "//nextButton") as! ButtonNode
        if let mDL = childNode(withName: "movingDoorLayer") as? SKSpriteNode {
            movingDoorLayer = mDL
        }
        
        restartButton.state = .hidden
        playButton.state = .hidden
        nextButton.state = .hidden
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
        longPress.minimumPressDuration = 0.3
        longPress.allowableMovement = 0
        view.addGestureRecognizer(longPress)
        
        pauseButton.selectedHandler = {
            self.isPaused = true
            self.restartButton.state = .active
            self.playButton.state = .active
            self.pauseButton.state = .hidden
        }
        
        playButton.selectedHandler = {
            self.restartButton.state = .hidden
            self.playButton.state = .hidden
            self.pauseButton.state = .active
            self.isPaused = false
        }
        
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
        switch timeState {
        case .forward:
            switch heroState {
            case .phasing:
                hero.physicsBody?.categoryBitMask = 0
                hero.physicsBody?.collisionBitMask = 2147483648
                hero.physicsBody?.contactTestBitMask = 0
                hero.position.x += heroSpeed
                hero.alpha = 0.4
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
                timeState = .backward
            }
        case .backward:
            if movingDoorLayer != nil {
                for i in movingDoorLayer.children {
                    let door = i as! MovingObstacle
                    if let last = door.previousPosition.last {
                        door.position = last
                        door.previousPosition.removeLast()
                    }
                }
            }
            if let last = heroPrevPos.last {
                hero.position = last
                heroPrevPos.removeLast()
            }
            if let last = heroPrevState.last {
                heroState = last
                heroPrevState.removeLast()
            }
            if let last = previousGravity.last {
                self.physicsWorld.gravity = last
                previousGravity.removeLast()
                grav = self.physicsWorld.gravity
            }
            if heroState == .phasing {
                hero.physicsBody?.categoryBitMask = 0
                hero.physicsBody?.collisionBitMask = 2147483648
                hero.physicsBody?.contactTestBitMask = 0
                hero.alpha = 0.4
                phaseDuration += 1 / 60
            }
        }
        
        if phaseDuration >= 2.0 {
            if heroState == .phasing {
                heroState = .running
            }
        }
        
        let targetX = hero.position.x
        let x = clamp(value: targetX, lower: targetX, upper: finalDoor.position.x + 12.5 - size.width / 2)
        cameraNode.position.x = x
        
        if movingDoorLayer != nil {
            for i in movingDoorLayer.children {
                let door = i as! MovingObstacle
                if timeState != .backward && heroState != .reversingEverything && heroState != .reversingOtherStuff {
                    door.previousPosition.append(door.position)
                }
                if door.previousPosition.count > 240 {
                    door.previousPosition.remove(at: 0)
                }
                if door.position.y > 0.0 {
                    door.position.y -= 1
                }
                if heroState == .reversingOtherStuff || timeState == .backward {
                    if heroPrevPos.last == nil || door.previousPosition.last == nil{
                        heroState = .running
                        end = true
                        if timeState == .backward {
                            timeState = .forward
                        }
                    }
                }
            }
        }
        
        if timeState != .backward && heroState != .reversingOtherStuff {
            heroPrevPos.append(hero.position)
            heroPrevState.append(heroState)
            previousGravity.append(self.physicsWorld.gravity)
        }
        if heroPrevPos.count > 240 {
            heroPrevPos.remove(at: 0)
            heroPrevState.remove(at: 0)
            previousGravity.remove(at: 0)
        }
        
        if !cameraNode.contains(hero) {
            guard let scene = GameScene.level(GameScene.level) else {
                print("Bye scene?!?!?!?!?!?!?!?!?!?!?!?!?!?!?!?")
                return
            }
            scene.scaleMode = .aspectFit
            self.view!.presentScene(scene)
        }
        
        if heroState == .running && timeState == .forward {
            phaseCoolDown -= 1 / 60
            timeCoolDown -= 1 / 60
        }
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
                if timeCoolDown <= 0.0 {
                    timeCoolDown = 5.0
                    heroState = .reversingEverything
                }
            case UISwipeGestureRecognizerDirection.right:
                if phaseCoolDown <= 0.0 && timeState == .forward {
                    phaseDuration = 0.0
                    phaseCoolDown = 5.0
                    timeState = .forward
                    heroState = .phasing
                }
                if timeState == .backward {
                    timeState = .forward
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
        if let longPressGesture = gesture as? UILongPressGestureRecognizer {
            if !end && longPressGesture.state == .ended {
                print("All is lost")
                heroState = .running
            } else if longPressGesture.state == .began {
                if timeCoolDown <= 0.0 {
                    timeCoolDown = 5.0
                    heroState = .reversingOtherStuff
                    print("PANIC")
                }
            }
        }
    }
    
}
