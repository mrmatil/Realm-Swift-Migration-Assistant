//
//  RealmMigrationUserDefaultsAssistant.swift
//  RealmMigrationAssistant
//
//  Created by Mateusz Łukasiński on 24/04/2022.
//

import Foundation
import RealmSwift

public class RealmMigrationUserDefaultsAssistant<RealmObject: Object>: RealmMigrationBaseAssistant<RealmObject> {
    
    private var userDefaultsData: [String: Any]
    
    public init(data: [String: Any]) {
        self.userDefaultsData = data
    }
    
    public func migrate(completionHandler: (RealmMigrationStatus) -> Void) {
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
