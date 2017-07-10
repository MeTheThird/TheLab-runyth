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
    var heroState: heroMovingState = .running
    var phaseCoolDown: CFTimeInterval = 0.0
    var phaseDuration: CFTimeInterval = 0.0
    
    override func didMove(to view: SKView) {
        hero = childNode(withName: "//hero") as! SKSpriteNode
        
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
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        switch heroState {
        case .phasing:
            hero.physicsBody?.categoryBitMask = 0
            hero.physicsBody?.collisionBitMask = 2147483648
            hero.physicsBody?.contactTestBitMask = 0
            hero.position.x += 1.5
            hero.alpha = 0.8
            phaseDuration += 1 / 60
        case .running:
            hero.alpha = 1.0
            hero.physicsBody?.categoryBitMask = 1
            hero.physicsBody?.collisionBitMask = 4294967295
            hero.physicsBody?.contactTestBitMask = 1
            hero.position.x += 1.5
        case .reversingOtherStuff:
            heroState = .running
        case .reversingEverything:
            heroState = .running
        }
        
        if phaseDuration >= 2.0 {
            heroState = .running
        }
        
        phaseCoolDown += 1 / 60
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
        if let longPressGesture = gesture as? UILongPressGestureRecognizer {
            if longPressGesture.state == .ended {
            } else if longPressGesture.state == .began {
                heroState = .reversingOtherStuff
            }
        }
    }
    
}
