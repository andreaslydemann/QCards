//
//  DecksViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 20/03/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import RxCocoa
import RxSwift
import UIKit

class DecksViewController: UITableViewController {
    
    private let disposeBag = DisposeBag()
    private let createDeckButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    private let store = PublishSubject<(RowAction, Int)>()
    var viewModel: DecksViewModel!
    
    enum RowAction {
        case edit
        case delete
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
        bindViewModel()
    }
    
    private func setupTableView() {
        tableView.register(DeckTableViewCell.self, forCellReuseIdentifier: DeckTableViewCell.reuseID)
        tableView.rowHeight = 80
        view.backgroundColor = .white
    }
    
    private func setupNavigationBar() {
        let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = UIColor.UIColorFromHex(hex: "#34495e")
        navigationController?.navigationBar.barStyle = .black
        navigationItem.rightBarButtonItem = createDeckButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.title = "QCards"
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let createDeckTrigger = createDeckButton.rx.tap.flatMap {
            return UIAlertController
                .present(in: self, text: UIAlertController.AlertText(
                    title: "Create deck", message: "Input a title for the deck"),
                         style: .alert, buttons: [.default("Add"), .cancel("Cancel")],
                         textFields: [ {(textfield: UITextField) -> Void in textfield.placeholder = "Presentation"} ])
            }
            .filter { $0.buttonIndex == 0 }
            .map { $0.1[0] }
        
        let editDeckTrigger = store
            .filter { $0.0 == RowAction.edit }.flatMap { _, row in
                return UIAlertController
                    .present(in: self, text: UIAlertController.AlertText(
                        title: "Edit deck", message: "Update the name of the deck"),
                             style: .alert, buttons: [.default("Update"), .cancel("Cancel")],
                             textFields: [ {(textfield: UITextField) -> Void in textfield.placeholder = "Presentation"} ])
                    .withLatestFrom(Observable.just(row)) { ($0, $1) }
            }
            .filter { $0.0.buttonIndex == 0 }
            .map { return (title: $0.0.texts[0], row: $0.1) }
        
        let deleteDeckTrigger = store
            .filter { $0.0 == RowAction.delete }.flatMap { _, row in
                return UIAlertController
                    .present(in: self, text: UIAlertController.AlertText(
                        title: "Do you want to delete this deck?",
                        message: "You can't undo this action"),
                             style: .alert,
                             buttons: [.default("Yes"), .cancel("No")],
                             textFields: [])
                    .withLatestFrom(Observable.just(row)) { alertData, row in
                        return (alertData.0, row)
                }
            }
            .filter { $0.0 == 0 }
            .map { $0.1 }
        
        let input = DecksViewModel.Input(trigger: viewWillAppear,
                                         createDeckTrigger: createDeckTrigger.asDriverOnErrorJustComplete(),
                                         editDeckTrigger: editDeckTrigger.asDriverOnErrorJustComplete(),
                                         deleteDeckTrigger: deleteDeckTrigger.asDriverOnErrorJustComplete())
        let output = viewModel.transform(input: input)
        
        [output.decks.drive(tableView.rx.items(cellIdentifier: DeckTableViewCell.reuseID, cellType: DeckTableViewCell.self)) { _, viewModel, cell in
            cell.bind(viewModel)
            },
         output.createDeck.drive(),
         output.editDeck.drive(),
         output.deleteDeck.drive()]
            .forEach({$0.disposed(by: disposeBag)})
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = .disclosureIndicator
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .default, title: "Edit", handler: { [unowned self] _, indexPath in
            self.store.onNext((RowAction.edit, indexPath.row))
        })
        
        edit.backgroundColor = .red
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [unowned self] _, indexPath in
            self.store.onNext((RowAction.delete, indexPath.row))
        })
        
        delete.backgroundColor = .blue
        
        return [delete, edit]
    }
}
