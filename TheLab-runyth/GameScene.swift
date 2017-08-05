//
//  GameScene.swift
//  TheLab-runyth
//
//  Created by Aniruddha Madhusudan on 7/10/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import SpriteKit
import GameplayKit
import Answers

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
    var levelLabel: SKLabelNode!
    var cameraNode: SKCameraNode!
    var restartButton: noAlphaChangeButton!
    var replayButton: noAlphaChangeButton!
    var levelSelectButton: noAlphaChangeButton!
    var pauseButton: noAlphaChangeButton!
    var playButton: noAlphaChangeButton!
    var nextButton: noAlphaChangeButton!
    var restartBack: SKSpriteNode!
    var replayBack: SKSpriteNode!
    var levelsBack: SKSpriteNode!
    var playBack: SKSpriteNode!
    var nextBack: SKSpriteNode!
    var movingCeilingDoorLayer: SKSpriteNode!
    var movingGroundDoorLayer: SKSpriteNode!
    var chainGroundSpikeLayer: SKSpriteNode!
    var evilScientistLayer: SKSpriteNode!
    var movingSpikeLayer: SKSpriteNode!
    var background: SKSpriteNode!
    var grass: SKSpriteNode!
    var finalDoor: SKSpriteNode!
    var treasure: SKSpriteNode!
    var dummyDoor: MovingObstacle!
    var meowMeow: MovingObstacle!
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
    var heroSpeed: CGFloat = 2.0
    var notMoved: Bool = false
    var phaseActive: Bool = true
    var timeActive: Bool = true
    var treasureFound: Bool = false
    var levelBeatenMethodCalled: Bool = false
    let gravity = CGVector(dx: 0, dy: -3.0)
    // lose animation
    var loseAnimation: SKAction? = nil
    // run animation
    var runningAnimation: SKAction? = nil
    var runningBlock: SKAction? = nil
    var heroNotRunning: Bool = false
    // roll to phase -- get rid of alpha change
    var phasingAnimation: SKAction? = nil
    var currentlyPhasing: Bool = false
    // stand to reverse time
    var timeReverseAnimation: SKAction? = nil
    var previousVelocity: CGVector? = nil
    static var level: Int = 1
    static var framesBack: Int = 150
    static var phaseDurationMax: Double = 0.5
    static var startLogged: Bool = false
    
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = gravity
//                view.showsFPS = true
//                view.showsPhysics = true
        loseAnimation = SKAction.animate(with: [SKTexture(imageNamed: "frame1Lose"), SKTexture(imageNamed: "frame2Lose"), SKTexture(imageNamed: "frame3Lose"), SKTexture(imageNamed: "frame4Lose"), SKTexture(imageNamed: "frame5Lose")], timePerFrame: 0.25 / 5.0)
        
        runningAnimation = SKAction.animate(with: [SKTexture(imageNamed: "frame2Run"), SKTexture(imageNamed: "frame3Run"), SKTexture(imageNamed: "frame4Run"), SKTexture(imageNamed: "frame1Run")], timePerFrame: 0.5 / 4.0)
        runningBlock = SKAction.repeatForever(runningAnimation!)
        
        phasingAnimation = SKAction.animate(with: [SKTexture(imageNamed: "frame1Roll"), SKTexture(imageNamed: "frame2Roll"), SKTexture(imageNamed: "frame3Roll")], timePerFrame: 0.5 / 3.0)
        
        timeReverseAnimation = SKAction.animate(with: [SKTexture(imageNamed: "frame1Stand"), SKTexture(imageNamed: "frame2Stand"), SKTexture(imageNamed: "frame3Stand"), SKTexture(imageNamed: "frame4Stand"), SKTexture(imageNamed: "frame5Stand"), SKTexture(imageNamed: "frame6Stand"), SKTexture(imageNamed: "frame7Stand"), SKTexture(imageNamed: "frame8Stand"), ], timePerFrame: 1.5 / 8.0)
        
        if !GameScene.startLogged {
            Answers.logLevelStart("Level_\(GameScene.level)", customAttributes: [:])
            GameScene.startLogged = true
        }
        if GameScene.level == 1 || GameScene.level == 2 || GameScene.level == 3 || GameScene.level == 5 || GameScene.level == 7 {
            notMoved = true
        }
        phaseCool = childNode(withName: "//phaseCool") as! SKLabelNode
        timeCool = childNode(withName: "//timeCool") as! SKLabelNode
        levelLabel = childNode(withName: "//levelLabel") as! SKLabelNode
        if GameScene.level < 3 {
            timeActive = false
            timeCool.isHidden = true
        }
        if GameScene.level < 5 {
            phaseActive = false
            phaseCool.isHidden = true
        }
        if GameScene.level == 3 {
            dummyDoor = childNode(withName: "//dummyDoor") as! MovingObstacle
            meowMeow = childNode(withName: "//meowMeow") as! MovingObstacle
            let x = dummyDoor.position.x
            let y = dummyDoor.position.y
            for i in 0...149 {
                dummyDoor.previousPosition.append(CGPoint(x: x, y: y + CGFloat(150 - i)))
                meowMeow.previousPosition.append(meowMeow.position)
            }
        }
        if GameScene.level >= 7 {
            treasure = childNode(withName: "treasure") as! SKSpriteNode
        }
        if GameScene.level == 7 {
            if LevelSelect.beatenLevelManager.beatenLevels.contains(levelBeat(levelNum: 7, treasureCollected: true)) {
                treasure.alpha = 0.0
                treasure.physicsBody?.contactTestBitMask = 0
            }
        }
        if GameScene.level > 7 {
            let randInt = arc4random_uniform(100)
            if LevelSelect.beatenLevelManager.beatenLevels.contains(levelBeat(levelNum: GameScene.level, treasureCollected: true)) {
                print("treasure previously collected...")
                print("GET REKT!!!")
            } else {
                if randInt < 100 {
                    treasure.alpha = 1.0
                    treasure.physicsBody?.contactTestBitMask = 1
                }
            }
        }
        //        background = childNode(withName: "background") as! SKSpriteNode
        //        grass = childNode(withName: "grass") as! SKSpriteNode
        hero = childNode(withName: "//hero") as! SKSpriteNode
        
        hero.physicsBody = SKPhysicsBody(circleOfRadius: 22.0, center: CGPoint(x: 0, y: 0))
        hero.physicsBody?.allowsRotation = false
        hero.physicsBody?.categoryBitMask = 1
        hero.physicsBody?.contactTestBitMask = 1
        
        finalDoor = childNode(withName: "finalDoor") as! SKSpriteNode
        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        restartButton = childNode(withName: "//restartButton") as! noAlphaChangeButton
        replayButton = childNode(withName: "//replayButton") as! noAlphaChangeButton
        levelSelectButton = childNode(withName: "//levelSelectButton") as! noAlphaChangeButton
        pauseButton = childNode(withName: "//pauseButton") as! noAlphaChangeButton
        playButton = childNode(withName: "//playButton") as! noAlphaChangeButton
        nextButton = childNode(withName: "//nextButton") as! noAlphaChangeButton
        restartBack = childNode(withName: "//restartBack") as! SKSpriteNode
        replayBack = childNode(withName: "//replayBack") as! SKSpriteNode
        levelsBack = childNode(withName: "//levelsBack") as! SKSpriteNode
        playBack = childNode(withName: "//playBack") as! SKSpriteNode
        nextBack = childNode(withName: "//nextBack") as! SKSpriteNode
        
        if let spikeLayer = childNode(withName: "spikeLayer") as? SKSpriteNode {
            for spike in spikeLayer.children {
                spike.physicsBody = SKPhysicsBody(circleOfRadius: 15.0, center: CGPoint(x: 0, y: 0))
                spike.physicsBody?.isDynamic = false
                spike.physicsBody?.affectedByGravity = false
                spike.physicsBody?.allowsRotation = false
                spike.physicsBody?.categoryBitMask = 2
                spike.physicsBody?.collisionBitMask = 0
                spike.physicsBody?.contactTestBitMask = 1
            }
        }
        if let tallSpikeLayer = childNode(withName: "tallSpikeLayer") as? SKSpriteNode {
            for tallSpike in tallSpikeLayer.children {
                tallSpike.physicsBody = SKPhysicsBody(circleOfRadius: 22.0, center: CGPoint(x: 0, y: 0))
                tallSpike.physicsBody?.isDynamic = false
                tallSpike.physicsBody?.affectedByGravity = false
                tallSpike.physicsBody?.allowsRotation = false
                tallSpike.physicsBody?.categoryBitMask = 2
                tallSpike.physicsBody?.collisionBitMask = 0
                tallSpike.physicsBody?.contactTestBitMask = 1
            }
        }
        if let mCDL = childNode(withName: "movingCeilingDoorLayer") as? SKSpriteNode {
            movingCeilingDoorLayer = mCDL
        }
        if let mGDL = childNode(withName: "movingGroundDoorLayer") as? SKSpriteNode {
            movingGroundDoorLayer = mGDL
        }
        if let eSL = childNode(withName: "evilScientistLayer") as? SKSpriteNode {
            evilScientistLayer = eSL
            for i in evilScientistLayer.children {
                let scientist = i as! MovingObstacle
                scientist.physicsBody?.restitution = 0.5
            }
        }
        if let mSL = childNode(withName: "movingSpikeLayer") as? SKSpriteNode {
            movingSpikeLayer = mSL
            for i in movingSpikeLayer.children {
                let spike = i as! MovingObstacle
                spike.physicsBody?.restitution = 0.5
            }
        }
        if let cSL = childNode(withName: "chainGroundSpikeLayer") as? SKSpriteNode {
            chainGroundSpikeLayer = cSL
            for reference in chainGroundSpikeLayer.children {
                let node = reference.children[0]
                
                let spike = node.childNode(withName: "spike") as! MovingObstacle
                let chainTop = node.childNode(withName: "chainTop") as! MovingObstacle
                let chainMid = node.childNode(withName: "chainMid") as! MovingObstacle
                let chainBot = node.childNode(withName: "chainBot") as! MovingObstacle
                let anchor = node.childNode(withName: "anchor") as! SKSpriteNode
                
                spike.physicsBody = SKPhysicsBody(circleOfRadius: 15.0, center: CGPoint(x: 0, y: 0))
                spike.physicsBody?.categoryBitMask = 2
                spike.physicsBody?.collisionBitMask = 4294967293
                spike.physicsBody?.contactTestBitMask = 1
                
                var groundPinLocation = chainBot.position
                groundPinLocation.x += 7.425
                groundPinLocation.y -= 10.96
                groundPinLocation = node.convert(groundPinLocation, to: self)
                let groundPinJoint = SKPhysicsJointPin.joint(withBodyA: anchor.physicsBody!, bodyB: chainBot.physicsBody!, anchor: groundPinLocation)
                physicsWorld.add(groundPinJoint)
                
                var botMidPinLocation = chainMid.position
                botMidPinLocation.y -= 10.96
                botMidPinLocation.x -= 7.425
                botMidPinLocation = node.convert(botMidPinLocation, to: self)
                let botMidPinJoint = SKPhysicsJointPin.joint(withBodyA: chainMid.physicsBody!, bodyB: chainBot.physicsBody!, anchor: botMidPinLocation)
                physicsWorld.add(botMidPinJoint)
                
                var midTopPinLocation = chainTop.position
                midTopPinLocation.y -= 10.96
                midTopPinLocation.x += 7.425
                midTopPinLocation = node.convert(midTopPinLocation, to: self)
                let midTopPinJoint = SKPhysicsJointPin.joint(withBodyA: chainMid.physicsBody!, bodyB: chainTop.physicsBody!, anchor: midTopPinLocation)
                physicsWorld.add(midTopPinJoint)
                
                var spikePinLocation = chainTop.position
                spikePinLocation.y += 10.96
                spikePinLocation.x -= 7.425
                spikePinLocation = node.convert(spikePinLocation, to: self)
                let spikePinJoint = SKPhysicsJointPin.joint(withBodyA: spike.physicsBody!, bodyB: chainTop.physicsBody!, anchor: spikePinLocation)
                physicsWorld.add(spikePinJoint)
            }
        }
        
        if !notMoved {
            hero.run(runningBlock!)
        } else {
            heroNotRunning = true
        }
        
        nextButton.position.y -= 25
        nextBack.position.y -= 25
        replayButton.position.y -= 25
        replayBack.position.y -= 25
        
        levelLabel.isHidden = true
        restartButton.state = .hidden
        restartBack.isHidden = true
        replayButton.state = .hidden
        replayBack.isHidden = true
        levelSelectButton.state = .hidden
        levelsBack.isHidden = true
        playButton.state = .hidden
        playBack.isHidden = true
        nextButton.state = .hidden
        nextBack.isHidden = true
        self.camera = cameraNode
        physicsWorld.contactDelegate = self
        
        //        let targetX = hero.position.x
        //        cameraNode.position.x = targetX
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        /*
         let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
         swipeLeft.direction = .left
         view.addGestureRecognizer(swipeLeft)
         */
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.respondToLongPressGesture))
        longPress.minimumPressDuration = 0.2
        view.addGestureRecognizer(longPress)
        
        pauseButton.selectedHandler = { [unowned self, unowned view] in
            self.isPaused = true
            self.restartButton.state = .active
            self.restartBack.isHidden = false
            self.levelSelectButton.state = .active
            self.levelsBack.isHidden = false
            self.playButton.state = .active
            self.playBack.isHidden = false
            self.pauseButton.state = .hidden
            self.levelLabel.isHidden = false
            view.gestureRecognizers?.removeAll()
        }
        
        playButton.selectedHandler = { [unowned self, unowned view] in
            self.restartButton.state = .hidden
            self.restartBack.isHidden = true
            self.levelSelectButton.state = .hidden
            self.levelsBack.isHidden = true
            self.playButton.state = .hidden
            self.playBack.isHidden = true
            self.pauseButton.state = .active
            self.levelLabel.isHidden = true
            self.isPaused = false
            view.addGestureRecognizer(swipeRight)
            view.addGestureRecognizer(swipeUp)
            view.addGestureRecognizer(swipeDown)
            view.addGestureRecognizer(longPress)
        }
        
        restartButton.selectedHandler = { [unowned self, unowned view] in
            guard let scene = GameScene.level(GameScene.level) else {
                print("Bye scene?!?!?!?!?!?!?!?!?!?!?!?!?!?!?!?")
                return
            }
            view.gestureRecognizers?.removeAll()
            scene.scaleMode = .aspectFit
            self.view!.presentScene(scene)
        }
        
        replayButton.selectedHandler = { [unowned self, unowned view] in
            guard let scene = GameScene.level(GameScene.level) else {
                print("Bye scene?!?!?!?!?!?!?!?!?!?!?!?!?!?!?!?")
                return
            }
            view.gestureRecognizers?.removeAll()
            scene.scaleMode = .aspectFit
            GameScene.startLogged = false
            self.view!.presentScene(scene)
        }
        
        nextButton.selectedHandler = { [unowned self, unowned view] in
            guard let _ = GameScene.level(GameScene.level + 1) else {
                print("NO NEXT LEVEL FOR YOU!!!")
                return
            }
            GameScene.level += 1
            let scene = GameScene.levelPreview(GameScene.level + 1)!
            view.gestureRecognizers?.removeAll()
            scene.scaleMode = .aspectFit
            GameScene.startLogged = false
            self.view!.presentScene(scene)
        }
        
        levelSelectButton.selectedHandler = { [unowned self, unowned view] in
            guard let scene = LevelSelect(fileNamed: "LevelSelect") else {
                print("Bye level select!?!?!?!?!?!?!?!?!?!?!?!?!?!?")
                return
            }
            view.gestureRecognizers?.removeAll()
            scene.scaleMode = .aspectFit
            GameScene.startLogged = false
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
                    if !currentlyPhasing {
                        hero.removeAllActions()
                        hero.run(phasingAnimation!)
                        heroNotRunning = true
                    }
                    hero.physicsBody?.categoryBitMask = 0
                    hero.physicsBody?.collisionBitMask = 8
                    hero.physicsBody?.contactTestBitMask = 0
                    hero.position.x += 2*heroSpeed
                    hero.alpha = 0.6
                    phaseDuration += 1 / 60
                    currentlyPhasing = true
                    break
                case .running:
                    if heroNotRunning {
                        hero.run(runningBlock!)
                        heroNotRunning = false
                    }
                    hero.alpha = 1.0
                    hero.physicsBody?.categoryBitMask = 1
                    hero.physicsBody?.collisionBitMask = 4294967295
                    hero.physicsBody?.contactTestBitMask = 1
                    hero.position.x += heroSpeed
                    break
                case .reversingOtherStuff:
                    hero.physicsBody?.affectedByGravity = false
                    hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    hero.removeAllActions()
                    hero.run(timeReverseAnimation!)
                    heroNotRunning = true
                    moveObstacleBackInTime()
                case .reversingEverything:
                    timeState = .backward
                case .stationary:
                    hero.removeAllActions()
                }
            case .backward:
                moveObstacleBackInTime()
                moveHeroBackInTime()
            }
        }
        
        
        if phaseDuration >= GameScene.phaseDurationMax {
            currentlyPhasing = false
            if heroState == .phasing {
                heroState = .running
            }
        }
        
        let targetX = hero.position.x
        let rightMostSideOfFinalDoor = finalDoor.position.x + finalDoor.size.width / 2
        let x = clamp(value: targetX - 75, lower: 0, upper: rightMostSideOfFinalDoor - size.width / 2)
        // Only move camera, main background, and upper grass -- stretch the rest out as needed in the sks
        cameraNode.position.x = x
        //        background.position.x = x
        //        grass.position.x = x
        
        if !notMoved {
            updatePreviousMovingObstaclePositions()
        }
        
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
            runLoseAnimation()
        } else if categoryA == 2 && categoryB == 1 {
            runLoseAnimation()
        } else if categoryA == 1 && categoryB == 4 {
            runLoseAnimation()
            let bullet = nodeB as! Bullet
            bullet.timeWhenDeleted = Date()
            enemyBullets.remove(at: enemyBullets.index(of: bullet)!)
            recentlyRemovedBullets.append(bullet)
            nodeB.run(removal)
        } else if categoryA == 4 && categoryB == 1 {
            runLoseAnimation()
            let bullet = nodeA as! Bullet
            bullet.timeWhenDeleted = Date()
            enemyBullets.remove(at: enemyBullets.index(of: bullet)!)
            recentlyRemovedBullets.append(bullet)
            nodeA.run(removal)
        } else if categoryA == 1 && categoryB == 0 {
            nodeB.run(removal)
            treasureFound = true
        } else if categoryA == 0 && categoryB == 1 {
            nodeA.run(removal)
            treasureFound = true
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
    
    func runLoseAnimation() {
        view?.gestureRecognizers?.removeAll()
        print("bye")
        if !(hero.physicsBody?.pinned)! {
            print("hi")
            hero.removeAllActions()
            hero.physicsBody?.categoryBitMask = 0
            hero.physicsBody?.collisionBitMask = 0
            hero.physicsBody?.contactTestBitMask = 0
            hero.physicsBody?.pinned = true
            let removeReference = SKAction.run({ [unowned self] in
                self.hero.parent!.parent!.removeFromParent()
            })
            let sequence = SKAction.sequence([loseAnimation!, removeReference])
            print("sequence defined")
            hero.run(sequence)
            print("hero ran sequence")
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
                if timeActive && timeCoolDown <= 0.0 {
                    timeCoolDown = 5.0
                    heroState = .reversingEverything
                    dateReversalStarted = Date()
                }
            case UISwipeGestureRecognizerDirection.right:
                if phaseActive && phaseCoolDown <= 0.0 && timeState == .forward {
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
                    self.physicsWorld.gravity = CGVector(dx: 0, dy: -gravity.dy)
                    hero.yScale = -1
                }
            case UISwipeGestureRecognizerDirection.down:
                if heroState != .stationary {
                    self.physicsWorld.gravity = gravity
                    hero.yScale = 1
                }
            default:
                break
            }
        }
    }
    
    func respondToLongPressGesture(gesture: UIGestureRecognizer) {
        if let longPressGesture = gesture as? UILongPressGestureRecognizer {
            if timeActive {
                if notMoved {
                    notMoved = false
                }
                if longPressGesture.state == .ended {
                    heroState = .running
                    hero.physicsBody?.affectedByGravity = true
                    hero.physicsBody?.velocity = previousVelocity!
                    if timeState == .backward {
                        timeState = .forward
                    }
                    timeReversed = 0.0
                } else if longPressGesture.state == .began {
                    if timeCoolDown <= 0.0 {
                        timeCoolDown = 5.0
                        previousVelocity = hero.physicsBody?.velocity
                        heroState = .reversingOtherStuff
                        dateReversalStarted = Date()
                    }
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
                if door.previousPosition.last == nil && heroState == .reversingOtherStuff {
                    heroState = .running
                    hero.physicsBody?.affectedByGravity = true
                    hero.physicsBody?.velocity = previousVelocity!
                    if timeState == .backward {
                        timeState = .forward
                    }
                    timeReversed = 0.0
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
        if movingSpikeLayer != nil {
            for i in movingSpikeLayer.children {
                let spike = i as! MovingObstacle
                if let last = spike.previousPosition.last {
                    spike.position = last
                    spike.previousPosition.removeLast()
                }
            }
        }
        if chainGroundSpikeLayer != nil {
            for i in chainGroundSpikeLayer.children {
                let node = i.children[0]
                let chainSpike = node.childNode(withName: "spike") as! MovingObstacle
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
        if timeReversed > 2.5 {
            heroState = .running
            hero.physicsBody?.affectedByGravity = true
            hero.physicsBody?.velocity = previousVelocity!
            if timeState == .backward {
                timeState = .forward
            }
            timeReversed = 0.0
        }
        
        if movingCeilingDoorLayer != nil {
            for i in movingCeilingDoorLayer.children {
                let door = i as! MovingObstacle
                if timeState != .backward && heroState != .reversingEverything && heroState != .reversingOtherStuff {
                    door.previousPosition.append(door.position)
                }
                if door.previousPosition.count > GameScene.framesBack {
                    door.previousPosition.remove(at: 0)
                }
                if door.position.x - cameraNode.position.x <= 1.25*size.width && door.position.y > 0.0 && !notMoved {
                    door.position.y -= 1
                }
            }
        }
        
        if movingGroundDoorLayer != nil {
            for i in movingGroundDoorLayer.children {
                let door = i as! MovingObstacle
                if timeState != .backward && heroState != .reversingEverything && heroState != .reversingOtherStuff {
                    door.previousPosition.append(door.position)
                }
                if door.previousPosition.count > GameScene.framesBack {
                    door.previousPosition.remove(at: 0)
                }
                if door.position.x - cameraNode.position.x <= 1.25*size.width && door.position.y < 0.0 && !notMoved {
                    door.position.y += 1
                }
            }
        }
        
        if movingSpikeLayer != nil {
            for i in movingSpikeLayer.children {
                let spike = i as! MovingObstacle
                if timeState != .backward && heroState != .reversingEverything && heroState != .reversingOtherStuff {
                    spike.previousPosition.append(spike.position)
                }
                if spike.previousPosition.count > GameScene.framesBack {
                    spike.previousPosition.remove(at: 0)
                }
            }
        }
        
        if chainGroundSpikeLayer != nil {
            for i in chainGroundSpikeLayer.children {
                let node = i.children[0]
                let spike = node.childNode(withName: "spike") as! MovingObstacle
                if timeState != .backward && heroState != .reversingEverything && heroState != .reversingOtherStuff {
                    spike.previousPosition.append(spike.position)
                }
                if spike.previousPosition.count > GameScene.framesBack {
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
                if scientist.previousPosition.count > GameScene.framesBack {
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
    
    func moveHeroBackInTime() {
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
    
    func updatePreviousHeroPositions() {
        if timeState != .backward && heroState != .reversingOtherStuff {
            heroPrevPos.append(hero.position)
            heroPrevState.append(heroState)
            previousGravity.append(self.physicsWorld.gravity)
        }
        if heroPrevPos.count > GameScene.framesBack {
            heroPrevPos.remove(at: 0)
            heroPrevState.remove(at: 0)
            previousGravity.remove(at: 0)
        }
        if heroState == .reversingOtherStuff || timeState == .backward {
            if heroPrevPos.last == nil {
                heroState = .running
                hero.physicsBody?.affectedByGravity = true
                hero.physicsBody?.velocity = previousVelocity!
                if timeState == .backward {
                    timeState = .forward
                }
            }
        }
    }
    
    func checkIfHeroIsDEAD() {
        if !cameraNode.contains(hero) || hero.convert(CGPoint(x: 0, y: 0), to: self).y > size.height / 2 {
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
        
        if heroPos.x >= finalDoor.position.x && !levelBeatenMethodCalled && cameraNode.contains(hero) {
            levelBeatenMethodCalled = true
            view?.gestureRecognizers?.removeAll()
            Answers.logLevelEnd("Level_\(GameScene.level)", score: nil, success: true, customAttributes: ["treasureCollected": treasureFound])
            if !LevelSelect.beatenLevelManager.beatenLevels.contains(levelBeat(levelNum: GameScene.level, treasureCollected: treasureFound)) {
                LevelSelect.beatenLevelManager.addNewBeatenLevel(beatenLevelNumber: GameScene.level, treasureCollected: self.treasureFound)
                print(self.treasureFound)
                print(LevelSelect.beatenLevelManager.beatenLevels.last!.treasureCollected)
                print(LevelSelect.beatenLevelManager.toString())
            }
            if treasureFound {
                print("Your money went from \(TheShop.managerOfCurrency.currency)")
                TheShop.managerOfCurrency.addToCurrency(amount: 10)
                print("To \(TheShop.managerOfCurrency.currency)")
                if TheShop.managerOfCurrency.currency <= 1000 {
                    print("Your funds are still somewhat LOW... :(")
                }
            }
            if GameScene.level(GameScene.level + 1) != nil && GameScene.level != 20 {
                pauseButton.state = .hidden
                nextButton.state = .active
                nextBack.isHidden = false
                replayButton.state = .active
                replayBack.isHidden = false
            } else if GameScene.level == 20 {
                guard let scene = SKScene(fileNamed: "WinScreen") else {
                    print("YOU'LL NEVER WIN!!! HAHAHAHAHAHAHAHAHA!!!")
                    return
                }
                scene.scaleMode = .aspectFit
                view?.gestureRecognizers?.removeAll()
                self.view!.presentScene(scene)
            } else if GameScene.level == 21 {
                guard let scene = MainMenu(fileNamed: "MainMenu") else {
                    print("no main menu :(")
                    return
                }
                scene.scaleMode = .aspectFit
                view?.gestureRecognizers?.removeAll()
                self.view!.presentScene(scene)
            } else {
                print("missing Level \(GameScene.level + 1)")
            }
            heroState = .stationary
        }
    }
}
