

import UIKit
import SnapKit

class LoginController: UIViewController {
    
    
    
    
    // MARK: - UI Components
    private let headerView            = AuthHeaderView(title: "Sign In", subTitle: "welcome to my page")
    private let emailField            = CustomTextField(fieldType: .email)
    private let passwordField         = CustomTextField(fieldType: .password)
    private let signInButton          = CustomButton(title: "Sign In",                    hasBackground: true , fontSize: .big)
    private let newUserButton         = CustomButton(title: "New User? Create Account. ", hasBackground: false, fontSize: .med)
    private let forgotPasswordButton  = CustomButton(title: "Forgot Password? ",          hasBackground: false, fontSize: .small)
    
    
    private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Setup()
        
        self.signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        self.newUserButton.addTarget(self, action: #selector(didTapNewUser), for: .touchUpInside)
        self.forgotPasswordButton.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
     
        setupActivityIndicator()
    }
    
    // MARK: - UI Setup
    func Setup(){
        
        view.backgroundColor = .white
        [headerView , emailField , passwordField , signInButton , newUserButton , forgotPasswordButton ].forEach { box in
            view.addSubview(box)
        }
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(210)
        }
        
        emailField.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(10)
            make.height.equalTo(50)
            
            
            make.centerX.equalTo(headerView)
            make.width.equalTo(view).multipliedBy(0.85)
        }
        
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(15)
            make.height.equalTo(50)
            
            
            make.centerX.equalTo(headerView)
            make.width.equalTo(view).multipliedBy(0.85)
        }
        
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(15)
            make.height.equalTo(50)
            
            
            make.centerX.equalTo(headerView)
            make.width.equalTo(view).multipliedBy(0.85)
        }
        
        newUserButton.snp.makeConstraints { make in
            make.top.equalTo(signInButton.snp.bottom).offset(11)
            make.height.equalTo(50)
            
            
            make.centerX.equalTo(headerView)
            make.width.equalTo(view).multipliedBy(0.85)
        }
        
        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(newUserButton.snp.bottom).offset(6)
            make.height.equalTo(50)
            make.centerX.equalTo(headerView)
            make.width.equalTo(view).multipliedBy(0.85)
        }
        
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        activityIndicator.hidesWhenStopped = true
    }
    
    // MARK: - Selectors
    
    @objc private func didTapSignIn(){
        activityIndicator.startAnimating()

        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            // E-posta ve şifre alanları boş ise hata mesajı göster
            print("Lütfen tüm alanları doldurun.")
            return
        }

        APIService.shared.login(organizationCode: "TEST", email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("Giriş başarılı. Token: \(token)")
                    print( "Giriş başarılı")
                    self?.activityIndicator.stopAnimating()
                    self?.goToNextPage()
                    
                case .failure(let error):
                    print("Giriş başarısız: \(error.localizedDescription)")
                    self?.activityIndicator.stopAnimating()
                    self?.goToNextPage()
                }
            }
        }
    }
    
    private func goToNextPage() {
          print("Sonraki sayfaya geçiş yapılıyor...")
       
        let vc = CameraViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
      }
    
    @objc private func didTapNewUser(){
        print("didTapNewUser")
    }
    
    @objc private func didTapForgotPassword(){
        print("didTapForgotPassword")
    }
    
}
