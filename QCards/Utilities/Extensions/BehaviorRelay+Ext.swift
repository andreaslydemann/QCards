//
//  BehaviorRelay+Ext.swift
//  QCards
//
//  Created by Andreas Lüdemann on 10/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RxCocoa

extension BehaviorRelay where Element: RangeReplaceableCollection {
    func append(_ element: Element.Element) {
        accept(value + [element])
    }
    
    public func insert(_ subElement: Element.Element, at index: Element.Index) {
        var newValue = value
        newValue.insert(subElement, at: index)
        accept(newValue)
    }
    
    public func insert(contentsOf newSubelements: Element, at index: Element.Index) {
        var newValue = value
        newValue.insert(contentsOf: newSubelements, at: index)
        accept(newValue)
    }
    
    public func remove(at index: Element.Index) {
        print(index)
        var newValue = value
        print(newValue)
        newValue.remove(at: index)
        accept(newValue)
    }
}
