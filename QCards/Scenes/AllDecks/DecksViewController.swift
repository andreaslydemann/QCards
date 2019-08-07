//
//  DecksViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 20/03/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class DecksViewController: UITableViewController {
    
    var viewModel: DecksViewModel!
    
    private let disposeBag = DisposeBag()
    private let settingsButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .done, target: self, action: nil)
    private let createDeckButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    private let store = PublishSubject<(RowAction, Int)>()
    
    private var noDecksLabel: UILabel = {
        let label: UILabel  = UILabel()
        label.text          = "No decks found."
        label.textColor     = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupNavigationItems()
        bindViewModel()
    }
    
    private func setupLayout() {
        tableView.rowHeight = 65
        tableView.backgroundView  = noDecksLabel
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(DeckTableViewCell.self, forCellReuseIdentifier: DeckTableViewCell.reuseID)
        view.backgroundColor = UIColor.UIColorFromHex(hex: "#10171E")
    }
    
    private func setupNavigationItems() {
        navigationItem.leftBarButtonItem = settingsButton
        navigationItem.rightBarButtonItem = createDeckButton
        navigationItem.title = "QCards"
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let selection = tableView.rx.itemSelected
        
        let createDeckTrigger = createDeckButton.rx.tap.flatMap {
            return UIAlertController
                .present(in: self, text: UIAlertController.AlertText(
                    title: "Create deck", message: "Input a title for the deck"),
                         style: .alert, buttons: [.default("Add"), .cancel("Cancel")],
                         textFields: [ {(textfield: UITextField) -> Void in
                            textfield.placeholder = "Presentation"
                            textfield.autocapitalizationType = .sentences
                            } ])
            }
            .filter { $0.buttonIndex == 0 }
            .map { $0.1[0] }
        
        let editDeckTrigger = store
            .filter { $0.0 == RowAction.edit }.flatMap { _, row in
                return UIAlertController
                    .present(in: self, text: UIAlertController.AlertText(
                        title: "Edit deck", message: "Update the name of the deck"),
                             style: .alert, buttons: [.default("Update"), .cancel("Cancel")],
                             textFields: [ {(textfield: UITextField) -> Void in
                                textfield.placeholder = "Presentation"
                                textfield.autocapitalizationType = .sentences
                                } ])
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
                                         selection: selection.asDriverOnErrorJustComplete(),
                                         createDeckTrigger: createDeckTrigger.asDriverOnErrorJustComplete(),
                                         editDeckTrigger: editDeckTrigger.asDriverOnErrorJustComplete(),
                                         deleteDeckTrigger: deleteDeckTrigger.asDriverOnErrorJustComplete(),
                                         settingsTrigger: settingsButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        [output.decks
            .map { [DeckSection(items: $0)] }
            .drive(tableView!.rx.items(dataSource: createDataSource())),
         output.selectedDeck.drive(),
         output.createDeck.drive(),
         output.editDeck.drive(),
         output.deleteDeck.drive(),
         output.deleteCards.drive(),
         output.settings.drive(),
         output.decksAvailable.drive(noDecksLabel.rx.isHidden)]
            .forEach({$0.disposed(by: disposeBag)})
    }
    
    private func createDataSource() -> RxTableViewSectionedAnimatedDataSource<DeckSection> {
        return RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .automatic,
                                                           reloadAnimation: .automatic,
                                                           deleteAnimation: .left),
            configureCell: { _, tableView, indexPath, deck -> DeckTableViewCell in
                let cell = tableView.dequeueReusableCell(withIdentifier: DeckTableViewCell.reuseID, for: indexPath) as! DeckTableViewCell
                cell.backgroundColor = UIColor.UIColorFromHex(hex: "#15202B")
                cell.selectionStyle = .none
                cell.accessoryType = .disclosureIndicator
                cell.bind(deck)
                return cell
        },
            canEditRowAtIndexPath: { _, _ in true }
        )
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .default, title: "Edit", handler: { [unowned self] _, indexPath in
            self.store.onNext((RowAction.edit, indexPath.row))
        })
        
        edit.backgroundColor = UIColor.UIColorFromHex(hex: "#1DA1F2")
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [unowned self] _, indexPath in
            self.store.onNext((RowAction.delete, indexPath.row))
        })
        
        delete.backgroundColor = UIColor.UIColorFromHex(hex: "#DF245E")
        
        return [delete, edit]
    }
}
