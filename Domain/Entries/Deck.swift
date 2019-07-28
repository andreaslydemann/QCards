//
//  Deck.swift
//  Domain
//
//  Created by Andreas Lüdemann on 27/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation

public struct Deck {
    public let title: String
    public let uid: String
    public let createdAt: String
    
    public init(title: String,
                uid: String,
                createdAt: String) {
        self.title = title
        self.uid = uid
        self.createdAt = createdAt
    }
    
    public init(title: String) {
        self.init(title: title, uid: NSUUID().uuidString, createdAt: String(round(Date().timeIntervalSince1970 * 1000)))
    }
}

extension Deck: Equatable {
    public static func == (lhs: Deck, rhs: Deck) -> Bool {
        return lhs.uid == rhs.uid &&
            lhs.title == rhs.title &&
            lhs.createdAt == rhs.createdAt
    }
}
