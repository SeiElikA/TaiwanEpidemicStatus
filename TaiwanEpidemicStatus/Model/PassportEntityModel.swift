//
//  PassportEntityModel.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/5.
//

import Foundation
import CoreData

public class PassportEntityModel {
    public var context: NSManagedObjectContext
    
    init(context:NSManagedObjectContext) {
        self.context = context
    }
    
    public func getAllPassport() -> [PassportEntity] {
        let request:NSFetchRequest<PassportEntity> = PassportEntity.fetchRequest()
        do {
            let fetchResult = try context.fetch(request)
            return fetchResult
        } catch {
            print("Fetch Data Error : \(error)")
            return []
        }
    }
    
    public func insertPassport(passport:Passport, hc1Code:String) {
        let entity = PassportEntity(context: context)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        entity.hc1Code = hc1Code
        entity.birthday = formatter.date(from: passport.birthday)
        entity.dose = Int64(passport.v.dose)
        entity.doses = Int64(passport.v.doses)
        entity.name = passport.name
        entity.vaccine = passport.v.vaccine
        entity.vaccineDate = formatter.date(from: passport.v.date)
        entity.country = passport.v.country
        
        self.context.insert(entity)
        try? self.context.save()
    }
    
    public func deletePassport(id:ObjectIdentifier) {
        let request:NSFetchRequest<PassportEntity> = PassportEntity.fetchRequest()
        do {
            let fetchResult = try context.fetch(request)
            let entity = fetchResult.first(where: {$0.id == id})
            guard let entity = entity else {
                return
            }
            context.delete(entity)
            try self.context.save()
        } catch {
            print("Delete Entity Error: \(error)")
        }
    }
}
