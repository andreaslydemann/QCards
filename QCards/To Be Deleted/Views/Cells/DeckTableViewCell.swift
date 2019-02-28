//
//  DeckTableViewCell.swift
//  QCards
//
//  Created by Andreas Lüdemann on 26/11/2018.
//  Copyright © 2018 Andreas Lüdemann. All rights reserved.
//

import UIKit

class DeckTableViewCell: UITableViewCell {

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(nameLabel)
        nameLabel.centerInSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(withItem item: DeckEntity) {
        nameLabel.text = item.name
    }
}
