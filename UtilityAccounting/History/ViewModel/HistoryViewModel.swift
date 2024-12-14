//
//  HistoryTableView.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 14.12.24.
//

import Foundation

class HistoryViewModel {
    static let shared = HistoryViewModel()
    var data: [PaymentModel] = []
    @Published var payments: [PaymentModel] = []
    var selectedFilter: Int = -1
    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchPayments { [weak self] payments, _ in
            guard let self = self else { return }
            self.data = payments
            self.filter()
        }
    }
    
    func chooseFilter(by index: Int) {
        selectedFilter = index
        filter()
    }
    
    private func filter() {
        if selectedFilter == -1 {
            self.payments = data
        } else {
            self.payments = data.filter({ $0.status == selectedFilter })
        }
    }
    
    func clear() {
        payments = []
        data = []
        selectedFilter = -1
    }
}
