//
//  CardsViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 06/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import Foundation
import RxCocoa
import RxSwift

final class CardsViewModel: ViewModelType {
    
    struct Input {
        let editTrigger: Driver<Void>
    }
    
    struct Output {
        let editing: Driver<Bool>
    }
    
    private let deck: Deck
    private let useCase: DecksUseCase
    private let navigator: CardsNavigator
    
    init(deck: Deck, useCase: DecksUseCase, navigator: CardsNavigator) {
        self.deck = deck
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let editing = input.editTrigger.scan(false) { editing, _ in
            return !editing
            }.startWith(false)
        
        return Output(editing: editing)
    }
}
