//
//  RealmMigrationUserDefaultsAssistant.swift
//  RealmMigrationAssistant
//
//  Created by Mateusz Łukasiński on 24/04/2022.
//

import Foundation
import RealmSwift

protocol RealmMigrationUserDefaultsAssistantProtocol {
    func migrate(completionHandler: (RealmMigrationStatus) -> Void)
}

class RealmMigrationUserDefaultsAssistant<RealmObject: Object>: RealmMigrationBaseAssistant<RealmObject>, RealmMigrationUserDefaultsAssistantProtocol {
    
    private var userDefaultsData: [String: Any]
    
    init(data: [String: Any]) {
        self.userDefaultsData = data
    }
    
    func migrate(completionHandler: (RealmMigrationStatus) -> Void) {
        do {
            let realmObject = try createRealmObject(from: userDefaultsData)
            saveRealmData(data: [realmObject], completionHandler: completionHandler)
        } catch RealmMigrationToolError.error(let description) {
            completionHandler(.error(description))
        } catch {
            completionHandler(.error(error.localizedDescription))
        }
    }
}
