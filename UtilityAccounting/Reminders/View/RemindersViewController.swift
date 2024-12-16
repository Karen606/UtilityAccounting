//
//  RemindersViewController.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 14.12.24.
//

import UIKit
import Combine

class RemindersViewController: UIViewController {

    @IBOutlet weak var remindersTableView: UITableView!
    @IBOutlet weak var tableViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var setReminderButton: BaseButton!
    private let viewModel = RemindersViewModel.shared
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        viewModel.fetchData()
    }
    
    func setupUI() {
        setNaviagtionBackButton()
        setNavigationTitle(title: "Reminders")
        setReminderButton.titleLabel?.font = .medium(size: 18)
        remindersTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        remindersTableView.layer.borderWidth = 1
        remindersTableView.layer.borderColor = UIColor.fieldBorder.cgColor
        remindersTableView.register(UINib(nibName: "ReminderTableViewCell", bundle: nil), forCellReuseIdentifier: "ReminderTableViewCell")
        remindersTableView.dataSource = self
        remindersTableView.delegate = self
    }
    
    func subscribe() {
        viewModel.$reminders
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.remindersTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func updateTableViewHeight(newSize: CGSize) {
        tableViewHeightConst.constant = newSize.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let newSize = change?[.newKey] as? CGSize {
                updateTableViewHeight(newSize: newSize)
            }
        }
    }
    
    @IBAction func clickedSetReminder(_ sender: BaseButton) {
        let reminderForm = ReminderFormViewController(nibName: "ReminderFormViewController", bundle: nil)
        reminderForm.completion = { [weak self] in
            if let self = self {
                self.viewModel.fetchData()
            }
        }
        self.navigationController?.pushViewController(reminderForm, animated: true)
    }
}

extension RemindersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderTableViewCell", for: indexPath) as! ReminderTableViewCell
        cell.configure(reminder: viewModel.reminders[indexPath.row])
        return cell
    }
}
