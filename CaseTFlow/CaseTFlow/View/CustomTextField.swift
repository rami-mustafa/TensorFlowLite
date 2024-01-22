
import UIKit

class CustomTextField: UITextField {

    enum customTextFieldType {
        case username
        case email
        case password
        case description
    }

    private let authFieldType: customTextFieldType
    
    
    init(fieldType: customTextFieldType){
        self.authFieldType = fieldType
        super.init(frame: .zero)
        
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 10
        
        self.returnKeyType = .done
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        
//        self.leftView = .always
//        self.leftViewMode = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.size.height))
     
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.size.height))
        self.leftViewMode = .always
        
        switch fieldType {
        case .username:
            self.placeholder = "Username"
        case .email:
            self.placeholder = "Email Address"
            self.keyboardType = .emailAddress
            self.textContentType = .emailAddress
        case .password:
            self.placeholder = "Password"
            self.textContentType = .oneTimeCode
            self.isSecureTextEntry = true

        case .description:
            self.placeholder = "Description"
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
