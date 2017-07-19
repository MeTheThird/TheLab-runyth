//
//  Bullet.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/17/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import SpriteKit

class Bullet: MovingObstacle {
    
    var timeWhenDeleted: Date = Date()
    var reAdded: Bool = false
    var parentalUnit: SKSpriteNode!
    
    init() {
        let color = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let size = CGSize(width: 15.0, height: 10.0)
        
        super.init(texture: nil, color: color, size: size)
        
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = 4
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
