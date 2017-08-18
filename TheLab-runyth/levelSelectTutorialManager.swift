//
//  levelSelectTutorialManager.swift
//  TheLabyrunth
//
//  Created by Aniruddha Madhusudan on 8/17/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import Foundation

class levelSelectTutorialManager {
    
    var seenTutorial: Bool = false
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("seenTutorial.plist")
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
            self.seenTutorial = back as? Bool ?? false
        }
        catch {
            print(error)
        }
    }
    
    func save() {
        let saveData = NSKeyedArchiver.archivedData(withRootObject: self.seenTutorial)
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("seenTutorial.plist")
        do {
            try saveData.write(to: path)
        }
        catch {
            print(error)
        }
    }
    
    func changeTo(value: Bool) {
        self.seenTutorial = value
        self.save()
    }
}
