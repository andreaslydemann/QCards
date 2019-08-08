//
//  ThemeManager.swift
//  QCards
//
//  Created by Andreas Lüdemann on 08/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTheme
import UIKit

let globalStatusBarStyle = BehaviorRelay<UIStatusBarStyle>(value: .default)
let themeService = ThemeType.service(initial: ThemeType.currentTheme())

protocol Theme {
    var primary: UIColor { get }
    var secondary: UIColor { get }
    var activeTint: UIColor { get }
    var inactiveTint: UIColor { get }
    var action: UIColor { get }
    var danger: UIColor { get }
    var statusBarStyle: UIStatusBarStyle { get }
    var barStyle: UIBarStyle { get }
    var keyboardAppearance: UIKeyboardAppearance { get }
    var blurStyle: UIBlurEffect.Style { get }
}

struct LightTheme: Theme {
    let primary = UIColor.UIColorFromHex(hex: "#A8E4FF")
    let secondary = UIColor.UIColorFromHex(hex: "#E3FCF1")
    let activeTint = UIColor.black
    let inactiveTint = UIColor.darkGray
    let action = UIColor.UIColorFromHex(hex: "#82A392")
    let danger = UIColor.UIColorFromHex(hex: "#DF245E")
    let statusBarStyle = UIStatusBarStyle.default
    let barStyle = UIBarStyle.default
    let keyboardAppearance = UIKeyboardAppearance.light
    let blurStyle = UIBlurEffect.Style.extraLight
}

struct DarkTheme: Theme {
    let primary = UIColor.UIColorFromHex(hex: "#15202B")
    let secondary = UIColor.UIColorFromHex(hex: "#10171E")
    let activeTint = UIColor.white
    let inactiveTint = UIColor.lightGray
    let action = UIColor.UIColorFromHex(hex: "#1DA1F2")
    let danger = UIColor.UIColorFromHex(hex: "#DF245E")
    let statusBarStyle = UIStatusBarStyle.lightContent
    let barStyle = UIBarStyle.black
    let keyboardAppearance = UIKeyboardAppearance.dark
    let blurStyle = UIBlurEffect.Style.dark
}

enum ThemeType: ThemeProvider {
    case light, dark
    
    var associatedObject: Theme {
        switch self {
        case .light: return LightTheme()
        case .dark: return DarkTheme()
        }
    }
    
    var isDark: Bool {
        switch self {
        case .dark: return true
        default: return false
        }
    }
}

extension ThemeType {
    static func currentTheme() -> ThemeType {
        let isDark = UserDefaults.standard.bool(forKey: "DarkModeKey")
        let theme = isDark ? ThemeType.dark : ThemeType.light
        theme.save()
        return theme
    }
    
    func save() {
        UserDefaults.standard.set(self.isDark, forKey: "DarkModeKey")
    }
}

extension Reactive where Base: UIView {
    
    var backgroundColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.backgroundColor = attr
        }
    }
}

extension Reactive where Base: UITableViewRowAction {
    
    var backgroundColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.backgroundColor = attr
        }
    }
}

extension Reactive where Base: UITextField {
    
    var placeholderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            if let color = attr {
                view.setPlaceHolderTextColor(color)
            }
        }
    }
}

extension Reactive where Base: UINavigationBar {
    
    @available(iOS 11.0, *)
    var largeTitleTextAttributes: Binder<[NSAttributedString.Key: Any]?> {
        return Binder(self.base) { view, attr in
            view.largeTitleTextAttributes = attr
        }
    }
}

extension Reactive where Base: UIApplication {
    
    var statusBarStyle: Binder<UIStatusBarStyle> {
        return Binder(self.base) { _, attr in
            globalStatusBarStyle.accept(attr)
        }
    }
}
