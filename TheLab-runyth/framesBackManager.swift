//
//  framesBackManager.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/27/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import Foundation

class framesBackManager {
    
    var framesBack: Int = 150
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("framesBack.plist")
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
            let back: Any? = NSKeyedUnarchiver.unarchiveObject(with: rawData)
            self.framesBack = back as? Int ?? 150
        }
        catch {
            print(error)
        }
    }
    
    func save() {
        let saveData = NSKeyedArchiver.archivedData(withRootObject: self.framesBack)
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("framesBack.plist")
        do {
            try saveData.write(to: path)
        }
        catch {
            print(error)
        }
    }
    
    func increaseBy(amount: Int) {
        self.framesBack += amount
        self.save()
    }
}
