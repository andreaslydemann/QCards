//
//  DarkModeCellViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 08/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import RxCocoa
import RxSwift

final class DarkModeCellViewModel: SwitchCellViewModel {
    override func transform(input: SwitchCellViewModel.Input) -> SwitchCellViewModel.Output {
        let isEnabled = super.transform(input: input).isEnabled
            .do(onNext: { isDarkMode in themeService.switch(isDarkMode ? .dark : .light) })
        
        return Output(isEnabled: isEnabled)
    }
}
