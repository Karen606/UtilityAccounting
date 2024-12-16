//
//  RemindersViewModel.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 14.12.24.
//

import Foundation

class RemindersViewModel {
    static let shared = RemindersViewModel()
    @Published var reminders: [ReminderModel] = []
    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchReminders { [weak self] reminders, _ in
            guard let self = self else { return }
            self.reminders = reminders
        }
    }
    
    func clear() {
        reminders = []
    }
}
