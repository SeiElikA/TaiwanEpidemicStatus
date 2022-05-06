//
//  PassportEntity+CoreDataProperties.swift
//  
//
//  Created by 葉家均 on 2022/5/5.
//
//

import Foundation
import CoreData


extension PassportEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PassportEntity> {
        return NSFetchRequest<PassportEntity>(entityName: "PassportEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var birthday: Date?
    @NSManaged public var dose: Int64
    @NSManaged public var doses: Int64
    @NSManaged public var vaccine: String?
    @NSManaged public var vaccineDate: Date?
    @NSManaged public var country: String?
    @NSManaged public var hc1Code: String?

}
