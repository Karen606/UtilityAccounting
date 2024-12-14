//
//  PaymentTableViewCell.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 13.12.24.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = .regular(size: 18)
        dateLabel.font = .regular(size: 14)
        priceLabel.font = .medium(size: 24)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(payment: PaymentModel) {
        if let service = payment.service {
            self.nameLabel.text = ServiceType.allCases[service].rawValue
        }
        dateLabel.text = payment.date?.toString()
        priceLabel.text = "\(payment.amount?.formattedToString() ?? "0")$"
        switch (payment.service ?? 0) {
        case 0:
            iconImageView.image = .waterIcon
        case 1:
            iconImageView.image = .electricityIcon
        case 2:
            iconImageView.image = .gasIcon
        case 3:
            iconImageView.image = .electricityIcon
        default:
            break
        }
    }
}
