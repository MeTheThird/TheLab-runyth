//
//  TheShopUpgradeButton.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/25/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import SpriteKit

enum buttonState {
    case active, selected, hidden
}

class TheShopUpgradeButton: SKSpriteNode {
    
    var selectedHandler: () -> Void = { print("NADA!!!") }
    
    var state: buttonState = .active {
        didSet {
            switch state {
            case .active:
                isUserInteractionEnabled = true
                break
            case .selected:
                break
            case .hidden:
                isUserInteractionEnabled = false
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
