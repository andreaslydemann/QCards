//
//  CardsViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 06/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class CardsViewController: UIViewController {
    
    var viewModel: CardsViewModel!
    
    private let disposeBag = DisposeBag()
    private let store = PublishSubject<(RowAction, Int)>()
    
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    private let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: nil)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        tableView.register(CardTableViewCell.self, forCellReuseIdentifier: CardTableViewCell.reuseID)
        tableView.rowHeight = 65
        return tableView
    }()
    
    private lazy var footerView: UIStackView = {
        let footerView = UIStackView(arrangedSubviews: [settingsButton, playButton])
        footerView.distribution = .equalCentering
        return footerView
    }()
    
    private var settingsButton: UIButton = {
        let settingsButton = UIButton(type: .system)
        settingsButton.setImage(UIImage(named: "settings"), for: .normal)
        settingsButton.tintColor = .black
        return settingsButton
    }()
    
    private var playButton: UIButton = {
        let playButton = UIButton(type: .system)
        playButton.setImage(UIImage(named: "play"), for: .normal)
        playButton.tintColor = .black
        return playButton
    }()
    
    private var divider: UIView = {
        let divider = UIView()
        divider.backgroundColor = .lightGray
        divider.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        return divider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
        bindViewModel()
    }
    
    private func setupTableView() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        view.addSubview(tableView)
        view.addSubview(divider)
        view.addSubview(footerView)
        
        tableView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: divider.topAnchor, trailing: view.trailingAnchor)
        divider.anchor(top: tableView.bottomAnchor, leading: view.leadingAnchor, bottom: footerView.topAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: 1))
        footerView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 15, bottom: 0, right: 15), size: .init(width: 0, height: 50))
        
        view.backgroundColor = .white
    }
    
    private func setupNavigationBar() {
        let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = UIColor.UIColorFromHex(hex: "#0E3D5B")
        navigationController?.navigationBar.barStyle = .black
        navigationController?.view.tintColor = .white
        navigationItem.rightBarButtonItems = [addButton, editButton]
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let deleteCardTrigger = store
            .filter { $0.0 == RowAction.delete }.flatMap { _, row in
                return UIAlertController
                    .present(in: self, text: UIAlertController.AlertText(
                        title: "Do you want to delete this card?",
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
        
        let input = CardsViewModel.Input(
            trigger: viewWillAppear,
            selection: tableView.rx.itemSelected.asDriver(),
            presentationTrigger: playButton.rx.tap.asDriver(),
            createCardTrigger: addButton.rx.tap.asDriver(),
            deleteCardTrigger: deleteCardTrigger.asDriverOnErrorJustComplete(),
            editOrderTrigger: editButton.rx.tap.asDriver())
        
        let output = viewModel.transform(input: input)
        
        [output.cards
            .map { [CardSection(items: $0)] }
            .drive(tableView.rx.items(dataSource: createDataSource())),
         output.editing.do(onNext: { editing in
            self.tableView.isEditing = editing
         }).drive(),
         output.presentation.drive(),
         output.createCard.drive(),
         output.deleteCard.drive(),
         output.selectedCard.drive()]
            .forEach({$0.disposed(by: disposeBag)})
    }
    
    private func createDataSource() -> RxTableViewSectionedAnimatedDataSource<CardSection> {
        return RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: { _, tableView, indexPath, card -> CardTableViewCell in
                let cell = tableView.dequeueReusableCell(withIdentifier: CardTableViewCell.reuseID, for: indexPath) as! CardTableViewCell
                cell.shouldIndentWhileEditing = true
                cell.accessoryType = .disclosureIndicator
                cell.bind(card)
                return cell
        },
            canEditRowAtIndexPath: { _, _ in true },
            canMoveRowAtIndexPath: { _, _ in true }
        )
    }
}

extension CardsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: "Delete") { _, indexPath in
            self.store.onNext((RowAction.delete, indexPath.row))
        }
        
        return [deleteButton]
    }
}

struct CardSection {
    var items: [CardItemViewModel]
}

extension CardSection: AnimatableSectionModelType {
    var identity: String { return "CardSection" }
    
    init(original: CardSection, items: [CardItemViewModel]) {
        self = original
        self.items = items
    }
}
