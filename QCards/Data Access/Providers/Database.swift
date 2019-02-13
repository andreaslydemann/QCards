//
//  RealmEntityProvider.swift
//  QCards
//
//  Created by Andreas Lüdemann on 13/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RealmSwift

class Database {
    func getRealm() -> Realm {
        guard let realm = try? Realm() else {
            fatalError("Could not create instance of realm")
        }
        
        return realm
    }
    
    func resetDatabase() {
        let realm = getRealm()
        realm.beginWrite()
        realm.deleteAll()
        
        do {
            try realm.commitWrite()
        } catch {
            print("Error while writing to database")
        }
    }
    
    func printDatabaseLocation() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
}
