//
//  ReminderTableViewCell.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 14.12.24.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {

    @IBOutlet weak var reminderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        reminderLabel.font = .regular(size: 19)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(reminder: ReminderModel) {
        reminderLabel.text = "\(ServiceType.allCases[reminder.service ?? 0].rawValue) - \(reminder.date?.toString() ?? "") at \(reminder.time?.toString(format: "HH:mm") ?? "")"
    }
    
}
