//
//  levelBeatManager.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/27/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import Foundation

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
    
    func toString() -> String {
        var ans: String = ""
        for i in 0..<self.beatenLevels.count {
            ans += "\(i): levelNumber: \(beatenLevels[i].levelNumber), treasureCollected: \(beatenLevels[i].treasureCollected) \n"
        }
        return ans
    }
}
