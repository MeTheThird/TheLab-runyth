//
//  ButtonNode.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/10/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import SpriteKit

enum buttonNodeState {
    case active, selected, hidden
}

class ButtonNode: SKSpriteNode {
    
    var selectedHandler: () -> Void = { print("NADA!!!") }
    
    var state: buttonNodeState = .active {
        didSet {
            switch state {
            case .active:
                isUserInteractionEnabled = true
                
                alpha = 1.0
                break
            case .selected:
                alpha = 0.7
                break
            case .hidden:
                isUserInteractionEnabled = false
                alpha = 0
                break
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .selected
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedHandler()
        if state == .selected {
            state = .active
        }
    }
}
