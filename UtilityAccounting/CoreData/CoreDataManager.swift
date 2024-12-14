//
//  CoreDataManager.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 13.12.24.
//


import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UtilityAccounting")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func savePayment(paymentModel: PaymentModel, completion: @escaping (Error?) -> Void) {
        let id = paymentModel.id
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                let payment: Payment
                
                if let existingPayment = results.first {
                    payment = existingPayment
                } else {
                    payment = Payment(context: backgroundContext)
                    payment.id = id
                }
                
                payment.date = paymentModel.date
                payment.service = Int32(paymentModel.service ?? 0)
                payment.status = Int32(paymentModel.status ?? 0)
                payment.amount = paymentModel.amount ?? 0
                payment.paidDate = paymentModel.paidDate
                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func fetchPayments(completion: @escaping ([PaymentModel], Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                var paymentsModel: [PaymentModel] = []
                for result in results {
                    let paymentModel = PaymentModel(id: result.id ?? UUID(), service: Int(result.service), amount: result.amount, date: result.date, status: Int(result.status), paidDate: result.paidDate)
                    paymentsModel.append(paymentModel)
                }
                DispatchQueue.main.async {
                    completion(paymentsModel, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
    }
    
    func payAllPayments(completion: @escaping (Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "status != %d", 0)
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                for payment in results {
                    payment.status = Int32(0)
                    payment.paidDate = Date().stripTime()
                }
                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
}