//
//  DecksViewModelTests.swift
//  QCardsTests
//
//  Created by Andreas Lüdemann on 19/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
@testable import QCards
import RxCocoa
import RxSwift
import XCTest

class DecksViewModelTests: XCTestCase {
    
    var decksUseCase: DecksUseCaseMock!
    var cardsUseCase: CardsUseCaseMock!
    var navigator: DecksNavigatorMock!
    var viewModel: DecksViewModel!
    
    override func setUp() {
        super.setUp()
        
        decksUseCase = DecksUseCaseMock()
        cardsUseCase = CardsUseCaseMock()
        navigator = DecksNavigatorMock()
        
        viewModel = DecksViewModel(decksUseCase: decksUseCase, cardsUseCase: cardsUseCase, navigator: navigator)
    }
    
    func test_transform_triggerInvoked_decksEmitted() {
        // arrange
        let trigger = PublishSubject<Void>()
        let input = createInput(trigger: trigger)
        let output = viewModel.transform(input: input)
        
        // act
        output.decks.drive().disposed(by: rx.disposeBag)
        trigger.onNext(())
        
        // assert
        XCTAssert(decksUseCase.decks_Called)
    }
    
    func test_transform_selectedDeckInvoked_navigateToDeck() {
        // arrange
        let select = PublishSubject<IndexPath>()
        let output = viewModel.transform(input: createInput(selection: select))
        let decks = createDecks()
        decksUseCase.decks_ReturnValue = Observable.just(decks)
        
        // act
        output.decks.drive().disposed(by: rx.disposeBag)
        output.selectedDeck.drive().disposed(by: rx.disposeBag)
        select.onNext(IndexPath(row: 1, section: 0))
        
        // assert
        XCTAssertTrue(navigator.toDeck_deck_Called)
        XCTAssertEqual(navigator.toDeck_deck_ReceivedArguments, decks[0])
    }
    
    private func createInput(trigger: Observable<Void> = Observable.just(()),
                             selection: Observable<IndexPath> = Observable.never(),
                             createDeckTrigger: Observable<String> = Observable.never(),
                             editDeckTrigger: Observable<(title: String, row: Int)> = Observable.never(),
                             deleteDeckTrigger: Observable<Int> = Observable.never(),
                             settingsTrigger: Observable<Void> = Observable.never())
        -> DecksViewModel.Input {
            return DecksViewModel.Input(trigger: trigger.asDriverOnErrorJustComplete(),
                                        selection: selection.asDriverOnErrorJustComplete(),
                                        createDeckTrigger: createDeckTrigger.asDriverOnErrorJustComplete(),
                                        editDeckTrigger: editDeckTrigger.asDriverOnErrorJustComplete(),
                                        deleteDeckTrigger: deleteDeckTrigger.asDriverOnErrorJustComplete(),
                                        settingsTrigger: settingsTrigger.asDriverOnErrorJustComplete())
    }
    
    private func createDecks() -> [Deck] {
        return [
            Deck(title: "title 1", uid: "uid 1", createdAt: "created at 1"),
            Deck(title: "title 2", uid: "uid 2", createdAt: "created at 2")
        ]
    }
}
