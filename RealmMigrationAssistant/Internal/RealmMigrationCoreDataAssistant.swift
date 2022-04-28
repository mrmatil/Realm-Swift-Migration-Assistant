//
//  RealmMigrationCoreDataAssistant.swift
//  RealmMigrationAssistant
//
//  Created by Mateusz Łukasiński on 24/04/2022.
//

import Foundation
import RealmSwift
import CoreData

class RealmMigrationCoreDataAssistant<CoreDataObject: NSManagedObject, RealmObject: Object>  : RealmMigrationBaseAssistant<RealmObject>, RealmMigrationProtocol where CoreDataObject: CoreDataMigrationManaged {
    private var context: NSManagedObjectContext?
    private var addedVariables: [[String: Any]]?
    private var removedVariables: [String]?
    private var renamedVariables: [String: String]?
    
    init(context: NSManagedObjectContext?) {
        self.context = context
        super.init()
    }
    
    func changeVariables(addedVariables: [[String: Any]]?, removedVariables: [String]?, renamedVariables: [String: String]?) {
        self.addedVariables = addedVariables
        self.removedVariables = removedVariables
        self.renamedVariables = renamedVariables
    }
    
    func migrate(completionHandler: (RealmMigrationStatus)->Void) {
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

    private func migrate(from coreDataObject: [NSManagedObject], completionHandler: (RealmMigrationStatus)->Void) {
        var realmObjects: [RealmObject] = []
        do {
            if let number = restrictNumber, number > (coreDataObject.count) {
                restrictNumber = coreDataObject.count
            }
            
            if addedVariables != nil, addedVariables?.count != coreDataObject.count {
                throw RealmMigrationToolError.error("Added variables should be in the same quantity as coreDataObjects")
            }
            
            for entity in coreDataObject[0..<(restrictNumber ?? coreDataObject.count)].enumerated() {
                let realmModelFromCoreData = try createRealmObject(from: getDataFromCoreDataEntity(entity: entity.element, addedData: addedVariables?[entity.offset]))
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

    private func getDataFromCoreDataEntity(entity: NSManagedObject, addedData: [String: Any]? = nil)-> [String: Any] {
        let names = entity.entity.properties.map({$0.name})
        var dataDictionary: [String: Any] = [:]
        names.forEach { name in
            dataDictionary[name] = entity.value(forKey: name)
        }
        
        if let addedData = addedData {
            for tempData in addedData {
                dataDictionary[tempData.key] = tempData.value
            }
        }

        if let removedVariables = removedVariables {
            for removedVariable in removedVariables {
                dataDictionary.removeValue(forKey: removedVariable)
            }
        }
        
        if let renamedVariables = renamedVariables {
            for renamedVariable in renamedVariables {
                dataDictionary.switchKey(fromKey: renamedVariable.key, toKey: renamedVariable.value)
            }
        }
        
        return dataDictionary
    }
}

