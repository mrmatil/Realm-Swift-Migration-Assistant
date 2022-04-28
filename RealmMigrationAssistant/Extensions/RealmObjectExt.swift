//
//  RealmObjectExt.swift
//  RealmMigrationAssistant
//
//  Created by Mateusz Łukasiński on 28/04/2022.
//

import Foundation

import RealmSwift
import Realm.Private

extension Object {
    func createObject(value: Any) {
        RLMInitializeWithValue(self, value, .partialPrivateShared())
    }
}
