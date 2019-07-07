//
//  RMCard.swift
//  Platform
//
//  Created by Andreas Lüdemann on 08/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Realm
import RealmSwift

final class RMCard: Object {
    @objc dynamic var uid: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var content: String = ""
    @objc dynamic var deckId: String = ""
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension RMCard {
    static var uid: Attribute<String> { return Attribute("uid")}
    static var title: Attribute<String> { return Attribute("title")}
    static var content: Attribute<String> { return Attribute("content")}
    static var deckId: Attribute<String> { return Attribute("deckId")}
}

extension RMCard: DomainConvertibleType {
    func asDomain() -> Card {
        return Card(uid: uid,
                    title: title,
                    content: content,
                    deckId: deckId)
    }
}

extension Card: RealmRepresentable {
    func asRealm() -> RMCard {
        return RMCard.build { object in
            object.uid = uid
            object.title = title
            object.content = content
            object.deckId = deckId
        }
    }
}
