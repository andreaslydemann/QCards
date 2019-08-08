//
//  SwitchTableViewCell.swift
//  QCards
//
//  Created by Andreas Lüdemann on 20/07/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RxSwift
import UIKit

class SwitchTableViewCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        themeService.rx.bind({ $0.activeTint }, to: label.rx.textColor).disposed(by: rx.disposeBag)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var switchView: UISwitch = {
        let switchView = UISwitch()
        themeService.rx.bind({ $0.action }, to: switchView.rx.onTintColor).disposed(by: rx.disposeBag)
        return switchView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    private func setupLayout() {
        self.selectionStyle = .none
        
        themeService.rx.bind({ $0.primary }, to: self.rx.backgroundColor).disposed(by: rx.disposeBag)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, switchView])
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        stackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,
                         padding: .init(top: 10, left: 20, bottom: 6, right: 15), size: .init(width: 0, height: 35))
    }
    
    func bind(to viewModel: SwitchCellViewModel) {
        titleLabel.text = viewModel.title
        
        let trigger = switchView.rx.isOn.changed.asDriver()
        
        viewModel
            .transform(input: SwitchCellViewModel.Input(trigger: trigger))
            .isEnabled.drive(switchView.rx.isOn)
            .disposed(by: rx.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
