//
//  FilterButton.swift
//  EcoClean
//
//  Created by Karen Khachatryan on 03.12.24.
//

import UIKit

class FilterButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? .baseGreen : .white
        }
    }
    
    func commonInit() {
        self.titleLabel?.font = .regular(size: 15)
        self.setTitleColor(.black, for: .normal)
        self.backgroundColor = .white
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}
