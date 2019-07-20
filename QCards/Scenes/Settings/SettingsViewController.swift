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
    
    var shareCell1 = SwitchTableViewCell()
    var shareCell2 = SwitchTableViewCell()
    
    override func loadView() {
        super.loadView()
        
        setupTableView()
        setupNavigationBar()
        bindViewModel()
    }
    
    private func setupTableView() {
        self.shareCell1.titleLabel.text = "Enable timer"
        self.shareCell2.titleLabel.text = "Share with Friends"
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.UIColorFromHex(hex: "#0E3D5B")
        navigationController?.navigationBar.barStyle = .black
        navigationController?.view.tintColor = .white
        navigationItem.rightBarButtonItem = okButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.title = "Settings"
    }
    
    private func bindViewModel() {
        let input = SettingsViewModel.Input(okTrigger: okButton.rx.tap.asDriver())
        
        let output = viewModel.transform(input: input)
        
        [output.dismiss.drive()]
            .forEach({$0.disposed(by: disposeBag)})
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: return self.shareCell1
        case 1: return self.shareCell2
        default: fatalError("Unknown row in section 1")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        
        if indexPath.row == 0 {
            if self.shareCell1.accessoryType == UITableViewCell.AccessoryType.none {
                self.shareCell1.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                self.shareCell1.accessoryType = UITableViewCell.AccessoryType.none
            }
        } else {
            if indexPath.row == 1 {
                if self.shareCell2.accessoryType == UITableViewCell.AccessoryType.none {
                    self.shareCell2.accessoryType = UITableViewCell.AccessoryType.checkmark
                } else {
                    self.shareCell2.accessoryType = UITableViewCell.AccessoryType.none
                }
            }
        }
        
    }
}
