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
    case phasing, reversingEverything, reversingOtherStuff, running, stationary
}

enum timeMovingState {
    case forward, backward
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var hero: SKSpriteNode!
    var heroPrevPos = [CGPoint]()
    var heroPrevState = [heroMovingState]()
    var previousGravity = [CGVector]()
    var phaseCool: SKLabelNode!
    var timeCool: SKLabelNode!
    var cameraNode: SKCameraNode!
    var restartButton: ButtonNode!
    var pauseButton: ButtonNode!
    var playButton: ButtonNode!
    var nextButton: ButtonNode!
    var movingDoorLayer: SKSpriteNode!
    var chainGroundSpikeLayer: SKSpriteNode!
    var finalDoor: SKSpriteNode!
    var ground: SKSpriteNode!
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
        phaseCool = childNode(withName: "//phaseCool") as! SKLabelNode
        timeCool = childNode(withName: "//timeCool") as! SKLabelNode
        ground = childNode(withName: "ground") as! SKSpriteNode
        if let mDL = childNode(withName: "movingDoorLayer") as? SKSpriteNode {
            movingDoorLayer = mDL
        }
        if let cSL = childNode(withName: "chainGroundSpikeLayer") as? SKSpriteNode {
            chainGroundSpikeLayer = cSL
            for spike in chainGroundSpikeLayer.children {
                var pinLocation = spike.children[0].position
                pinLocation.y += 20
                let spikeJoint = SKPhysicsJointPin.joint(withBodyA: spike.physicsBody!, bodyB: spike.children[0].physicsBody!, anchor: pinLocation)
                physicsWorld.add(spikeJoint)
                
                var pin2Location = spike.children[0].position
                pin2Location.y -= 20
                let spikeJoint2 = SKPhysicsJointPin.joint(withBodyA: ground.physicsBody!, bodyB: spike.children[0].physicsBody!, anchor: pin2Location)
                physicsWorld.add(spikeJoint2)
            }
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
            self.view!.presentScene(scene)
        }
        
        nextButton.selectedHandler = {
            guard let scene = GameScene.levelPreview(GameScene.level + 1) else {
                print("NO NEXT LEVEL FOR YOU!!!")
                return
            }
            GameScene.level += 1
            view.removeGestureRecognizer(longPress)
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
                break
            case .running:
                hero.alpha = 1.0
                hero.physicsBody?.categoryBitMask = 1
                hero.physicsBody?.collisionBitMask = 4294967295
                hero.physicsBody?.contactTestBitMask = 1
                hero.position.x += heroSpeed
                break
            case .reversingOtherStuff:
                moveObstacleBackInTime()
            case .reversingEverything:
                timeState = .backward
            default:
                break
            }
        case .backward:
            moveObstacleBackInTime()
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
            }
            if heroState == .phasing {
                hero.physicsBody?.categoryBitMask = 0
                hero.physicsBody?.collisionBitMask = 2147483648
                hero.physicsBody?.contactTestBitMask = 0
                hero.alpha = 0.4
                phaseDuration += 1 / 60
            }
        }
        
        if phaseDuration >= 1.0 {
            if heroState == .phasing {
                heroState = .running
            }
        }
        
        let targetX = hero.position.x
        let x = clamp(value: targetX, lower: targetX, upper: finalDoor.position.x + 12.5 - size.width / 2)
        cameraNode.position.x = x
        
        updatePreviousMovingObstaclePositions()
        
        updatePreviousHeroPositions()
        
        checkIfHeroIsDEAD()
        
        updateCooldowns()
        
        checkIfLevelIsBEATEN()
        
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
    
    class func levelPreview(_ levelNumber: Int) -> GameScene? {
        guard let scene = GameScene(fileNamed: "Level_\(levelNumber)_Preview") else {
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
    

    func moveObstacleBackInTime() {
        if movingDoorLayer != nil {
            for i in movingDoorLayer.children {
                let door = i as! MovingObstacle
                if let last = door.previousPosition.last {
                    door.position = last
                    door.previousPosition.removeLast()
                }
            }
        }
        if chainGroundSpikeLayer != nil {
            for i in chainGroundSpikeLayer.children {
                let chainSpike = i as! MovingObstacle
                if let last = chainSpike.previousPosition.last {
                    chainSpike.position = last
                    chainSpike.previousPosition.removeLast()
                }
            }
        }
    }
    
    func updatePreviousMovingObstaclePositions() {
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
        
        if chainGroundSpikeLayer != nil {
            for i in chainGroundSpikeLayer.children {
                let spike = i as! MovingObstacle
                if timeState != .backward && heroState != .reversingEverything && heroState != .reversingOtherStuff {
                    spike.previousPosition.append(spike.position)
                }
                if spike.previousPosition.count > 240 {
                    spike.previousPosition.remove(at: 0)
                }
            }
        }
    }
    
    func updatePreviousHeroPositions() {
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
    }
    
    func checkIfHeroIsDEAD() {
        if !cameraNode.contains(hero) {
            guard let scene = GameScene.level(GameScene.level) else {
                print("Bye scene?!?!?!?!?!?!?!?!?!?!?!?!?!?!?!?")
                return
            }
            scene.scaleMode = .aspectFit
            self.view!.presentScene(scene)
        }
    }
    
    func updateCooldowns() {
        if heroState == .running && timeState == .forward {
            phaseCoolDown -= 1 / 60
            timeCoolDown -= 1 / 60
        }
        
        if phaseCoolDown <= 0.0 {
            phaseCool.text = "Phase: 0.0"
        } else {
            phaseCool.text = String(format: "Phase: %.1f", phaseCoolDown)
        }
        
        if timeCoolDown <= 0.0 {
            timeCool.text = "Time: 0.0"
        } else {
            timeCool.text = String(format: "Time: %.1f", timeCoolDown)
        }
    }
    
    func checkIfLevelIsBEATEN() {
        let heroPos = hero.convert(CGPoint(x: 0, y: 0), to: self)
        
        if heroPos.x >= finalDoor.position.x {
            nextButton.state = .active
            heroState = .stationary
        }
    }
}
