//
//  ViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 20/11/2018.
//  Copyright © 2018 Andreas Lüdemann. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

struct SectionOfDecks {
    var header: String?
    var items: [Deck]
}

extension SectionOfDecks: AnimatableSectionModelType {
    typealias Item = Deck
    
    var identity: String { return self.header ?? "SectionOfDecks" }
    
    init(original: SectionOfDecks, items: [Deck]) {
        self = original
        self.items = items
    }
}

class DeckViewController: UITableViewController {
    
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    private let cellIdentifier = "cellIdentifier"
    private var viewModel: DeckViewModel!
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<SectionOfDecks>!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = createDataSource()
        viewModel = DeckViewModel(deckProvider: DeckProvider.shared)

        setupTableView()
        setupNavigationBar()
        setupBindings()
    }
    
    private func setupTableView() {
        tableView.register(DeckTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = 80
        view.backgroundColor = .white
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.UIColorFromHex(hex: "#34495e")
        navigationItem.rightBarButtonItem = addButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.title = "QCards"
    }

    private func setupBindings() {
        viewModel
            .decks
            .asObservable()
            .map { decks in
                [SectionOfDecks(header: "My decks", items: decks)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        addButton.rx.tap.subscribe(onNext: { _ in
            let actions: [UIAlertController.AlertAction] = [
                .action(title: "Add", style: .default),
                .action(title: "Cancel", style: .cancel)
            ]
            
            let textField = UITextField()
            textField.placeholder = "Presentation"
            
            UIAlertController
                .present(in: self, text: UIAlertController.AlertText(title: "Create deck", message: "Input a name for the deck"), style: .alert, actions: actions, textFields: [textField])
                .filter({ element in
                    if let inputText = element.inputText, !inputText.isEmpty {
                        return element.index == 0 && !inputText[0].isEmpty
                    } else {
                        return element.index == 0
                    }
                })
                .subscribe(onNext: { element in
                    if let deckName = element.inputText?[0] {
                        DispatchQueue.global(qos: .background).async {
                            self.viewModel.onAddDeck(name: deckName)
                        }
                    }
                })
                .disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        viewModel.decks
            .map { decks in [SectionOfDecks(header: "My decks", items: decks)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }).disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .bind(to: self.viewModel.deleteCommand)
            .disposed(by: disposeBag)
    }
    
    @objc func dismissAlertController() {
        self.dismiss(animated: true, completion: nil)
    }

    private func createDataSource() -> RxTableViewSectionedAnimatedDataSource<SectionOfDecks> {
        return RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .left),
            configureCell: { _, tableView, indexPath, deck -> DeckTableViewCell in
                let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! DeckTableViewCell
                cell.configure(withItem: deck)
                return cell
        },
            canEditRowAtIndexPath: { _, _ in true }
        )
    }
}
