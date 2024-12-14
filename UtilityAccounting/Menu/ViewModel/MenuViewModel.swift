//
//  MenuViewModel.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 13.12.24.
//

import Foundation

class MenuViewModel {
    static let shared = MenuViewModel()
    private var data: [PaymentModel] = []
    @Published var payments: [PaymentModel] = []
    @Published var expense = ExpenseModel()
    private var selectedPeriod: Int = 0
    
    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchPayments { [weak self] payments, _ in
            guard let self = self else { return }
            self.data = payments
            self.payments = data.filter({ $0.status == 1 })
            self.filterByPeriod()
        }
    }
    
    func payAllPayment(completion: @escaping (Error?) -> Void) {
        CoreDataManager.shared.payAllPayments(completion: completion)
    }
    
    func choosePeriod(period: Int) {
        self.selectedPeriod = period
        filterByPeriod()
    }
    
    private func filterByPeriod() {
        let calendar = Calendar.current
            let now = Date()
            let startOfPeriod: Date?

        switch selectedPeriod {
            case 0:
                startOfPeriod = calendar.date(from: calendar.dateComponents([.year, .month], from: now))
            case 1:
                startOfPeriod = calendar.date(from: calendar.dateComponents([.year], from: now))
            default:
                startOfPeriod = nil
            }
        
        guard let start = startOfPeriod else { return }
        let paidPayments = data.filter({ $0.status == 0 })

        let filteredPayments = paidPayments.filter { payment in
            guard let paidDate = payment.paidDate else { return false }
            return calendar.compare(paidDate, to: start, toGranularity: selectedPeriod == 0 ? .month : .year) != .orderedAscending
        }
        let water = filteredPayments.filter { $0.service == 0 }.reduce(0.0) { $0 + ($1.amount ?? 0.0) }
        let electricity = filteredPayments.filter { $0.service == 1 }.reduce(0.0) { $0 + ($1.amount ?? 0.0) }
        let gas = filteredPayments.filter { $0.service == 2 }.reduce(0.0) { $0 + ($1.amount ?? 0.0) }
        let internet = filteredPayments.filter { $0.service == 3 }.reduce(0.0) { $0 + ($1.amount ?? 0.0) }
        expense = ExpenseModel(water: water, electricity: electricity, internet: internet, gas: gas, totalSum: water + electricity + internet + gas, paymentsCount: filteredPayments.count)
    }
    
    func clear() {
        payments = []
    }
}
