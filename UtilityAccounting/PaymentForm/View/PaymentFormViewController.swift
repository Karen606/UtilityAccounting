//
//  PaymentFormViewController.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 13.12.24.
//

import UIKit
import DropDown
import Combine

class PaymentFormViewController: UIViewController {

    @IBOutlet var titleLabels: [UILabel]!
    @IBOutlet weak var serviceButton: UIButton!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var amountTextField: PriceTextField!
    @IBOutlet weak var dateTextField: BaseTextField!
    @IBOutlet weak var saveButton: BaseButton!
    @IBOutlet weak var serviceDropDownImageView: UIImageView!
    @IBOutlet weak var statusDropDownImageView: UIImageView!
    @IBOutlet weak var serviceView: UIView!
    @IBOutlet weak var statusView: UIView!
    private let serviceDropDown = DropDown()
    private let statusDropDown = DropDown()
    private let datePicker = UIDatePicker()
    private let viewModel = PaymentFormViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    var completion: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
    }
    
    override func viewDidLayoutSubviews() {
        self.serviceDropDown.width = serviceButton.bounds.width
        self.serviceDropDown.bottomOffset = CGPoint(x: self.serviceButton.frame.minX, y: self.serviceButton.frame.maxY + 2)
        self.statusDropDown.width = statusButton.bounds.width
        self.statusDropDown.bottomOffset = CGPoint(x: self.statusButton.frame.minX, y: self.statusButton.frame.maxY + 2)
    }
    
    func setupUI() {
        setNaviagtionCancelButton()
        titleLabels.forEach({ $0.font = .regular(size: 15) })
        datePicker.locale = NSLocale.current
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        dateTextField.inputView = datePicker
        amountTextField.baseDelegate = self
        saveButton.titleLabel?.font = .medium(size: 18)
        
        serviceButton.layer.borderWidth = 1
        serviceButton.layer.borderColor = UIColor.border.cgColor
        statusButton.layer.borderWidth = 1
        statusButton.layer.borderColor = UIColor.border.cgColor
        
        let servicesData: [String] = ServiceType.allCases.map { $0.rawValue }
        serviceDropDown.backgroundColor = .baseWhite
        serviceDropDown.setupCornerRadius(8)
        serviceDropDown.dataSource = servicesData
        serviceDropDown.anchorView = serviceView
        serviceDropDown.direction = .bottom
        DropDown.appearance().textColor = .black
        DropDown.appearance().textFont = .regular(size: 15) ?? .boldSystemFont(ofSize: 18)
        DropDown.appearance().selectionBackgroundColor = .clear
        serviceDropDown.addShadow()
        
        serviceDropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.viewModel.payment.service = index
            self.serviceButton.setTitle(ServiceType.allCases[index].rawValue, for: .normal)
            self.serviceDropDownImageView.isHighlighted = false
        }
        
        serviceDropDown.cancelAction = { [weak self] in
            guard let self = self else { return }
            self.serviceDropDownImageView.isHighlighted = false
        }
        
        let statusesData: [String] = PaymentStatus.allCases.map { $0.rawValue }
        statusDropDown.backgroundColor = .baseWhite
        statusDropDown.setupCornerRadius(8)
        statusDropDown.dataSource = statusesData
        statusDropDown.anchorView = statusView
        statusDropDown.direction = .bottom
        statusDropDown.addShadow()
        statusDropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.viewModel.payment.status = index
            self.statusButton.setTitle(PaymentStatus.allCases[index].rawValue, for: .normal)
            self.statusDropDownImageView.isHighlighted = false
        }
        
        statusDropDown.cancelAction = { [weak self] in
            guard let self = self else { return }
            self.statusDropDownImageView.isHighlighted = false
        }
    }
    
    func subscribe() {
        viewModel.$payment
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payment in
                guard let self = self else { return }
                self.saveButton.isEnabled = (payment.amount != nil && payment.date != nil && payment.service != nil && payment.status != nil)
            }
            .store(in: &cancellables)
    }
    
    @objc func datePickerValueChanged() {
        viewModel.payment.date = datePicker.date
        dateTextField.text = datePicker.date.toString(format: "dd/MM/yy HH:mm")
    }
    
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func chooseService(_ sender: UIButton) {
        serviceDropDown.show()
        serviceDropDownImageView.isHighlighted = !serviceDropDown.isHidden
    }
    
    @IBAction func chooseStatus(_ sender: UIButton) {
        statusDropDown.show()
        statusDropDownImageView.isHighlighted = !statusDropDown.isHidden
    }
    
    @IBAction func clickedSave(_ sender: BaseButton) {
        viewModel.save { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            } else {
                self.completion?()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    deinit {
        viewModel.clear()
    }
}

extension PaymentFormViewController: PriceTextFielddDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == amountTextField {
            let textWithoutSpaces = textField.text?.components(separatedBy: .whitespacesAndNewlines).joined()
            viewModel.payment.amount = Double(textWithoutSpaces ?? "")
        }
    }
}
