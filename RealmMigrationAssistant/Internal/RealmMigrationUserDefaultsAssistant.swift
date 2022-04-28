//
//  RealmMigrationUserDefaultsAssistant.swift
//  RealmMigrationAssistant
//
//  Created by Mateusz Łukasiński on 24/04/2022.
//

import Foundation
import RealmSwift

class RealmMigrationUserDefaultsAssistant<RealmObject: Object>: RealmMigrationBaseAssistant<RealmObject>, RealmMigrationProtocol {
    
    private var userDefaultsData: [[String: Any]]
    
    init(data: [[String: Any]]) {
        self.userDefaultsData = data
    }
    
    func migrate(completionHandler: (RealmMigrationStatus) -> Void) {
        do {
            var realmObjects: [RealmObject] = []
            for tempData in userDefaultsData {
                let realmObject = try createRealmObject(from: tempData)
                realmObjects.append(realmObject)
            }
            saveRealmData(data: realmObjects, completionHandler: completionHandler)
        } catch RealmMigrationToolError.error(let description) {
            completionHandler(.error(description))
        } catch {
            completionHandler(.error(error.localizedDescription))
        }
    }
}
