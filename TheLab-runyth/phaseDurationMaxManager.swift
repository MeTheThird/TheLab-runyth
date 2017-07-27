//
//  phaseDurationMaxManager.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/27/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import Foundation

class phaseDurationMaxManager {
    
    var phaseDurationMax: Double = 1.0
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("phaseDurationMax.plist")
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
            let duration: Any? = NSKeyedUnarchiver.unarchiveObject(with: rawData)
            self.phaseDurationMax = duration as? Double ?? 1.0
        }
        catch {
            print(error)
        }
    }
    
    func save() {
        let saveData = NSKeyedArchiver.archivedData(withRootObject: self.phaseDurationMax)
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("phaseDurationMax.plist")
        do {
            try saveData.write(to: path)
        }
        catch {
            print(error)
        }
    }
    
    func increaseBy(amount: Double) {
        self.phaseDurationMax += amount        
        self.save()
    }
}
