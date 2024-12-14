//
//  PaymentFormViewModel.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 13.12.24.
//

import Foundation

class PaymentFormViewModel {
    static let shared = PaymentFormViewModel()
    @Published var payment = PaymentModel(id: UUID())
    private init() {}
    
    func save(completion: @escaping (Error?) -> Void) {
        if payment.status == 0 {
            payment.paidDate = Date().stripTime()
        }
        CoreDataManager.shared.savePayment(paymentModel: payment, completion: completion)
    }
    
    func clear() {
        payment = PaymentModel(id: UUID())
    }
}
