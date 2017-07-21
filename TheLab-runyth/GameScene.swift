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
    var levelSelectButton: ButtonNode!
    var pauseButton: ButtonNode!
    var playButton: ButtonNode!
    var nextButton: ButtonNode!
    var movingCeilingDoorLayer: SKSpriteNode!
    var movingGroundDoorLayer: SKSpriteNode!
    var chainGroundSpikeLayer: SKSpriteNode!
    var evilScientistLayer: SKSpriteNode!
    var finalDoor: SKSpriteNode!
    var ground: SKSpriteNode!
    var heroState: heroMovingState = .running
    var timeState: timeMovingState = .forward
    var phaseCoolDown: CFTimeInterval = 0.0
    var phaseDuration: CFTimeInterval = 0.0
    var timeCoolDown: CFTimeInterval = 0.0
    var timeSinceESShot: CFTimeInterval = 1.0
    var dateReversalStarted: Date = Date()
    var timeReversed: TimeInterval = 0.0
    var enemyBullets = [Bullet]()
    var recentlyRemovedBullets = [Bullet]()
    let framesBack: Int = 150
    var heroSpeed: CGFloat = 2.0
    var end: Bool = false
    var notMoved: Bool = true
    static var level: Int = 1
    
    override func didMove(to view: SKView) {
        hero = childNode(withName: "//hero") as! SKSpriteNode
        finalDoor = childNode(withName: "finalDoor") as! SKSpriteNode
        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        restartButton = childNode(withName: "//restartButton") as! ButtonNode
        levelSelectButton = childNode(withName: "//levelSelectButton") as! ButtonNode
        pauseButton = childNode(withName: "//pauseButton") as! ButtonNode
        playButton = childNode(withName: "//playButton") as! ButtonNode
        nextButton = childNode(withName: "//nextButton") as! ButtonNode
        phaseCool = childNode(withName: "//phaseCool") as! SKLabelNode
        timeCool = childNode(withName: "//timeCool") as! SKLabelNode
        ground = childNode(withName: "ground") as! SKSpriteNode
        if let mCDL = childNode(withName: "movingCeilingDoorLayer") as? SKSpriteNode {
            movingCeilingDoorLayer = mCDL
        }
        if let mGDL = childNode(withName: "movingGroundDoorLayer") as? SKSpriteNode {
            movingGroundDoorLayer = mGDL
        }
        if let eSL = childNode(withName: "evilScientistLayer") as? SKSpriteNode {
            evilScientistLayer = eSL
        }
        if let cSL = childNode(withName: "chainGroundSpikeLayer") as? SKSpriteNode {
            chainGroundSpikeLayer = cSL
            var spike: SKSpriteNode
            for reference in chainGroundSpikeLayer.children {
                spike = reference.children[0].children[0] as! MovingObstacle
                let chainTop = spike.childNode(withName: "chainTop") as! SKSpriteNode
                let chainMid = spike.childNode(withName: "chainMid") as! SKSpriteNode
                let chainBot = spike.childNode(withName: "chainBot") as! SKSpriteNode
                
                var groundPinLocation = chainBot.position
                groundPinLocation.x += 12.374
                groundPinLocation.y -= 15.91
                groundPinLocation = spike.convert(groundPinLocation, to: self)
                let groundPinJoint = SKPhysicsJointPin.joint(withBodyA: ground.physicsBody!, bodyB: chainBot.physicsBody!, anchor: groundPinLocation)
                physicsWorld.add(groundPinJoint)
                
                var botMidPinLocation = chainMid.position
                botMidPinLocation.y -= 15.91
                botMidPinLocation.x -= 12.374
                botMidPinLocation = spike.convert(botMidPinLocation, to: self)
                let botMidPinJoint = SKPhysicsJointPin.joint(withBodyA: chainMid.physicsBody!, bodyB: chainBot.physicsBody!, anchor: botMidPinLocation)
                physicsWorld.add(botMidPinJoint)
                
                var midTopPinLocation = chainTop.position
                midTopPinLocation.y -= 15.91
                midTopPinLocation.x += 12.374
                midTopPinLocation = spike.convert(midTopPinLocation, to: self)
                let midTopPinJoint = SKPhysicsJointPin.joint(withBodyA: chainMid.physicsBody!, bodyB: chainTop.physicsBody!, anchor: midTopPinLocation)
                physicsWorld.add(midTopPinJoint)
                
                var spikePinLocation = chainTop.position
                spikePinLocation.y += 15.91
                spikePinLocation.x -= 12.374
                spikePinLocation = spike.convert(spikePinLocation, to: self)
                let spikePinJoint = SKPhysicsJointPin.joint(withBodyA: spike.physicsBody!, bodyB: chainTop.physicsBody!, anchor: spikePinLocation)
                physicsWorld.add(spikePinJoint)
            }
        }
        
        
        restartButton.state = .hidden
        levelSelectButton.state = .hidden
        playButton.state = .hidden
        nextButton.state = .hidden
        self.camera = cameraNode
        physicsWorld.contactDelegate = self
        
//        let targetX = hero.position.x
//        cameraNode.position.x = targetX
        
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
        longPress.minimumPressDuration = 0.2
        view.addGestureRecognizer(longPress)
        
        pauseButton.selectedHandler = { [unowned self] in
            self.isPaused = true
            self.restartButton.state = .active
            self.levelSelectButton.state = .active
            self.playButton.state = .active
            self.pauseButton.state = .hidden
            view.gestureRecognizers?.removeAll()
        }
        
        playButton.selectedHandler = { [unowned self] in
            self.restartButton.state = .hidden
            self.levelSelectButton.state = .hidden
            self.playButton.state = .hidden
            self.pauseButton.state = .active
            self.isPaused = false
            view.addGestureRecognizer(swipeRight)
            view.addGestureRecognizer(swipeLeft)
            view.addGestureRecognizer(swipeUp)
            view.addGestureRecognizer(swipeDown)
            view.addGestureRecognizer(longPress)
        }
        
        restartButton.selectedHandler = { [unowned self] in
            guard let scene = GameScene.level(GameScene.level) else {
                print("Bye scene?!?!?!?!?!?!?!?!?!?!?!?!?!?!?!?")
                return
            }
            view.gestureRecognizers?.removeAll()
            scene.scaleMode = .aspectFit
            scene.notMoved = false
            self.view!.presentScene(scene)
        }
        
        nextButton.selectedHandler = { [unowned self] in
            guard let _ = GameScene.level(GameScene.level + 1) else {
                print("NO NEXT LEVEL FOR YOU!!!")
                return
            }
            GameScene.level += 1
            let scene = GameScene.levelPreview(GameScene.level + 1)!
            view.gestureRecognizers?.removeAll()
            scene.scaleMode = .aspectFit
            self.view!.presentScene(scene)
        }
        
        levelSelectButton.selectedHandler = { [unowned self] in
            guard let scene = GameScene(fileNamed: "LevelSelect") else {
                print("Bye level select!?!?!?!?!?!?!?!?!?!?!?!?!?!?")
                return
            }
            view.gestureRecognizers?.removeAll()
            scene.scaleMode = .aspectFit
            self.view!.presentScene(scene)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if !notMoved {
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
        }
        
        if phaseDuration >= 1.0 {
            if heroState == .phasing {
                heroState = .running
            }
        }
        
        let targetX = hero.position.x
        let x = clamp(value: targetX, lower: targetX, upper: finalDoor.position.x + finalDoor.size.width / 2 - size.width / 2)
        cameraNode.position.x = x
        
        updatePreviousMovingObstaclePositions()
        
        updatePreviousHeroPositions()
        
        evilScientistsShoot()
        
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
        
        let removal = SKAction.removeFromParent()
        
        if categoryA == 1 && categoryB == 2 {
            nodeA.parent!.parent!.run(removal)
        } else if categoryA == 2 && categoryB == 1 {
            nodeB.parent!.parent!.run(removal)
        } else if categoryA == 1 && categoryB == 4 {
            nodeA.parent!.parent!.run(removal)
            let bullet = nodeB as! Bullet
            bullet.timeWhenDeleted = Date()
            enemyBullets.remove(at: enemyBullets.index(of: bullet)!)
            recentlyRemovedBullets.append(bullet)
            nodeB.run(removal)
        } else if categoryA == 4 && categoryB == 1 {
            let bullet = nodeA as! Bullet
            bullet.timeWhenDeleted = Date()
            nodeB.parent!.parent!.run(removal)
            enemyBullets.remove(at: enemyBullets.index(of: bullet)!)
            recentlyRemovedBullets.append(bullet)
            nodeA.run(removal)
        } else if categoryA == 4 {
            let bullet = nodeA as! Bullet
            bullet.timeWhenDeleted = Date()
            enemyBullets.remove(at: enemyBullets.index(of: bullet)!)
            recentlyRemovedBullets.append(bullet)
            nodeA.run(removal)
        } else if categoryB == 4 {
            let bullet = nodeB as! Bullet
            bullet.timeWhenDeleted = Date()
            enemyBullets.remove(at: enemyBullets.index(of: bullet)!)
            recentlyRemovedBullets.append(bullet)
            nodeB.run(removal)
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
        guard let scene = GameScene(fileNamed: "PreviewScene") else {
            return nil
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if notMoved {
                notMoved = false
            }
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                if timeCoolDown <= 0.0 {
                    timeCoolDown = 5.0
                    heroState = .reversingEverything
                    dateReversalStarted = Date()
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
                if heroState != .stationary {
                    self.physicsWorld.gravity = CGVector(dx: 0, dy: 9.8)
                }
            case UISwipeGestureRecognizerDirection.down:
                if heroState != .stationary {
                    self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
                }
            default:
                break
            }
        }
    }
    
    func respondToLongPressGesture(gesture: UIGestureRecognizer) {
        if let longPressGesture = gesture as? UILongPressGestureRecognizer {
            if notMoved {
                notMoved = false
            }
            if !end && longPressGesture.state == .ended {
                heroState = .running
            } else if longPressGesture.state == .began {
                if timeCoolDown <= 0.0 {
                    timeCoolDown = 5.0
                    heroState = .reversingOtherStuff
                    dateReversalStarted = Date()
                }
            }
        }
    }
    
    
    func moveObstacleBackInTime() {
        timeReversed = Date().timeIntervalSince(dateReversalStarted)
        if movingCeilingDoorLayer != nil {
            for i in movingCeilingDoorLayer.children {
                let door = i as! MovingObstacle
                if let last = door.previousPosition.last {
                    door.position = last
                    door.previousPosition.removeLast()
                }
            }
        }
        if movingGroundDoorLayer != nil {
            for i in movingGroundDoorLayer.children {
                let door = i as! MovingObstacle
                if let last = door.previousPosition.last {
                    door.position = last
                    door.previousPosition.removeLast()
                }
            }
        }
        if chainGroundSpikeLayer != nil {
            for i in chainGroundSpikeLayer.children {
                let chainSpike = i.children[0].children[0] as! MovingObstacle
                if let last = chainSpike.previousPosition.last {
                    chainSpike.position = last
                    chainSpike.previousPosition.removeLast()
                }
            }
        }
        if evilScientistLayer != nil {
            for a in evilScientistLayer.children {
                let scientist = a as! MovingObstacle
                if let last = scientist.previousPosition.last {
                    scientist.position = last
                    scientist.previousPosition.removeLast()
                }
            }
            for bullet in enemyBullets {
                if bullet.position.x < -22.5 {
                    bullet.position.x += 10
                } else {
                    enemyBullets.remove(at: enemyBullets.index(of: bullet)!)
                    let removal = SKAction.removeFromParent()
                    bullet.run(removal)
                    bullet.timeWhenDeleted = Date()
                    recentlyRemovedBullets.append(bullet)
                }
            }
            for bullet in recentlyRemovedBullets {
                let timeBetweenBulletRemovalAndReversalStart = dateReversalStarted.timeIntervalSince(bullet.timeWhenDeleted)
                if timeBetweenBulletRemovalAndReversalStart - timeReversed <= 0.5 && timeBetweenBulletRemovalAndReversalStart - timeReversed >= -0.5 && !bullet.reAdded {
                    bullet.reAdded = true
                    recentlyRemovedBullets.remove(at: recentlyRemovedBullets.index(of: bullet)!)
                    if bullet.parent == nil {
                        bullet.parentalUnit.addChild(bullet)
                    }
                    enemyBullets.append(bullet)
                }
            }
        }
    }
    
    func updatePreviousMovingObstaclePositions() {
        if movingCeilingDoorLayer != nil {
            for i in movingCeilingDoorLayer.children {
                let door = i as! MovingObstacle
                if timeState != .backward && heroState != .reversingEverything && heroState != .reversingOtherStuff {
                    door.previousPosition.append(door.position)
                }
                if door.previousPosition.count > framesBack {
                    door.previousPosition.remove(at: 0)
                }
                if door.position.x - cameraNode.position.x <= 1.5*size.width && door.position.y > 0.0 && !notMoved {
                    door.position.y -= 1
                }
                if heroState == .reversingOtherStuff || timeState == .backward {
                    if heroPrevPos.last == nil || door.previousPosition.last == nil {
                        heroState = .running
                        end = true
                        if timeState == .backward {
                            timeState = .forward
                        }
                    }
                }
            }
        }
        
        if movingGroundDoorLayer != nil {
            for i in movingGroundDoorLayer.children {
                let door = i as! MovingObstacle
                if timeState != .backward && heroState != .reversingEverything && heroState != .reversingOtherStuff {
                    door.previousPosition.append(door.position)
                }
                if door.previousPosition.count > framesBack {
                    door.previousPosition.remove(at: 0)
                }
                if door.position.x - cameraNode.position.x <= 1.5*size.width && door.position.y < 0.0 && !notMoved {
                    door.position.y += 1
                }
            }
        }
        
        if chainGroundSpikeLayer != nil {
            for i in chainGroundSpikeLayer.children {
                let spike = i.children[0].children[0] as! MovingObstacle
                if timeState != .backward && heroState != .reversingEverything && heroState != .reversingOtherStuff {
                    spike.previousPosition.append(spike.position)
                }
                if spike.previousPosition.count > framesBack {
                    spike.previousPosition.remove(at: 0)
                }
            }
        }
        
        if evilScientistLayer != nil {
            for a in evilScientistLayer.children {
                let scientist = a as! MovingObstacle
                if timeState != .backward && heroState != .reversingEverything && heroState != .reversingOtherStuff {
                    scientist.previousPosition.append(scientist.position)
                }
                if scientist.previousPosition.count > framesBack {
                    scientist.previousPosition.remove(at: 0)
                }
            }
            for bullet in recentlyRemovedBullets {
                if bullet.timeWhenDeleted.timeIntervalSince(Date()) < -2.5 && heroState != .reversingEverything && heroState != .reversingOtherStuff {
                    recentlyRemovedBullets.remove(at: recentlyRemovedBullets.index(of: bullet)!)
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
        if heroPrevPos.count > framesBack {
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
            view!.gestureRecognizers?.removeAll()
            scene.scaleMode = .aspectFit
            scene.notMoved = false
            self.view!.presentScene(scene)
        }
    }
    
    func updateCooldowns() {
        if heroState == .running && timeState == .forward {
            phaseCoolDown -= 1 / 60
            timeCoolDown -= 1 / 60
            timeSinceESShot -= 1 / 60
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
    
    func evilScientistsShoot() {
        if evilScientistLayer != nil && !notMoved {
            if timeSinceESShot < 0.0 {
                for baddie in evilScientistLayer.children {
                    let bullet = Bullet()
                    enemyBullets.append(bullet)
                    bullet.parentalUnit = baddie as! SKSpriteNode
                    baddie.addChild(bullet)
                    bullet.position.x = -22.5
                    bullet.position.y = 0
                    timeSinceESShot = 1.0
                }
            }
            
            for bullet in enemyBullets {
                if heroState != .reversingOtherStuff && heroState != .reversingEverything {
                    bullet.position.x -= 10
                    if bullet.position.x <= -250 {
                        let removal = SKAction.removeFromParent()
                        enemyBullets.remove(at: enemyBullets.index(of: bullet)!)
                        recentlyRemovedBullets.append(bullet)
                        bullet.timeWhenDeleted = Date()
                        bullet.run(removal)
                    }
                }
            }
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
