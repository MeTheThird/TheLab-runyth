//
//  RandomPListStuff.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/25/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import Foundation

class levelBeat: NSObject, NSCoding {
    let beaten: Bool
    let levelNumber: Int
    
    init(beaten: Bool, levelNum: Int) {
        self.beaten = beaten
        self.levelNumber = levelNum
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.beaten = aDecoder.decodeObject(forKey: "beaten") as! Bool
        self.levelNumber = aDecoder.decodeObject(forKey: "levelNumber") as! Int
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.beaten, forKey: "beaten")
        aCoder.encode(self.levelNumber, forKey: "levelNumber")
    }
}

class levelBeatManager {
    
    var beatenLevels = [levelBeat]()
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("beatenLevels.plist").absoluteString
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: path) {
            if let bundle = Bundle.main.path(forResource: "DefaultFile", ofType: "plist") {
                do {
                    try fileManager.copyItem(atPath: bundle, toPath: path)
                }
                catch {
                    print(error)
                }
            }
        }
        
        if let rawData = NSData(contentsOfFile: path) {
            let beatenArray: AnyObject? = NSKeyedUnarchiver.unarchiveObject(with: rawData as Data) as AnyObject
            self.beatenLevels = beatenArray as? [levelBeat] ?? []
        }
    }
}
