//
//  SettingsViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 17/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import RxCocoa
import RxDataSources
import RxSwift

class SettingsViewController: UITableViewController {
    
    var viewModel: SettingsViewModel!
    
    private let disposeBag = DisposeBag()
    private let okButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: nil)
    
    override func loadView() {
        super.loadView()
        
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.reuseID)
        tableView.register(TimeTableViewCell.self, forCellReuseIdentifier: TimeTableViewCell.reuseID)
        
        setupLayout()
        bindViewModel()
    }
    
    private func setupLayout() {
        tableView.backgroundColor = UIColor.UIColorFromHex(hex: "#10171E")
        navigationItem.rightBarButtonItem = okButton
        navigationItem.title = "Settings"
    }
    
    private func bindViewModel() {
        let input = SettingsViewModel.Input(okTrigger: okButton.rx.tap.asDriver(), selection: tableView.rx.modelSelected(SettingsSectionItem.self).asDriver())
        
        let output = viewModel.transform(input: input)
        
        /*let showTimerCells = output.timerEnabled.map { !$0 }
        
        [output.dismiss.drive(),
         output.timerEnabled.drive(enableTimerCell.cellSwitch.rx.isOn),
         showTimerCells.drive(flashRedCell.rx.isHidden),
         showTimerCells.drive(showCountdownCell.rx.isHidden),
         showTimerCells.drive(timePerCardCell.rx.isHidden)]
            .forEach({$0.disposed(by: disposeBag)})*/
        
        [output.dismiss.drive(),
         output.selectedEvent.drive(),
         Driver.of(output.items)
            .drive(tableView.rx.items(dataSource: createDataSource()))]
            .forEach({$0.disposed(by: disposeBag)})
    }
    
    private func createDataSource() -> RxTableViewSectionedReloadDataSource<SettingsSection> {
        return RxTableViewSectionedReloadDataSource<SettingsSection>(configureCell: { dataSource, tableView, indexPath, item in
            switch item {
            case .enableTimerItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.reuseID, for: indexPath) as! SwitchTableViewCell
                cell.bind(to: viewModel)
                return cell
            case .timePerCardItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: TimeTableViewCell.reuseID, for: indexPath) as! TimeTableViewCell
                cell.bind(to: viewModel)
                return cell
            }
        }, titleForHeaderInSection: { dataSource, index in
            let section = dataSource[index]
            return section.title
        })
    }
}
