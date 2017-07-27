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
        self.treasureCollected = aDecoder.decodeBool(forKey: "treasureCollected")
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

class levelBeatManager {
    
    var beatenLevels = [levelBeat]()
    var lastLevelBeatenNumber: Int = 0
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("beatenLevels.plist")
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: path.absoluteString) {
            if let bundle = Bundle.main.path(forResource: "DefaultFile", ofType: "plist") {
                do {
                    try fileManager.copyItem(atPath: bundle, toPath: path.absoluteString)
                }
                catch {
                    print(error)
                }
            }
        }
        do {
            let rawData = try Data(contentsOf: path)
            let beatenArray: Any? = NSKeyedUnarchiver.unarchiveObject(with: rawData)
            self.beatenLevels = beatenArray as? [levelBeat] ?? []
        }
        catch {
            print(error)
        }
        
        for x in beatenLevels {
            if x.levelNumber > lastLevelBeatenNumber {
                lastLevelBeatenNumber = x.levelNumber
            }
        }
    }
    
    func save() {
        let saveData = NSKeyedArchiver.archivedData(withRootObject: self.beatenLevels)
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("beatenLevels.plist")
        do {
            try saveData.write(to: path)
        }
        catch {
            print(error)
        }
    }
    
    func addNewBeatenLevel(beatenLevelNumber: Int, treasureCollected: Bool) {
        let newBeatenLevel = levelBeat(levelNum: beatenLevelNumber, treasureCollected: treasureCollected)
        if beatenLevelNumber > lastLevelBeatenNumber {
            lastLevelBeatenNumber = beatenLevelNumber
        }
        self.beatenLevels.append(newBeatenLevel)
        self.save()
    }
}

class currencyManager {
    var currency: Int = 0
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("currency.plist")
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: path.absoluteString) {
            if let bundle = Bundle.main.path(forResource: "DefaultFile", ofType: "plist") {
                do {
                    try fileManager.copyItem(atPath: bundle, toPath: path.absoluteString)
                }
                catch {
                    print(error)
                }
            }
        }
        
        do {
            let rawData = try Data(contentsOf: path)
            let theCurrency: Any? = NSKeyedUnarchiver.unarchiveObject(with: rawData)
            self.currency = theCurrency as? Int ?? 0
        }
        catch {
            print(error)
        }
    }
    
    func save() {
        let saveData = NSKeyedArchiver.archivedData(withRootObject: self.currency)
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("currency.plist")
        do {
            try saveData.write(to: path)
        }
        catch {
            print(error)
        }
    }
    
    func addToCurrency(amount: Int) {
        self.currency += amount
        self.save()
    }
}
