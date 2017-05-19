//
//  Photo+CoreDataClass.swift
//  Virtual TOurists
//
//  Created by Amarnath Manipatra on 14/05/17.
//  Copyright © 2017 otd. All rights reserved.
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: Constants.photo, in: context)!
        super.init(entity: entity, insertInto: context)
        self.id = dictionary[Constants.id] as? String
        self.url = dictionary[Constants.urlM] as? String
    }
}
