//
//  DataController.swift
//  VirtualTourist
//
//  Created by Ali Ahmad on 16/07/2020.
//  Copyright © 2020 Ali Ahmed. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer:NSPersistentContainer
    
    var viewContext : NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    
    func load(completion: (() -> Void)? = nil){
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
