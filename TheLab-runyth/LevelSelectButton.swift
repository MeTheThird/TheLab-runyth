//
//  LevelSelectButton.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/20/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import SpriteKit

class LevelSelectButton: ButtonNode {
    
    var number: Int = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        number = Int(self.name!)!
    }
}
