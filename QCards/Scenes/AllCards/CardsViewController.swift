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

class CardsViewController: UIViewController {
    
    var viewModel: CardsViewModel!
    
    private let rowActionStore = PublishSubject<(RowAction, Int)>()
    private let cardsStore = PublishSubject<[CardItemViewModel]>()
    
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    private let editButton = UIBarButtonItem(title: NSLocalizedString("Common.Edit", comment: ""), style: .plain, target: self, action: nil)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds)
        tableView.register(CardTableViewCell.self, forCellReuseIdentifier: CardTableViewCell.reuseID)
        tableView.rowHeight = 65
        return tableView
    }()
    
    private lazy var footerView: UIStackView = {
        let footerView = UIStackView(arrangedSubviews: [playButton])
        footerView.distribution = .equalCentering
        return footerView
    }()
    
    private lazy var playButton: UIButton = {
        let playButton = UIButton(type: .system)
        playButton.setImage(UIImage(named: "play"), for: .normal)
        themeService.rx.bind({ $0.action }, to: playButton.rx.tintColor).disposed(by: rx.disposeBag)
        return playButton
    }()
    
    private lazy var divider: UIView = {
        let divider = UIView()
        themeService.rx.bind({ $0.inactiveTint }, to: divider.rx.backgroundColor).disposed(by: rx.disposeBag)
        divider.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        return divider
    }()
    
    private lazy var noCardsLabel: UILabel = {
        let label: UILabel  = UILabel()
        label.text          = NSLocalizedString("AllCards.TableView.Background", comment: "")
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

        tableView.backgroundView  = noCardsLabel
        tableView.tableFooterView = UIView(frame: .zero)
        
        themeService.rx
            .bind({ $0.primary }, to: view.rx.backgroundColor)
            .bind({ $0.secondary }, to: tableView.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        view.addSubview(tableView)
        view.addSubview(divider)
        view.addSubview(footerView)
        
        tableView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: divider.topAnchor, trailing: view.trailingAnchor)
        divider.anchor(top: tableView.bottomAnchor, leading: view.leadingAnchor, bottom: footerView.topAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: 1))
        footerView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 15, bottom: 0, right: 15), size: .init(width: 0, height: 50))
    }
    
    private func setupNavigationItems() {
        navigationItem.rightBarButtonItems = [addButton, editButton]
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let deleteCardTrigger = rowActionStore
            .filter { $0.0 == RowAction.delete }.flatMap { _, row in
                return UIAlertController
                    .present(in: self, text: UIAlertController.AlertText(
                        title: NSLocalizedString("AllCards.DeleteCard.Title", comment: ""),
                        message: NSLocalizedString("AllCards.DeleteCard.Subtitle", comment: "")),
                             style: .alert,
                             buttons: [.default(NSLocalizedString("Common.Yes", comment: "")),
                                       .cancel(NSLocalizedString("Common.No", comment: ""))],
                             textFields: [])
                    .withLatestFrom(Observable.just(row)) { alertData, row in
                        return (alertData.0, row)
                }
            }
            .filter { $0.0 == 0 }
            .map { $0.1 }
        
        let moveCardTrigger = tableView.rx.itemMoved.withLatestFrom(cardsStore) { ($0, $1) }
        
        let input = CardsViewModel.Input(
            trigger: viewWillAppear,
            selectionTrigger: tableView.rx.itemSelected.asDriver(),
            moveCardTrigger: moveCardTrigger.asDriverOnErrorJustComplete(),
            presentationTrigger: playButton.rx.tap.asDriver(),
            createCardTrigger: addButton.rx.tap.asDriver(),
            deleteCardTrigger: deleteCardTrigger.asDriverOnErrorJustComplete(),
            editOrderTrigger: editButton.rx.tap.asDriver())
        
        let output = viewModel.transform(input: input)
        
        [output.cards
            .do(onNext: { cards in
                self.cardsStore.onNext(cards)
            })
            .map { [CardSection(items: $0)] }
            .drive(tableView.rx.items(dataSource: createDataSource())),
         output.editing.do(onNext: { editing in
            self.tableView.isEditing = editing
         }).drive(),
         output.presentation.drive(),
         output.createCard.drive(),
         output.deleteCard.drive(),
         output.saveCards.drive(),
         output.selectedCard.drive(),
         output.moveCard.drive(),
         output.enablePresentation.do(onNext: { isEnabled in
            self.playButton.isEnabled = isEnabled
         }).drive(),
         output.cardsAvailable.drive(noCardsLabel.rx.isHidden)]
            .forEach({$0.disposed(by: rx.disposeBag)})
    }
    
    private func createDataSource() -> RxTableViewSectionedAnimatedDataSource<CardSection> {
        return RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: { _, tableView, indexPath, card -> CardTableViewCell in
                let cell = tableView.dequeueReusableCell(withIdentifier: CardTableViewCell.reuseID, for: indexPath) as! CardTableViewCell
                cell.shouldIndentWhileEditing = true
                themeService.rx.bind({ $0.primary }, to: cell.rx.backgroundColor).disposed(by: self.rx.disposeBag)
                cell.selectionStyle = .none
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
        let deleteButton = UITableViewRowAction(style: .default, title: NSLocalizedString("Common.Delete", comment: "")) { _, indexPath in
            self.rowActionStore.onNext((RowAction.delete, indexPath.row))
        }
        
        themeService.rx.bind({ $0.danger }, to: deleteButton.rx.backgroundColor).disposed(by: rx.disposeBag)
        
        return [deleteButton]
    }
}
