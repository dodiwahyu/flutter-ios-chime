//
//  DialogVC.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 23/11/22.
//

import UIKit

class DialogVC: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stackContentView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var buttonYes: UIButton!
    @IBOutlet weak var buttonNo: UIButton!
    
    
    var onYes: (() -> Void)?
    var onNo: (() -> Void)?
    
    private var _titleText: String
    private var _messageText: String?
    
    init(title: String, message: String?) {
        _titleText = title
        _messageText = message
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
        titleLabel.text = _titleText
        titleLabel.textAlignment = .center
        messageLabel.font = AppFonts.font(size: 15, weight: .regular)
        messageLabel.textColor = AppColors.textColor
        messageLabel.text = _messageText
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
    }
    
    @IBAction func didTapYes(_ sender: UIButton) {
        self.onYes?()
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapNo(_ sender: UIButton) {
        self.onNo?()
        self.dismiss(animated: true)
    }
}

extension DialogVC {
    static func show(
        from viewController: UIViewController,
        title: String,
        message: String,
        onYes: (() -> Void)? = nil,
        onNo: (() -> Void)? = nil
    ) {
        let dialog = DialogVC(title: "Confirmation", message: "Are you sure want to end the call?")
        dialog.onYes = onYes
        dialog.onNo = onNo
        dialog.modalPresentationStyle = .overFullScreen
        viewController.present(dialog, animated: true)
        
    }
}
