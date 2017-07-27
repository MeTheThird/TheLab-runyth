//
//  currencyManager.swift
//  TheLabrunyth
//
//  Created by Aniruddha Madhusudan on 7/27/17.
//  Copyright © 2017 Aniruddha Madhusudan. All rights reserved.
//

import Foundation

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
        if self.currency + amount <= 4000 {
            self.currency += amount
        } else {
            self.currency = 4000
        }
        self.save()
    }
}
