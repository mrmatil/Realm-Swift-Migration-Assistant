//
//  RealmMigrationAssistantDelegate.swift
//  RealmMigrationAssistant
//
//  Created by Mateusz Łukasiński on 25/04/2022.
//

import Foundation

public protocol RealmMigrationAssistantDelegate: AnyObject {
    func migrationSuccess()
    func migrationError(description: String)
    func migrationProgress(finishedMigrations: Int, allMigrations: Int)
}

public extension RealmMigrationAssistantDelegate {
    func migrationProgress(finishedMigrations: Int, allMigrations: Int) { }
}
