//
//  TimePerCardTableViewCell.swift
//  QCards
//
//  Created by Andreas Lüdemann on 05/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import RxSwift
import UIKit

final class TimePerCardTableViewCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        themeService.rx.bind({ $0.activeTint }, to: label.rx.textColor).disposed(by: rx.disposeBag)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(titleLabel)
        
        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,
                          padding: .init(top: 15, left: 20, bottom: 12, right: 0), size: .init(width: 0, height: 0))
        setupLayout()
    }
    
    func setupLayout() {
        selectionStyle = .none
        
        themeService.rx
            .bind({ $0.primary }, to: rx.backgroundColor)
            .bind({ $0.action }, to: rx.tintColor)
            .disposed(by: rx.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func bind(_ viewModel: TimePerCardCellViewModel) {
        self.titleLabel.text = viewModel.displayName
        self.accessoryType = viewModel.isSelected ? .checkmark : .none
    }
}
