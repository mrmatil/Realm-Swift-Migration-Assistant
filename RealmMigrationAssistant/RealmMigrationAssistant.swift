//
//  RealmMigrationAssistant.swift
//  RealmMigrationAssistant
//
//  Created by Mateusz Łukasiński on 25/04/2022.
//

import Foundation
import RealmSwift
import CoreData

protocol RealmMigrationAssistantDelegate: AnyObject {
    func migrationSuccess()
    func migrationError(description: String)
    func migrationProgress(finishedMigrations: Int, allMigrations: Int)
}

public class RealmMigrationAssistant {
    
    private let context: NSManagedObjectContext?
    private weak var delegate: RealmMigrationAssistantDelegate?
    
    private var migrationsFinished: Int = 0
    private var migrationsCount: Int {
        coreDataMigrations.count + userDefaultsMigrations.count
    }
    
    private var coreDataMigrations: [RealmMigrationCoreDataAssistantProtocol] = []
    private var userDefaultsMigrations: [RealmMigrationUserDefaultsAssistantProtocol] = []
    
    init(delegate: RealmMigrationAssistantDelegate?, context: NSManagedObjectContext? = nil) {
        self.context = context
        self.delegate = delegate
    }
    
    public func addMigration<CoreDataObject: NSManagedObject, RealmObject: Object>(coreDataObject: CoreDataObject, realmObject: RealmObject) where CoreDataObject: CoreDataMigrationManaged {
        let migration = RealmMigrationCoreDataAssistant<CoreDataObject, RealmObject>(context: context)
        coreDataMigrations.append(migration)
    }
    
    public func addMigration<RealmObject: Object>(data: [String: Any], realmObject: RealmObject) {
        let migration = RealmMigrationUserDefaultsAssistant(data: data)
        userDefaultsMigrations.append(migration)
    }
    
    public func startMigration() {
        migrationsFinished = 0
        delegate?.migrationProgress(finishedMigrations: migrationsFinished, allMigrations: migrationsCount)
        
        //
    }
}
