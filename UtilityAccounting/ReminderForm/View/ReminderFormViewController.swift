//
//  ReminderFormViewController.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 14.12.24.
//

import UIKit
import DropDown
import Combine

class ReminderFormViewController: UIViewController {

    @IBOutlet var titleLabels: [UILabel]!
    @IBOutlet weak var serviceButton: UIButton!
    @IBOutlet weak var periodicityButton: UIButton!
    @IBOutlet weak var dateTextField: BaseTextField!
    @IBOutlet weak var timeTextField: BaseTextField!
    @IBOutlet weak var serviceDropDownImageView: UIImageView!
    @IBOutlet weak var periodicityDropDownImageView: UIImageView!
    @IBOutlet weak var serviceView: UIView!
    @IBOutlet weak var periodicityView: UIView!
    @IBOutlet weak var saveButton: BaseButton!
    private let serviceDropDown = DropDown()
    private let periodicityDropDown = DropDown()
    private let datePicker = UIDatePicker()
    private let timePicker = UIDatePicker()
    private let viewModel = ReminderFormViewModel.shared
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
        self.periodicityDropDown.width = periodicityButton.bounds.width
        self.periodicityDropDown.bottomOffset = CGPoint(x: self.periodicityButton.frame.minX, y: self.periodicityButton.frame.maxY + 2)
    }
    
    func setupUI() {
        setNaviagtionCancelButton()
        titleLabels.forEach({ $0.font = .regular(size: 15) })
        serviceButton.layer.borderWidth = 1
        serviceButton.layer.borderColor = UIColor.fieldBorder.cgColor
        serviceButton.titleLabel?.font = .regular(size: 14)
        periodicityButton.layer.borderWidth = 1
        periodicityButton.layer.borderColor = UIColor.fieldBorder.cgColor
        periodicityButton.titleLabel?.font = .regular(size: 14)
        dateTextField.setupRightViewIcon(.calendar, size: CGSize(width: 40, height: 40))
        timeTextField.setupRightViewIcon(.alarmIcon, size: CGSize(width: 40, height: 40))
        
        datePicker.locale = NSLocale.current
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        dateTextField.inputView = datePicker
        timePicker.locale = NSLocale.current
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.addTarget(self, action: #selector(timePickerValueChanged), for: .valueChanged)
        timeTextField.inputView = timePicker
        
        let servicesData: [String] = ServiceType.allCases.map { $0.rawValue }
        serviceDropDown.backgroundColor = .baseWhite
        serviceDropDown.setupCornerRadius(8)
        serviceDropDown.dataSource = servicesData
        serviceDropDown.anchorView = serviceView
        serviceDropDown.direction = .bottom
        DropDown.appearance().textColor = .baseBlack
        DropDown.appearance().textFont = .regular(size: 15) ?? .boldSystemFont(ofSize: 18)
        DropDown.appearance().selectionBackgroundColor = .clear
        serviceDropDown.addShadow()
        
        serviceDropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.viewModel.reminder.service = index
            self.serviceButton.setTitle(ServiceType.allCases[index].rawValue, for: .normal)
            self.serviceDropDownImageView.isHighlighted = false
        }
        
        serviceDropDown.cancelAction = { [weak self] in
            guard let self = self else { return }
            self.serviceDropDownImageView.isHighlighted = false
        }
        
        let periodData: [String] = Periodicity.allCases.map { $0.rawValue }
        periodicityDropDown.backgroundColor = .baseWhite
        periodicityDropDown.setupCornerRadius(8)
        periodicityDropDown.dataSource = periodData
        periodicityDropDown.anchorView = periodicityView
        periodicityDropDown.direction = .bottom
        periodicityDropDown.addShadow()
        periodicityDropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.viewModel.reminder.periodicity = index
            self.periodicityButton.setTitle(Periodicity.allCases[index].rawValue, for: .normal)
            self.periodicityDropDownImageView.isHighlighted = false
        }
        
        periodicityDropDown.cancelAction = { [weak self] in
            guard let self = self else { return }
            self.periodicityDropDownImageView.isHighlighted = false
        }
    }
    
    func subscribe() {
        viewModel.$reminder
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reminder in
                guard let self = self else { return }
                self.saveButton.isEnabled = (reminder.service != nil && reminder.date != nil && reminder.time != nil && reminder.periodicity != nil)
            }
            .store(in: &cancellables)
    }
    
    @objc func datePickerValueChanged() {
        viewModel.reminder.date = datePicker.date
        dateTextField.text = datePicker.date.toString(format: "dd/MM/yy")
    }
    
    @objc func timePickerValueChanged() {
        viewModel.reminder.time = timePicker.date
        timeTextField.text = timePicker.date.toString(format: "HH:mm")
    }
    
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func chooseService(_ sender: UIButton) {
        serviceDropDown.show()
        serviceDropDownImageView.isHighlighted = !serviceDropDown.isHidden
    }
    
    @IBAction func choosePeriodicity(_ sender: UIButton) {
        periodicityDropDown.show()
        periodicityDropDownImageView.isHighlighted = !periodicityDropDown.isHidden
    }
    
    @IBAction func clickedSave(_ sender: BaseButton) {
        viewModel.save { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            } else {
                NotificationManager.shared.requestNotificationPermission { granted in
                    if granted {
                        NotificationManager.shared.scheduleNotification(for: self.viewModel.reminder)
                    }
                }
                self.completion?()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    deinit {
        viewModel.clear()
    }
}
