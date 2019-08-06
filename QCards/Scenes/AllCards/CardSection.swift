//
//  CardSection.swift
//  QCards
//
//  Created by Andreas Lüdemann on 06/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RxDataSources

struct CardSection {
    var items: [CardItemViewModel]
}

extension CardSection: AnimatableSectionModelType {
    var identity: String { return "CardSection" }
    
    init(original: CardSection, items: [CardItemViewModel]) {
        self = original
        self.items = items
    }
}
