//
//  Card.swift
//  Domain
//
//  Created by Andreas Lüdemann on 08/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation

public struct Card: Codable {
    public let uid: String
    public let title: String
    public let content: String
    public var orderPosition: Int
    public let deckId: String
    
    public init(uid: String, title: String, content: String, orderPosition: Int, deckId: String
                ) {
        self.uid = uid
        self.title = title
        self.content = content
        self.orderPosition = orderPosition
        self.deckId = deckId
    }
    
    public init(title: String, content: String, orderPosition: Int, deckId: String) {
        self.init(uid: NSUUID().uuidString, title: title, content: content, orderPosition: orderPosition, deckId: deckId)
    }
}

extension Card: Equatable {
    public static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.uid == rhs.uid &&
            lhs.title == rhs.title &&
            lhs.content == rhs.content
    }
}
