//
//  SettingViewController.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 01/12/22.
//

import UIKit
import AmazonChimeSDK
import AmazonChimeSDKMedia

class SettingViewController: BottomPopupViewController {
    
    var meetingSession: DefaultMeetingSession!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var speakerTagLabel: UILabel!
    @IBOutlet weak var speakerField: UIControl!
    @IBOutlet weak var speakerLabel: UILabel!
    
    
    // MARK: - BottomPopupAttributesDelegate Variables
    override var popupHeight: CGFloat { 250.0 }
    override var popupTopCornerRadius: CGFloat { 10.0 }
    override var popupPresentDuration: Double { 0.3 }
    override var popupDismissDuration: Double { 0.3 }
    override var popupShouldDismissInteractivelty: Bool { true }
    override var popupDimmingViewAlpha: CGFloat { BottomPopupConstants.dimmingViewDefaultAlphaValue }
    
    init(meetingSession: DefaultMeetingSession) {
        let bundle = Bundle.getBundle(for: SettingViewController.self)
        super.init(nibName: "SettingViewController", bundle: bundle)
        self.meetingSession = meetingSession
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.font = AppFonts.font(size: 16.0, weight: .medium)
        titleLabel.textColor = AppColors.textColor
        
        speakerTagLabel.font = AppFonts.font(size: 14.0, weight: .regular)
        speakerTagLabel.textColor = AppColors.textColor
        
        speakerLabel.font = AppFonts.font(size: 14.0, weight: .regular)
        speakerLabel.textColor = AppColors.textColor
        speakerLabel.text = meetingSession.audioVideo.getActiveAudioDevice()?.label ?? "Unkown"
    }
    
    @IBAction func didTapSpeakerOption(_ sender: UIControl) {
        let devices = meetingSession.audioVideo.listAudioDevices()
        
        let alert = UIAlertController(title: "Audio Dvices", message: "Choose audio device", preferredStyle: .actionSheet)
        
        for device in devices {
            let option = UIAlertAction(title: device.label, style: .default) {[weak self] (_) in
                self?.meetingSession.audioVideo.chooseAudioDevice(mediaDevice: device)
                self?.speakerLabel.text = device.label
            }
            alert.addAction(option)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(cancel)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
        }
        
        self.present(alert, animated: true)
    }
    
}
