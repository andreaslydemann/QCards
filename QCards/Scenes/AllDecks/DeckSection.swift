//
//  DeckSection.swift
//  QCards
//
//  Created by Andreas Lüdemann on 06/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RxDataSources

struct DeckSection {
    var items: [DeckItemViewModel]
}

extension DeckSection: AnimatableSectionModelType {
    var identity: String { return "DeckSection" }
    
    init(original: DeckSection, items: [DeckItemViewModel]) {
        self = original
        self.items = items
    }
}
