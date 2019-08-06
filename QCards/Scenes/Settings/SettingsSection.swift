//
//  SettingsSection.swift
//  QCards
//
//  Created by Andreas Lüdemann on 06/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RxDataSources

enum SettingsSection {
    case setting(title: String, items: [SettingsSectionItem])
}

enum SettingsSectionItem {
    case timePerCardItem(viewModel: TimeCellViewModel)
    case nextCardVibrateItem(viewModel: SwitchCellViewModel)
    case nextCardFlashItem(viewModel: SwitchCellViewModel)
}

extension SettingsSection: SectionModelType {
    var title: String {
        switch self {
        case .setting(let title, _): return title
        }
    }
    
    var items: [SettingsSectionItem] {
        switch self {
        case .setting(_, let items): return items.map {$0}
        }
    }
    
    init(original: SettingsSection, items: [SettingsSectionItem]) {
        switch original {
        case .setting(let title, let items): self = .setting(title: title, items: items)
        }
    }
}

