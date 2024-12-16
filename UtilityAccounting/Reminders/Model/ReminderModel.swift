//
//  ReminderModel.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 14.12.24.
//

import Foundation

struct ReminderModel {
    var id: UUID
    var service: Int?
    var date: Date?
    var time: Date?
    var periodicity: Int?
}

enum Periodicity: String, CaseIterable {
    case oneTime = "One time"
    case monthly = "Monthly"
}
