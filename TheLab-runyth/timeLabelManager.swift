//
//  timeLabelManager.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/27/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import Foundation

class timeLabelManager {
    
    var timeLabelText: String = "100"
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("timeLabelText.plist")
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
            let text: Any? = NSKeyedUnarchiver.unarchiveObject(with: rawData)
            self.timeLabelText = text as? String ?? "nada"
        }
        catch {
            print(error)
        }
    }
    
    func save() {
        let saveData = NSKeyedArchiver.archivedData(withRootObject: self.timeLabelText)
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("timeLabelText.plist")
        do {
            try saveData.write(to: path)
        }
        catch {
            print(error)
        }
    }
    
    func increaseCost() {
        let timeInt = Double(self.timeLabelText)!
        self.timeLabelText = String(format: "%.0f", 1.5*timeInt)
        self.save()
    }
}
