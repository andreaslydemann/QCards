//
//  TimePerCardViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 04/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

enum TimePerCard: Int {
    case unlimited, thirtysec, onemin, twomin
    
    static let allValues = [unlimited, thirtysec, onemin, twomin]
    
    static func displayName(option: Int) -> String {
        switch TimePerCard(rawValue: option)! {
        case .unlimited: return "Unlimited"
        case .thirtysec: return "30 seconds"
        case .onemin: return "One minute"
        case .twomin: return "Two minutes"
        }
    }
}

class TimePerCardViewController: UITableViewController {
    
    var viewModel: TimePerCardViewModel!
    
    private let disposeBag = DisposeBag()
    private let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupNavigationItems()
        bindViewModel()
    }
    
    private func setupLayout() {
        tableView.backgroundColor = UIColor.UIColorFromHex(hex: "#10171E")
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(TimePerCardTableViewCell.self, forCellReuseIdentifier: TimePerCardTableViewCell.reuseID)
    }
    
    private func setupNavigationItems() {
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.title = "Time per card"
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = TimePerCardViewModel.Input(trigger: viewWillAppear,
                                               saveTrigger: saveButton.rx.tap.asDriver(),
                                               selection: tableView.rx.modelSelected(TimePerCardCellViewModel.self).asDriver())
        
        let output = viewModel.transform(input: input)

        output.items.map { [TimeSection(items: $0)] }
            .drive(tableView!.rx.items(dataSource: createDataSource())).disposed(by: disposeBag)

        [output.save.drive(), output.selectedOption.drive()]
            .forEach({$0.disposed(by: disposeBag)})
    }
    
    private func createDataSource() -> RxTableViewSectionedReloadDataSource<TimeSection> {
        return RxTableViewSectionedReloadDataSource(
            configureCell: { _, tableView, indexPath, viewModel -> TimePerCardTableViewCell in
                let cell = tableView.dequeueReusableCell(withIdentifier: TimePerCardTableViewCell.reuseID, for: indexPath) as! TimePerCardTableViewCell
                cell.bind(viewModel)
                return cell
        },
            canEditRowAtIndexPath: { _, _ in true }
        )
    }
}
