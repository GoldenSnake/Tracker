
import UIKit

final class TextCell: UITableViewCell {
    private var onTextChange: ((String) -> Void)?
    
    private var textField = UITextField()
    private let maxCharacterLimit = 38
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupTextField()
        
        self.selectionStyle = .none
        self.backgroundColor = .ypBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTextField(){
        contentView.addSubview(textField)
        
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.clearButtonMode = .whileEditing
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.returnKeyType = .go
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        textField.delegate = self
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(text: String, placeholder: String, onTextChange: @escaping (String) -> Void) {
        textField.text = text
        textField.placeholder = placeholder
        self.onTextChange = onTextChange
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        onTextChange?(textField.text ?? "")
    }
}

extension TextCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Получаем текущий текст
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // Проверка на ограничение символов
        return updatedText.count <= maxCharacterLimit
    }
}
