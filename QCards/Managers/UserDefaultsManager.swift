//
//  UserDefaultsManager.swift
//  QCards
//
//  Created by Andreas Lüdemann on 31/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class UserDefaultsManager: NSObject {
    
    static let shared = UserDefaultsManager()
    private let disposeBag = DisposeBag()
    
    let darkModeEnabled = BehaviorRelay(value: UserDefaults.standard.bool(forKey: UserDefaultsKeys.darkModeEnabled))
    
    override init() {
        super.init()
        
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.darkModeEnabled) == nil {
            darkModeEnabled.accept(true)
        }
        
        darkModeEnabled.subscribe(onNext: { (enabled) in
            UserDefaults.standard.set(enabled, forKey: UserDefaultsKeys.darkModeEnabled)
        }).disposed(by: disposeBag)
        
    }
    
    struct UserDefaultsKeys {
        static let darkModeEnabled = "DarkModeEnabled"
    }
}
