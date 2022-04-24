//
//  CoreDataMigrationManaged.swift
//  RealmMigrationAssistant
//
//  Created by Mateusz Łukasiński on 24/04/2022.
//

import Foundation
import CoreData

public protocol CoreDataMigrationManaged
{
    associatedtype ManagedType: NSManagedObject = Self
    static var entityName : String { get }
    
    static func all(in context: NSManagedObjectContext) throws -> [ManagedType]
}

public extension CoreDataMigrationManaged where Self : NSManagedObject {
    static var entityName : String { return String(describing:self) }
    
    static func all(in context: NSManagedObjectContext) throws -> [ManagedType] {
        let request = NSFetchRequest<ManagedType>(entityName: entityName)
        return try context.fetch(request)
    }
}
