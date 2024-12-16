//
//  ReminderFormViewModel.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 14.12.24.
//

import Foundation

class ReminderFormViewModel {
    static let shared = ReminderFormViewModel()
    @Published var reminder = ReminderModel(id: UUID())
    private init() {}
    
    func save(completion: @escaping (Error?) -> Void) {
        CoreDataManager.shared.saveReminder(reminderModel: reminder, completion: completion)
    }
    
    func clear() {
        reminder = ReminderModel(id: UUID())
    }
}
