//
//  TimeSection.swift
//  QCards
//
//  Created by Andreas Lüdemann on 06/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RxDataSources

struct TimeSection {
    var items: [TimePerCardCellViewModel]
}

extension TimeSection: SectionModelType {
    init(original: TimeSection, items: [TimePerCardCellViewModel]) {
        self = original
        self.items = items
    }
}
