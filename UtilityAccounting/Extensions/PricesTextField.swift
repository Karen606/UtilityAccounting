//
//  PricesTextField.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 13.12.24.
//

import UIKit

@objc protocol PriceTextFielddDelegate: AnyObject {
    @objc optional func textFieldDidChangeSelection(_ textField: UITextField)
    @objc optional func textFieldDidBeginEditing(_ textField: UITextField)
    @objc optional func textFieldDidEndEditing(_ textField: UITextField)
}

class PriceTextField: BaseTextField, UITextFieldDelegate {
    weak var baseDelegate: PriceTextFielddDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.delegate = self
        self.keyboardType = .decimalPad
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let numberSet = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        if !numberSet.isSuperset(of: characterSet) && string != "." {
            return false
        }
        
        let decimalCount = updatedText.components(separatedBy: ".").count - 1
        if decimalCount > 1 {
            return false
        }
        
        if let dotIndex = updatedText.firstIndex(of: ".") {
            let decimalPart = updatedText[updatedText.index(after: dotIndex)...]
            if decimalPart.count > 2 {
                return false
            }
        }
        
        if let dotIndex = updatedText.firstIndex(of: ".") {
            let integerPart = updatedText[..<dotIndex]
            if integerPart.count > 9 {
                return false
            }
        } else {
            if updatedText.count > 9 {
                return false
            }
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        baseDelegate?.textFieldDidChangeSelection?(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        baseDelegate?.textFieldDidEndEditing?(textField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        baseDelegate?.textFieldDidBeginEditing?(textField)
    }
}

