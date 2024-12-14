//
//  ExpensesModel.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 13.12.24.
//

import Foundation

struct ExpenseModel {
    var water: Double?
    var electricity: Double?
    var internet: Double?
    var gas: Double?
    var totalSum: Double?
    var paymentsCount: Int = 0
}

enum Period: String, CaseIterable {
    case month = "This Month"
    case year = "This Year"
}
