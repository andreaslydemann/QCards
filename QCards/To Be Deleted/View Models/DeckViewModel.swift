//
//  DeckViewModel.swift
//  QCards
//
//  Created by Andreas Lüdemann on 06/02/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RealmSwift
import RxCocoa
import RxSwift

class DeckViewModel {
    
    // MARK: inputs
    private let deckProvider: IDeckProvider?
    let selectedDeck = PublishSubject<IndexPath>()
    let deleteCommand = PublishSubject<Int>()
    let addCommand = PublishSubject<String>()
    
    // MARK: outputs
    public let deckss: BehaviorRelay<[Deck]> = BehaviorRelay(value: [])
    
    public var decks: Results<DeckEntity>!
    private var disposeBag = DisposeBag()
    
    init(deckProvider: IDeckProvider) {
        
        self.deckProvider = deckProvider
        
        fetchDecks()
        
        setupCommands()

        
        /*if let deckResults = self.deckProvider?.fetch() {
            observeChanges(to: deckResults)
        }*/
    }
    
    private func fetchDecks() {
        let decks = self.deckProvider?.fetch()
        Observable.collection(from: decks!)
            .map({ $0 })
            .subscribe(onNext: { decks in
                self.decks = decks
            })
            .disposed(by: disposeBag)
    }
    
    
    private func setupCommands() {
        deleteCommand
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [unowned self] index in
                let deck = self.decks[index]
                self.deckProvider?.delete(deck: deck)
            })
            .disposed(by: disposeBag)
        
        addCommand
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [unowned self] name in
                self.deckProvider?.add(name: name)
            })
            .disposed(by: disposeBag)
    }
}
