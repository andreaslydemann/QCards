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
    
    private let settingsButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .done, target: self, action: nil)
    private let createDeckButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    private let store = PublishSubject<(RowAction, Int)>()
    
    private lazy var noDecksLabel: UILabel = {
        let label: UILabel  = UILabel()
        label.text          = NSLocalizedString("AllDecks.TableView.Background", comment: "")
        themeService.rx.bind({ $0.inactiveTint }, to: label.rx.textColor).disposed(by: rx.disposeBag)
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
        themeService.rx.bind({ $0.secondary }, to: view.rx.backgroundColor)
    }
    
    private func setupNavigationItems() {
        navigationItem.leftBarButtonItem = settingsButton
        navigationItem.rightBarButtonItem = createDeckButton
        navigationItem.title = NSLocalizedString("AllDecks.Navigation.Title", comment: "")
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let selection = tableView.rx.itemSelected
        
        let createDeckTrigger = createDeckButton.rx.tap.flatMap {
            return UIAlertController
                .present(in: self, text: UIAlertController.AlertText(
                    title: NSLocalizedString("AllDecks.CreateDeck.Title", comment: ""), message: NSLocalizedString("AllDecks.CreateDeck.Subtitle", comment: "")),
                         style: .alert, buttons: [.default(NSLocalizedString("Common.Add", comment: "")), .cancel(NSLocalizedString("Common.Cancel", comment: ""))],
                         textFields: [ {(textfield: UITextField) -> Void in
                            textfield.placeholder = NSLocalizedString("AllDecks.CreateDeck.TitleField.Placeholder", comment: "")
                            textfield.autocapitalizationType = .sentences
                            } ])
            }
            .filter { $0.buttonIndex == 0 }
            .map { $0.1[0] }
        
        let editDeckTrigger = store
            .filter { $0.0 == RowAction.edit }.flatMap { _, row in
                return UIAlertController
                    .present(in: self, text: UIAlertController.AlertText(
                        title: NSLocalizedString("AllDecks.EditDeck.Title", comment: ""), message: NSLocalizedString("AllDecks.EditDeck.Subtitle", comment: "")),
                             style: .alert, buttons: [.default(NSLocalizedString("Common.Update", comment: "")), .cancel(NSLocalizedString("Common.Cancel", comment: ""))],
                             textFields: [ {(textfield: UITextField) -> Void in
                                textfield.placeholder = NSLocalizedString("AllDecks.EditDeck.TitleField.Placeholder", comment: "")
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
                        title: NSLocalizedString("AllDecks.DeleteDeck.Title", comment: ""),
                        message: NSLocalizedString("AllDecks.DeleteDeck.Subtitle", comment: "")),
                             style: .alert,
                             buttons: [.default(NSLocalizedString("Common.Yes", comment: "")), .cancel(NSLocalizedString("Common.No", comment: ""))],
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
            .forEach({$0.disposed(by: rx.disposeBag)})
    }
    
    private func createDataSource() -> RxTableViewSectionedAnimatedDataSource<DeckSection> {
        return RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .automatic,
                                                           reloadAnimation: .automatic,
                                                           deleteAnimation: .left),
            configureCell: { _, tableView, indexPath, deck -> DeckTableViewCell in
                let cell = tableView.dequeueReusableCell(withIdentifier: DeckTableViewCell.reuseID, for: indexPath) as! DeckTableViewCell
                themeService.rx.bind({ $0.primary }, to: cell.rx.backgroundColor).disposed(by: self.rx.disposeBag)
                cell.selectionStyle = .none
                cell.accessoryType = .disclosureIndicator
                cell.bind(to: deck)
                return cell
        },
            canEditRowAtIndexPath: { _, _ in true }
        )
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .default, title: NSLocalizedString("Common.Edit", comment: ""), handler: { [unowned self] _, indexPath in
            self.store.onNext((RowAction.edit, indexPath.row))
        })

        let delete = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Common.Delete", comment: ""), handler: { [unowned self] _, indexPath in
            self.store.onNext((RowAction.delete, indexPath.row))
        })
        
        themeService.rx
            .bind({ $0.action }, to: edit.rx.backgroundColor)
            .bind({ $0.danger }, to: delete.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
        
        return [delete, edit]
    }
}
