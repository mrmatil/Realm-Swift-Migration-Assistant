//
//  RealmMigrationAssistant.swift
//  RealmMigrationAssistant
//
//  Created by Mateusz Łukasiński on 25/04/2022.
//

import Foundation
import RealmSwift
import CoreData

public class RealmMigrationAssistant {
    
    private let context: NSManagedObjectContext?
    private weak var delegate: RealmMigrationAssistantDelegate?
    
    private var migrationsFinished: Int = 0 {
        didSet {
            delegate?.migrationProgress(finishedMigrations: migrationsFinished, allMigrations: migrationsCount)
            if migrationsFinished == migrationsCount, migrationsCount > 0 {
                delegate?.migrationSuccess()
            }
        }
    }
    private var migrationsCount: Int { migrations.count }
    
    private var migrations: [RealmMigrationProtocol] = []
    
    init(delegate: RealmMigrationAssistantDelegate?, context: NSManagedObjectContext? = nil) {
        self.context = context
        self.delegate = delegate
    }
    
    public func addMigration<CoreDataObject: NSManagedObject, RealmObject: Object>(coreDataObject: CoreDataObject, realmObject: RealmObject) where CoreDataObject: CoreDataMigrationManaged {
        let migration = RealmMigrationCoreDataAssistant<CoreDataObject, RealmObject>(context: context)
        migrations.append(migration)
    }
    
    public func addMigration<RealmObject: Object>(data: [String: Any], realmObject: RealmObject) {
        let migration = RealmMigrationUserDefaultsAssistant(data: data)
        migrations.append(migration)
    }
    
    public func startMigration() {
        migrationsFinished = 0
        delegate?.migrationProgress(finishedMigrations: migrationsFinished, allMigrations: migrationsCount)
        
        for migration in migrations {
            migration.migrate { status in
                switch status {
                case .success:
                    migrationsFinished += 1
                case .error(let error):
                    delegate?.migrationError(description: error)
                    return
                }
            }
        }
    }
}
