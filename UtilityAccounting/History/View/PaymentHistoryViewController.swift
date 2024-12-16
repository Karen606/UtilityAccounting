//
//  PaymentHistoryViewController.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 14.12.24.
//

import UIKit
import DropDown
import Combine

class PaymentHistoryViewController: UIViewController {

    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var dropDownImageView: UIImageView!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var tableViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var dropDownView: UIView!
    private let viewModel = HistoryViewModel.shared
    private let dropDown = DropDown()
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        viewModel.fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        self.dropDown.width = 90
        self.dropDown.bottomOffset = CGPoint(x: self.dropDownView.frame.minX, y: self.dropDownView.frame.maxY + 2)
    }
    
    func setupUI() {
        historyTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        setNaviagtionBackButton()
        setNavigationTitle(title: "Payment history")
        historyTableView.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryTableViewCell")
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.layer.borderWidth = 1
        historyTableView.layer.borderColor = UIColor.fieldBorder.cgColor
        dropDownView.layer.borderWidth = 1
        dropDownView.layer.borderColor = UIColor.baseBlack.cgColor
        
        var data: [String] = PaymentStatus.allCases.map { $0.rawValue }
        data.insert("All", at: 0)
        dropDown.backgroundColor = .baseWhite
        dropDown.setupCornerRadius(8)
        dropDown.dataSource = data
        dropDown.anchorView = view
        dropDown.direction = .bottom
        DropDown.appearance().textColor = .baseBlack
        DropDown.appearance().textFont = .regular(size: 15) ?? .boldSystemFont(ofSize: 18)
        DropDown.appearance().selectionBackgroundColor = .clear
        dropDown.addShadow()
        
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.viewModel.chooseFilter(by: index - 1)
            self.filterLabel.text = item
            self.dropDownImageView.isHighlighted = false
        }
        
        dropDown.cancelAction = { [weak self] in
            guard let self = self else { return }
            self.dropDownImageView.isHighlighted = false
        }
    }
    
    func subscribe() {
        viewModel.$payments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payments in
                guard let self = self else { return }
                self.historyTableView.reloadData()
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
    
    @IBAction func clickedFilter(_ sender: UIButton) {
        dropDown.show()
        dropDownImageView.isHighlighted = !dropDown.isHidden
    }
    
    deinit {
        viewModel.clear()
    }
}

extension PaymentHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.payments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
        cell.configure(payment: viewModel.payments[indexPath.row])
        return cell
    }
}
