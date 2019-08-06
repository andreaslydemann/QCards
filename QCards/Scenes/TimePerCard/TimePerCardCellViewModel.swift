//
//  TimePerCardCellViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 05/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation

class TimePerCardCellViewModel {
    let timeOption: Int
    let isSelected: Bool
    let displayName: String
    
    init(with timeOption: Int, isSelected: Bool) {
        self.timeOption = timeOption
        self.isSelected = isSelected
        self.displayName = TimePerCard.displayName(option: timeOption)
    }
}
