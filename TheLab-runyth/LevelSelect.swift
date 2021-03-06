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
    var levelSelectButtonLayer: SKSpriteNode!
    var levelSelectLockLayer: SKSpriteNode!
    var coinLayer: SKSpriteNode!
    var finalDoor: SKSpriteNode!
    var cameraNode: SKCameraNode!
    var backButton: noAlphaChangeButton!
    var swipeLabel: SKLabelNode!
    static var tutorialManager = levelSelectTutorialManager()
    static var beatenLevelManager = levelBeatManager()
    
    override func didMove(to view: SKView) {
        levelSelectButtonLayer = childNode(withName: "levelSelectButtonLayer") as! SKSpriteNode
        levelSelectLockLayer = childNode(withName: "levelSelectLockLayer") as! SKSpriteNode
        coinLayer = childNode(withName: "coinLayer") as! SKSpriteNode
        backButton = childNode(withName: "//backButton") as! noAlphaChangeButton
        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        finalDoor = childNode(withName: "finalDoor") as! SKSpriteNode
        swipeLabel = childNode(withName: "swipeLabel") as! SKLabelNode
        
        if LevelSelect.tutorialManager.seenTutorial {
            swipeLabel.alpha = 0.0
        }
        
        self.camera = cameraNode
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.respondToPanGesture))
        panGesture.minimumNumberOfTouches = 1
        view.addGestureRecognizer(panGesture)
                
        for i in levelSelectLockLayer.children {
            let lock = i as! LevelSelectLock
            if LevelSelect.beatenLevelManager.beatenLevels.contains(levelBeat(levelNum: lock.number, treasureCollected: nil)) || lock.number == LevelSelect.beatenLevelManager.lastLevelBeatenNumber + 1 {
                lock.alpha = 0.0
            }
        }
        
        for i in coinLayer.children {
            let coin = i as! LevelSelectLock
//            coin.isUserInteractionEnabled = false
            if !LevelSelect.beatenLevelManager.beatenLevels.contains(levelBeat(levelNum: coin.number, treasureCollected: true)) {
                coin.alpha = 0.0
            }
        }
        
        backButton.selectedHandler = { [unowned self] in
            guard let skView = self.view as SKView! else {
                print("Could not get Skview")
                return
            }
            
            guard let scene = GameScene(fileNamed: "MainMenu") else {
                print("no Main menu... :(")
                return
            }
            
            scene.scaleMode = .aspectFit
            skView.presentScene(scene)
        }
        
        for a in levelSelectButtonLayer.children {
            let button = a as! LevelSelectButton
            button.selectedHandler = { [unowned self, unowned button] in
                if LevelSelect.beatenLevelManager.beatenLevels.contains(levelBeat(levelNum: button.number, treasureCollected: nil)) || button.number == LevelSelect.beatenLevelManager.lastLevelBeatenNumber + 1 {
                    self.loadGame(level: button.number)
                }
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let touchPos = touch.location(in: self)
        
        for i in levelSelectButtonLayer.children {
            let button = i as! LevelSelectButton
            let buttonPos = levelSelectButtonLayer.convert(i.position, to: self)
            if abs(buttonPos.y - touchPos.y) <= 30 && abs(buttonPos.x - touchPos.x) <= 30 && LevelSelect.beatenLevelManager.beatenLevels.contains(levelBeat(levelNum: button.number, treasureCollected: nil)) {
                button.touchesEnded(touches, with: event)
                break
            }
        }
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
    
    func respondToPanGesture(gesture: UIGestureRecognizer) {
        if let gestureOfPan = gesture as? UIPanGestureRecognizer {
            let targetX = cameraNode.position.x - 0.03*gestureOfPan.velocity(in: self.view!).x
            let rightMostSideOfFinalDoor = finalDoor.position.x + finalDoor.size.width / 2
            let x = clamp(value: targetX, lower: 0, upper: rightMostSideOfFinalDoor - size.width / 2)
            cameraNode.position.x = x
        }
    }
}
