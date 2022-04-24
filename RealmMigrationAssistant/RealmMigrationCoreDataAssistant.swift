//
//  RealmMigrationCoreDataAssistant.swift
//  RealmMigrationAssistant
//
//  Created by Mateusz Łukasiński on 24/04/2022.
//

import Foundation
import RealmSwift
import CoreData

public class RealmMigrationCoreDataAssistant<CoreDataObject: NSManagedObject, RealmObject: Object> : RealmMigrationBaseAssistant<RealmObject> {
    private var context: NSManagedObjectContext?
    
    public init(context: NSManagedObjectContext?) {
        self.context = context
        super.init()
    }
    
    public func migrate(completionHandler: (RealmMigrationStatus)->Void) where CoreDataObject: CoreDataMigrationManaged {
        do {
            let coreDataEntities = try getCoreDataEntity()
            migrate(from: coreDataEntities, completionHandler: completionHandler)
        } catch RealmMigrationToolError.error(let description) {
            completionHandler(.error(description))
            return
        } catch {
            completionHandler(.error(error.localizedDescription))
            return
        }
    }

    public func migrate(from coreDataObject: [NSManagedObject], completionHandler: (RealmMigrationStatus)->Void) {
        var realmObjects: [RealmObject] = []
        do {
            for entity in coreDataObject {
                let realmModelFromCoreData = try createRealmObject(from: getDataFromCoreDataEntity(entity: entity))
                realmObjects.append(realmModelFromCoreData)
            }
            saveRealmData(data: realmObjects, completionHandler: completionHandler)
        } catch RealmMigrationToolError.error(let description) {
            completionHandler(.error(description))
            return
        } catch {
            completionHandler(.error(error.localizedDescription))
            return
        }
    }
    
    private func getCoreDataEntity() throws -> [CoreDataObject] where CoreDataObject: CoreDataMigrationManaged {
        guard let context = context else {
            throw RealmMigrationToolError.error("Couldn't get NSManagedObjectContext")
        }
        let entities = try CoreDataObject.all(in: context)
        guard let bestEntity = entities.filter({ $0.isFault == false }) as? [CoreDataObject] else {
            throw RealmMigrationToolError.error("Couldn't get entity without faulty data")
        }
        return bestEntity
    }

    private func getDataFromCoreDataEntity(entity: NSManagedObject)-> [String: Any] {
        let names = entity.entity.properties.map({$0.name})
        var dataDictionary: [String: Any] = [:]
        names.forEach { name in
            dataDictionary[name] = entity.value(forKey: name)
        }
        return dataDictionary
    }
}
