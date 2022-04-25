//
//  RealmMigrationBaseAssistant.swift
//  RealmMigrationAssistant
//
//  Created by Mateusz Łukasiński on 24/04/2022.
//

import Foundation
import RealmSwift

public enum RealmMigrationToolError: Error {
    case error(String)
}

public enum RealmMigrationStatus {
    case success
    case error(String)
}

protocol RealmMigrationProtocol {
    func migrate(completionHandler: (RealmMigrationStatus)->Void)
}

class RealmMigrationBaseAssistant<RealmObject: Object> {
    
    func createRealmObject(from dictionary: [String: Any]) throws -> RealmObject {
        let tempRealmModel: RealmObject = RealmObject()
        tempRealmModel.createObject(value: dictionary)
        return tempRealmModel
    }
    
    func saveRealmData(data: [RealmObject], completionHandler: (RealmMigrationStatus) -> Void) {
        do {
            let realm = try Realm()
            try realm.write({
                realm.add(data)
                completionHandler(.success)
            })
        } catch {
            completionHandler(.error(error.localizedDescription))
        }
    }
}

import Realm.Private
extension Object {
    func createObject(value: Any) {
        RLMInitializeWithValue(self, value, .partialPrivateShared())
    }
}
