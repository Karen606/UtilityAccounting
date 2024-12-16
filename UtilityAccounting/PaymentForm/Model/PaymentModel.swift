//
//  PaymentModel.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 13.12.24.
//

import Foundation

struct PaymentModel {
    var id: UUID
    var service: Int?
    var amount: Double?
    var date: Date?
    var status: Int?
}

enum ServiceType: String, CaseIterable {
    case water = "Water"
    case electricity = "Electricity"
    case gas = "Gas"
    case internet = "Internet"
}

enum PaymentStatus: String, CaseIterable {
    case paid = "Paid"
    case notPaid = "Not paid"
}
