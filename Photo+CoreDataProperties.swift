//
//  Photo+CoreDataProperties.swift
//  Virtual TOurists
//
//  Created by Amarnath Manipatra on 14/05/17.
//  Copyright © 2017 otd. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var id: String?
    @NSManaged public var photo: Data?
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?

}
