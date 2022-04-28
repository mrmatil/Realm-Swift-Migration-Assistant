//
//  DictionaryExt.swift
//  RealmMigrationAssistant
//
//  Created by Mateusz Łukasiński on 28/04/2022.
//

import Foundation

extension Dictionary {
    mutating func switchKey(fromKey: Key, toKey: Key) {
        if let entry = removeValue(forKey: fromKey) {
            self[toKey] = entry
        }
    }
}
