

import UIKit
import SnapKit


class AuthHeaderView: UIView {
    
 
    // MARK: - UI Components
    let titleLabel    = UILabel()
    let LogoImage     = UIImageView()
    let subTitleLabel = UILabel()
    
    // MARK: - LifeCycle
    init(title: String ,subTitle: String  ) {
        super.init(frame: .zero)
     
        Setup()
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    func Setup(){
        
        titleLabel.text = " Error "
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        
        LogoImage.image = UIImage(named: "image")
        LogoImage.contentMode = .scaleAspectFit
        
        subTitleLabel.text = " Error "
        subTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        subTitleLabel.textAlignment = .center
        subTitleLabel.textColor = .secondaryLabel
        subTitleLabel.textColor = .black

        
        [titleLabel ,subTitleLabel,LogoImage ].forEach { box in
            addSubview(box)
        }
        
        LogoImage.snp.makeConstraints { make in
            make.top.equalTo(layoutMarginsGuide.snp.top).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(LogoImage.snp.width)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(LogoImage.snp.bottom).offset(19)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    
    }
}
