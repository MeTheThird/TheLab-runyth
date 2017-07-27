//
//  RandomPListStuff.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/25/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import Foundation

class levelBeat: NSObject, NSCoding {
    let levelNumber: Int
    let treasureCollected: Bool?
    
    init(levelNum: Int, treasureCollected: Bool?) {
        self.levelNumber = levelNum
        self.treasureCollected = treasureCollected
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.levelNumber = aDecoder.decodeInteger(forKey: "levelNumber")
        if aDecoder.decodeObject(forKey: "hi") != nil {
            self.treasureCollected = aDecoder.decodeBool(forKey: "treasureCollected")
        } else {
            self.treasureCollected = nil
        }
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.levelNumber, forKey: "levelNumber")
        aCoder.encode(self.treasureCollected, forKey: "treasureCollected")
    }
    
    override var hash: Int {
        return levelNumber
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? levelBeat {
            if self.treasureCollected != nil && other.treasureCollected != nil {
                return self.levelNumber == other.levelNumber && self.treasureCollected == other.treasureCollected
            }
            return self.levelNumber == other.levelNumber
        }
        return false
    }
}
