//
//  SettingsViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 17/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Domain
import RxCocoa
import RxSwift
import UIKit

class SettingsViewController: UITableViewController {
    
    var viewModel: SettingsViewModel!
    
    private let disposeBag = DisposeBag()
    private let okButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: nil)
    
    var enableTimerCell = SwitchTableViewCell()
    var flashRedCell = SwitchTableViewCell()
    var showCountdownCell = SwitchTableViewCell()
    var timePerCardCell = TimeTableViewCell()
    var darkModeCell = SwitchTableViewCell()
    
    override func loadView() {
        super.loadView()
        
        setupLayout()
        setupNavigationItems()
        bindViewModel()
    }
    
    private func setupLayout() {
        tableView.backgroundColor = UIColor.UIColorFromHex(hex: "#10171E")
        
        enableTimerCell.titleLabel.text = "Enable timer"
        enableTimerCell.selectionStyle = .none
        enableTimerCell.backgroundColor = UIColor.UIColorFromHex(hex: "#15202B")
        
        flashRedCell.titleLabel.text = "Flash red at 10 secs left on card"
        flashRedCell.selectionStyle = .none
        flashRedCell.backgroundColor = UIColor.UIColorFromHex(hex: "#15202B")
        
        showCountdownCell.titleLabel.text = "Show countdown on each card"
        showCountdownCell.selectionStyle = .none
        showCountdownCell.backgroundColor = UIColor.UIColorFromHex(hex: "#15202B")
        
        timePerCardCell.titleLabel.text = "Time per card"
        timePerCardCell.titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        timePerCardCell.timeLabel.text = "1 minute"
        timePerCardCell.accessoryType = .disclosureIndicator
        timePerCardCell.backgroundColor = UIColor.UIColorFromHex(hex: "#15202B")
        timePerCardCell.selectionStyle = .none
        
        darkModeCell.titleLabel.text = "Enable dark mode"
        darkModeCell.selectionStyle = .none
        darkModeCell.backgroundColor = UIColor.UIColorFromHex(hex: "#15202B")
        
    }
    
    private func setupNavigationItems() {
        navigationItem.rightBarButtonItem = okButton
        navigationItem.title = "Settings"
    }
    
    private func bindViewModel() {
        let input = SettingsViewModel.Input(okTrigger: okButton.rx.tap.asDriver(), enableTimerTrigger: enableTimerCell.cellSwitch.rx.value.share(replay: 1, scope: .forever))
        
        let output = viewModel.transform(input: input)
        
        [output.dismiss.drive(),
         output.showTimerSettings.bind(to: flashRedCell.rx.isHidden),
         output.showTimerSettings.bind(to: showCountdownCell.rx.isHidden),
         output.showTimerSettings.bind(to: timePerCardCell.rx.isHidden)]
            .forEach({$0.disposed(by: disposeBag)})
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 4
        default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return darkModeCell
        case 1:
            switch indexPath.row {
            case 0: return enableTimerCell
            case 1: return timePerCardCell
            case 2: return flashRedCell
            case 3: return showCountdownCell
            default: fatalError("Unknown row")
            }
        default: fatalError("Unknown row")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
}
