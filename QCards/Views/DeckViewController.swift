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

class DeckViewController: UITableViewController {
    
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    private let cellIdentifier = "cellIdentifier"
    private var viewModel: DeckViewModel!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

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
            .bind(to: self.tableView.rx.items(cellIdentifier: cellIdentifier, cellType: DeckTableViewCell.self)) { _, item, cell in
                cell.configure(withItem: item)
            }.disposed(by: disposeBag)
        
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //let edit = editAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        
        let swipeActions = UISwipeActionsConfiguration(actions: [delete])
        swipeActions.performsFirstActionWithFullSwipe = false
        
        return swipeActions
        //return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    /*private func editAction(at indexPath: IndexPath) -> UIContextualAction {
     let action = UIContextualAction(style: .normal, title: "Edit", handler: { _, _, completion in
     self.displayAlertToAddCategory(indexPath.row)
     completion(true)
     })
     action.image = #imageLiteral(resourceName: "edit")
     action.backgroundColor = .purple
     
     return action
     }*/
    
    private func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let deck = viewModel.decks.value[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "Delete", handler: { _, _, completion in
            DispatchQueue.global(qos: .background).async {
                if let id = deck.id {
                    self.viewModel.onRemoveDeck(id: id)
                }
            }
            
            completion(true)
        })
        
        action.image = #imageLiteral(resourceName: "trash")
        action.backgroundColor = .red
        
        return action
    }
    
    /*
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
     deckItem?.onItemSelected()
     
     tableView.deselectRow(at: indexPath, animated: true)
     }*/
    /*
     func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
     
     let deckItem = viewModel.decks[indexPath.row]
     
     var menuActions: [UIContextualAction] = []
     
     _ = deckItem?.menuItems?.map({ menuItem in
     let menuAction = UIContextualAction(style: .normal, title: menuItem.title!) { (action, sourceView, success: (Bool) -> (Void)) in
     
     if let delegate = menuItem {
     DispatchQueue.global(qos: .background).async {
     delegate.onMenuItemSelected()
     }
     }
     
     success(true)
     }
     
     //deleteAction.image = UIImage(named: "delete-icon")
     //menuAction.backgroundColor = menuItem.backColor!.hexColor
     menuActions.append(menuAction)
     })
     
     return UISwipeActionsConfiguration(actions: menuActions)
     }
     */
}
