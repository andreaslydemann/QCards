//
//  DeckProvider.swift
//  QCards
//
//  Created by Andreas Lüdemann on 10/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RealmSwift

class DeckProvider {
    private var realm: Realm!
    static let shared = DeckProvider()
    
    init() {
        do {
            print(Realm.Configuration.defaultConfiguration.fileURL!)
            realm = try Realm()
        } catch {
            fatalError("Could not create instance of realm")
        }
    }
    
    public func fetch() -> Results<DeckEntity> {
        return realm.objects(DeckEntity.self)
    }
    
    func add(name: String) {
        var id: Int? = 1
        
        let deckNameIsNew = realm.objects(DeckEntity.self).filter({ $0.name.lowercased() == name.lowercased() }).isEmpty
        if !deckNameIsNew {
            print("Deck name already exists.")
            return
        }
        
        if let lastEntity = realm.objects(DeckEntity.self).last {
            id = lastEntity.id + 1
        }
        
        let deckEntity = DeckEntity()
        deckEntity.id = id!
        deckEntity.name = name
        
        do {
            try realm.write {
                realm.add(deckEntity)
            }
        } catch {
            print("Error adding deck \(error)")
        }
    }
    
    func delete(primaryKey: Int) {
        do {
            if let deckEntity = realm.object(ofType: DeckEntity.self, forPrimaryKey: primaryKey) {
                try realm.write {
                    realm.delete(deckEntity)
                }
            }
        } catch {
            print("Error deleting deck, \(error)")
        }
    }
}
