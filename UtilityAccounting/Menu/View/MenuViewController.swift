//
//  MenuViewController.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 13.12.24.
//

import UIKit
import PieCharts
import Combine
import DropDown

class MenuViewController: UIViewController {

    @IBOutlet weak var paidTitleLabel: UILabel!
    @IBOutlet weak var paidSumLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var servicesTableView: UITableView!
    @IBOutlet weak var statisticsTitleLabel: UILabel!
    @IBOutlet weak var totalExpenseLabel: UILabel!
    @IBOutlet weak var totalPaymentsLabel: UILabel!
    @IBOutlet weak var periodButton: UIButton!
    @IBOutlet weak var chartView: PieChart!
    @IBOutlet weak var addButton: BaseButton!
    @IBOutlet weak var tableViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var paymentsContentView: UIView!
    @IBOutlet weak var expensesContentView: UIView!
    @IBOutlet weak var waterView: UIView!
    @IBOutlet weak var electricityView: UIView!
    @IBOutlet weak var gasView: UIView!
    @IBOutlet weak var internetView: UIView!
    @IBOutlet var servicesLabels: [UILabel]!
    private let viewModel = MenuViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    private let periodDropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        servicesTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        setupUI()
        subscribe()
        viewModel.fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        self.periodDropDown.width = 100
        self.periodDropDown.bottomOffset = CGPoint(x: self.periodButton.frame.minX, y: self.periodButton.frame.maxY + 2)
    }
    
    func setupUI() {
        setNaviagtionRightButton()
        paidTitleLabel.font = .regular(size: 16)
        paidSumLabel.font = .medium(size: 40)
        payButton.titleLabel?.font = .semibold(size: 24)
        statisticsTitleLabel.font = .medium(size: 16)
        totalExpenseLabel.font = .regular(size: 32)
        totalPaymentsLabel.font = .regular(size: 16)
        periodButton.titleLabel?.font = .medium(size: 12)
        addButton.titleLabel?.font = .medium(size: 18)
        servicesLabels.forEach({ $0.font = .medium(size: 12)})
        paymentsContentView.layer.borderWidth = 1
        paymentsContentView.layer.borderColor = UIColor.border.cgColor
        expensesContentView.layer.borderWidth = 1
        expensesContentView.layer.borderColor = UIColor.border.cgColor
        servicesTableView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentTableViewCell")
        servicesTableView.delegate = self
        servicesTableView.dataSource = self
        
        let servicesData: [String] = Period.allCases.map { $0.rawValue }
        periodDropDown.backgroundColor = .white
        periodDropDown.setupCornerRadius(8)
        periodDropDown.dataSource = servicesData
        periodDropDown.anchorView = expensesContentView
        periodDropDown.direction = .bottom
        DropDown.appearance().textColor = .black
        DropDown.appearance().textFont = .regular(size: 12) ?? .boldSystemFont(ofSize: 18)
        DropDown.appearance().selectionBackgroundColor = .clear
        periodDropDown.addShadow()
        
        periodDropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.periodButton.setTitle(Period.allCases[index].rawValue, for: .normal)
            self.viewModel.choosePeriod(period: index)
        }
    }
    
    func subscribe() {
        viewModel.$payments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payments in
                guard let self = self else { return }
                let totalPayments = payments.reduce(0.0) { (result, payment) -> Double in
                    return result + (payment.amount ?? 0.0)
                }
                self.paidSumLabel.text = "\(totalPayments.formattedToString())$"
                self.payButton.isEnabled = totalPayments > 0
                self.servicesTableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$expense
            .receive(on: DispatchQueue.main)
            .sink { [weak self] expense in
                guard let self = self else { return }
                self.chartView.clear()
                self.totalPaymentsLabel.text = "\(expense.paymentsCount) payments"
                self.totalExpenseLabel.text = "\(expense.totalSum?.formattedToString() ?? "")$"
                self.waterView.isHidden = expense.water == 0
                self.gasView.isHidden = expense.gas == 0
                self.electricityView.isHidden = expense.electricity == 0
                self.internetView.isHidden = expense.internet == 0
                if expense.totalSum == 0 {
                    self.chartView.models = [PieSliceModel(value: 1.0, color: .baseGreen)]
                } else {
                    self.chartView.models = [PieSliceModel(value: expense.electricity ?? 0, color: .electricity), PieSliceModel(value: Double(expense.gas ?? 0), color: .gas), PieSliceModel(value: Double(expense.internet ?? 0), color: .internet), PieSliceModel(value: Double(expense.water ?? 0), color: .water)]
                }
                self.servicesLabels[0].text = "Water - \(expense.water?.formattedToString() ?? "")$"
                self.servicesLabels[1].text = "Electricity - \(expense.electricity?.formattedToString() ?? "")$"
                self.servicesLabels[2].text = "Gas - \(expense.gas?.formattedToString() ?? "")$"
                self.servicesLabels[3].text = "Internet - \(expense.internet?.formattedToString() ?? "")$"
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
    
    @IBAction func choosePeriod(_ sender: UIButton) {
        periodDropDown.show()
    }
    
    @IBAction func clickedPay(_ sender: BaseButton) {
        viewModel.payAllPayment { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            } else {
                self.viewModel.fetchData()
            }
        }
    }
    
    @IBAction func clickedAddPayment(_ sender: BaseButton) {
        let paymentForm = PaymentFormViewController(nibName: "PaymentFormViewController", bundle: nil)
        paymentForm.completion = { [weak self] in
            if let self = self {
                self.viewModel.fetchData()
            }
        }
        self.navigationController?.pushViewController(paymentForm, animated: true)
    }
    
    @IBAction func clickedHistoryPayment(_ sender: BaseButton) {
        self.pushViewController(PaymentHistoryViewController.self)
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.payments.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentTableViewCell", for: indexPath) as! PaymentTableViewCell
        cell.configure(payment: viewModel.payments[indexPath.section])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        10
    }
}
