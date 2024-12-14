//
//  HistoryTableViewCell.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 14.12.24.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var paymentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        paymentLabel.font = .regular(size: 18)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(payment: PaymentModel) {
        paymentLabel.text = "\(payment.date?.toString() ?? "") - \(ServiceType.allCases[payment.service ?? 0].rawValue): \(payment.amount?.formattedToString() ?? "")$ - \(PaymentStatus.allCases[payment.status ?? 0].rawValue)"
    }
    
}
