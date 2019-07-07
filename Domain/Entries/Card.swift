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
    public let deckId: String
    
    public init(uid: String, title: String, content: String, deckId: String
                ) {
        self.uid = uid
        self.title = title
        self.content = content
        self.deckId = deckId
    }
    
    public init(title: String, content: String, deckId: String) {
        self.init(uid: NSUUID().uuidString, title: title, content: content, deckId: deckId)
    }
    
    private enum CodingKeys: String, CodingKey {
        case uid
        case title
        case content
        case deckId
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        
        if let uid = try container.decodeIfPresent(Int.self, forKey: .uid) {
            self.uid = "\(uid)"
        } else {
            uid = try container.decodeIfPresent(String.self, forKey: .uid) ?? ""
        }
        
        if let deckId = try container.decodeIfPresent(Int.self, forKey: .deckId) {
            self.deckId = "\(deckId)"
        } else {
            deckId = try container.decodeIfPresent(String.self, forKey: .deckId) ?? ""
        }
    }
}

extension Card: Equatable {
    public static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.uid == rhs.uid &&
            lhs.title == rhs.title &&
            lhs.content == rhs.content
    }
}
