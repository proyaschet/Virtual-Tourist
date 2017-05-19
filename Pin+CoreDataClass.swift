//
//  Pin+CoreDataClass.swift
//  Virtual TOurists
//
//  Created by Amarnath Manipatra on 14/05/17.
//  Copyright © 2017 otd. All rights reserved.
//

import Foundation
import CoreData
import MapKit


public class Pin: NSManagedObject,MKAnnotation {
    
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Initializer
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: Constants.pin, in: context)!
        super.init(entity: entity, insertInto: context)
        self.latitude = latitude
        self.longitude = longitude
    }

}
