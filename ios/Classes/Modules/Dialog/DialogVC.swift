//
//  DialogVC.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 23/11/22.
//

import UIKit

enum DialogType {
    case Confirmation
    case Info
    case Failure
    case Success
    
    var title: String {
        switch self {
        case .Confirmation:
            return "CONFIRM".localized()
        case .Info:
            return "Info"
        case .Failure:
            return "Failure"
        case .Success:
            return "Success"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .Confirmation: return .fromCurrentBundle(with: "shape_confirm")
        case .Info: return .fromCurrentBundle(with: "shape_information")
        case .Failure: return .fromCurrentBundle(with: "shape_warning")
        case .Success: return .fromCurrentBundle(with: "shape_success")
        }
    }
}

class DialogVC: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stackContentView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var buttonYes: UIButton!
    @IBOutlet weak var buttonNo: UIButton!
    
    private var type: DialogType = .Info
    
    
    var onYes: (() -> Void)?
    var onNo: (() -> Void)?
    
    private var titleText: String
    private var messageText: String?
    
    init(type: DialogType, title: String, message: String?) {
        self.titleText = title
        self.messageText = message
        self.type = type
        
        let bundle = Bundle.getBundle(for: DialogVC.self)
        super.init(nibName: "DialogVC", bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupUI() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8.0
        
        titleLabel.font = AppFonts.font(size: 20, weight: .medium)
        titleLabel.textColor = AppColors.textColor
        titleLabel.text = titleText
        titleLabel.textAlignment = .center
        messageLabel.font = AppFonts.font(size: 15, weight: .regular)
        messageLabel.textColor = AppColors.textColor
        messageLabel.text = messageText
        messageLabel.textAlignment = .center
        
        buttonYes.titleLabel?.font = AppFonts.font(size: 15.0, weight: .semibold)
        buttonYes.setTitleColor(AppColors.textColor, for: .normal)
        buttonYes.clipsToBounds = true
        buttonYes.layer.cornerRadius = 10.0
        buttonYes.layer.borderColor = AppColors.textColor.cgColor
        buttonYes.layer.borderWidth = 1.5
        
        buttonNo.titleLabel?.font = AppFonts.font(size: 15.0, weight: .semibold)
        buttonNo.setTitleColor(AppColors.red, for: .normal)
        buttonNo.clipsToBounds = true
        buttonNo.layer.cornerRadius = 10.0
        buttonNo.layer.borderColor = AppColors.red.cgColor
        buttonNo.layer.borderWidth = 1.5
        
        imageView.image = self.type.icon
        
        switch self.type {
        case .Info:
            buttonNo.isHidden = true
            buttonYes.isHidden = false
            buttonYes.setTitle("BUTTON.OK".localized(), for: .normal)
            
        case .Confirmation:
            buttonNo.isHidden = false
            buttonYes.isHidden = false
            
            buttonNo.setTitle("BUTTON.NO".localized(), for: .normal)
            buttonYes.setTitle("BUTTON.YES".localized(), for: .normal)
            
        case .Failure:
            buttonNo.isHidden = true
            buttonYes.isHidden = false
            
            buttonNo.setTitle("BUTTON.CANCEL".localized(), for: .normal)
            buttonYes.setTitle("BUTTON.RETRY".localized(), for: .normal)
            
        case .Success:
            buttonNo.isHidden = true
            buttonYes.isHidden = false
            
            buttonYes.setTitle("BUTTON.OK".localized(), for: .normal)
        }
    }
    
    @IBAction func didTapYes(_ sender: UIButton) {
        self.dismiss(animated: true) { [weak self] in
            self?.onYes?()
        }
    }
    
    @IBAction func didTapNo(_ sender: UIButton) {
        self.dismiss(animated: true) {[weak self] in
            self?.onNo?()
        }
    }
}

extension DialogVC {
    static func show(
        from viewController: UIViewController,
        type: DialogType,
        title: String? = nil,
        message: String,
        onYes: (() -> Void)? = nil,
        onNo: (() -> Void)? = nil
    ) {
        let dialog = DialogVC(type: type, title: title ?? type.title, message: message)
        dialog.onYes = onYes
        dialog.onNo = onNo
        dialog.modalPresentationStyle = .overFullScreen
        viewController.present(dialog, animated: true)
    }
}
