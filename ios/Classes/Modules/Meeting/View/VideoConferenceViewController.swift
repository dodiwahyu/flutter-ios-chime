//
//  VideoConferenceViewController.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 13/10/22.
//

import UIKit
import AmazonChimeSDK
import AmazonChimeSDKMedia
import Flutter
import Connectivity

class VideoConferenceViewController: UIViewController {
    var viewModel: VideoConferenceVM!
    
    // Navigation Bar
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var connectivityView: UIView!
    
    @IBOutlet weak var prymaryScreenView: DefaultVideoRenderView!
    @IBOutlet weak var secondaryScreenView: DefaultVideoRenderView!
    
    @IBOutlet weak var contentRecordingView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var recordTimeLabel: UILabel!
    
    @IBOutlet weak var statusAlertView: UIView!
    @IBOutlet weak var statusAlertLabel: UILabel!
    
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var scriptButton: UIButton!
    
    @IBOutlet weak var scriptContentView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var maskSecondaryScreenView: UIView!
    @IBOutlet weak var maskDescLabel: UILabel!
    @IBOutlet weak var maskImageView: UIImageView!
    
    @IBOutlet weak var bottomConstraintSecondVideoView: NSLayoutConstraint!
    var secondaryScreenHeight: NSLayoutConstraint?
    
    private var connectivity = Connectivity()
    private var isSessionStarted = false
    
    init() {
        let bundle = Bundle.getBundle(for: VideoConferenceViewController.self)
        super.init(nibName: "VideoConferenceViewController", bundle: bundle)
    }
    
    deinit {
        viewModel.removeObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initConnectivity()
        setupUI()
        bindView()
        
        connectivity.startNotifier()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startVideoSessions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func didTapSetting(_ sender: UIButton) {
        let vc = SettingViewController(meetingSession: viewModel.meetingSession)
        self.present(vc, animated: true)
    }
    
    @IBAction func didTapEndButton(_ sender: UIButton) {
        DialogVC.show(
            from: self,
            type: .Confirmation,
            message: "CONFERENCE.MESSAGE_CONFIRM_END".localized(),
            onYes: {[weak self] in
                self?.viewModel.requestEndMeeting()
            },
            onNo: nil
        )
    }
    
    @IBAction func didTapMicBUtton(_ sender: UIButton) {
        self.viewModel.isMute = !self.viewModel.isMute
        sender.backgroundColor = self.viewModel.isMute ? AppColors.grey : AppColors.primary
        sender.setImage(.fromCurrentBundle(with: self.viewModel.isMute ? "icon_mic_mute" : "icon_mic_unmute"), for: .normal)
    }
    
    @IBAction func didTapToggleScript(_ sender: UIButton) {
        self.toggleScript()
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        DialogVC.show(
            from: self,
            type: .Confirmation,
            message: "CONFERENCE.MESSAGE_CONFIRM_END".localized(),
            onYes: {[weak self] in
                self?.viewModel.requestEndMeeting()
            }, onNo: nil)
    }
    
    
    // MARK: Private
    private func initConnectivity() {
        let connectivityChanged: (Connectivity) -> Void = { [weak self] connectivity in
             self?.updateConnectionStatus(connectivity.status)
        }
        connectivity.whenConnected = connectivityChanged
        connectivity.whenDisconnected = connectivityChanged
    }
    
    private func resetState() {
        contentRecordingView.isHidden = true
        recordTimeLabel.text = ""
        scriptContentView.isHidden = true
    }
    
    private func resetTimerRecord() {
        viewModel.resetTimerRecord()
    }
    
    private func setupUI() {
        prymaryScreenView.backgroundColor = .white
        secondaryScreenView.backgroundColor = .clear
        statusAlertView.backgroundColor = AppColors.primary
        
        scriptContentView.clipsToBounds = true
        scriptContentView.layer.cornerRadius = 12
        scriptContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        maskSecondaryScreenView.backgroundColor = AppColors.grey
        maskSecondaryScreenView.isHidden = false
        maskImageView.image = .fromCurrentBundle(with: "image_profile")
        
        settingButton.setTitle("", for: .normal)
        settingButton.setImage(.fromCurrentBundle(with: "icon_more"), for: .normal)
        endButton.setTitle("", for: .normal)
        endButton.setImage(.fromCurrentBundle(with: "icon_phone"), for: .normal)
        micButton.setTitle("", for: .normal)
        micButton.setImage(.fromCurrentBundle(with: "icon_mic_unmute"), for: .normal)
        scriptButton.setTitle("", for: .normal)
        scriptButton.setImage(.fromCurrentBundle(with: "icon_file"), for: .normal)
        backButton.titleLabel?.font = AppFonts.font(size: 12, weight: .semibold)
        backButton.setTitleColor(AppColors.primary, for: .normal)
        
        titleLabel.font = AppFonts.font(size: 14.0, weight: .semibold)
        titleLabel.font = AppFonts.font(size: 14.0, weight: .semibold)
        backButton.titleLabel?.font = AppFonts.font(size: 14.0, weight: .semibold)
        backButton.titleLabel?.textColor = AppColors.primary
        textView.font = AppFonts.font(size: 12.0, weight: .medium)
        textView.textColor = AppColors.textColor
        textView.backgroundColor = .white
        
        recordTimeLabel.textColor = .black
        contentRecordingView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        
        connectivityView.backgroundColor = AppColors.red
        
        resetState()
        setupScript()
        setRatioSecondaryScreen(130/170)
    }
    
    private func setupScript() {
        let attibuted = NSMutableAttributedString()
        
        let title = "CONFERENCE.SCRIPT_AGENT_TITLE".localized()
        attibuted.append(NSAttributedString(string: title + "\n\n", attributes: [.font: AppFonts.font(size: 15.0, weight: .bold)]))
        
        let content = viewModel.wordingText ?? "CONFERENCE.SCRIPT_EMPTY".localized()
        attibuted.append(NSAttributedString(string: content, attributes: [.font: AppFonts.font(size: 13.0, weight: .regular)]))
        
        textView.attributedText = attibuted
    }
    
    private func showStatusAlert(with message: String) {
        if (statusAlertView.isHidden) {
            UIView.animate(withDuration: 0.3, delay: 0.0) {
                self.statusAlertView.isHidden = false
            }
        }
        
        statusAlertLabel.text = message
    }
    
    private func hideStatusAlert() {
        statusAlertView.isHidden = true
        statusAlertLabel.text = ""
    }
    
    private func showRecordingTime(_ current: String) {
        recordTimeLabel.text = current
        
        if (contentRecordingView.isHidden) {
            UIView.animate(withDuration: 0.3, delay: 0.0) {
                self.contentRecordingView.isHidden = false
            }
        }
    }
    
    private func bindView() {
        viewModel.addObserver()
        viewModel.output = self
        viewModel.onTimeDidTick = {[weak self] (args) in
            self?.showRecordingTime(args)
        }
        viewModel.onTimeAlert = {[weak self] (args) in
            self?.showStatusAlert(with: "CONFERENCE.MESSAGE_MEETING_WARNING".localizedWithFormat(args))
        }
        
        viewModel.onTimesup = {[weak self] in
            self?.dismiss(animated: true)
        }
        
    }
    
    func startVideoSessions() {
        if isSessionStarted {
            return
        }
        
        viewModel.startMeeting {[weak self] isSuccess in
            self?.isSessionStarted = isSuccess
        }
    }
    
    private func toggleScript() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState) {
            self.scriptContentView.isHidden = !self.scriptContentView.isHidden
            let bottomMargin: CGFloat = 16.0
            self.bottomConstraintSecondVideoView.constant = self.scriptContentView.isHidden ? self.view.safeAreaInsets.bottom + bottomMargin : bottomMargin
            self.view.layoutIfNeeded()
        }
    }
    
    private func bindLocalScreen(_ args: (DefaultMeetingSession, Int)) {
        args.0.audioVideo.bindVideoView(videoView: prymaryScreenView, tileId: args.1)
    }
    
    private func bindContentScreen(_ args: (DefaultMeetingSession, Int)) {
        args.0.audioVideo.bindVideoView(videoView: secondaryScreenView, tileId: args.1)
    }
    
    private func updateConnectionStatus(_ status: Connectivity.Status) {
        switch status {
        case .connectedViaCellular,
            .connectedViaWiFi,
            .connected:
            connectivityView.backgroundColor = AppColors.green
            
        case .notConnected,
            .connectedViaCellularWithoutInternet,
            .connectedViaWiFiWithoutInternet:
            connectivityView.backgroundColor = AppColors.red
            
        case .determining:
            connectivityView.backgroundColor = AppColors.orange
        }
    }
    
    private func setRatioSecondaryScreen(_ multiplier: CGFloat) {
        if let current = secondaryScreenHeight {
            NSLayoutConstraint.deactivate([current])
            secondaryScreenView.removeConstraint(current)
        }
        
        secondaryScreenHeight = NSLayoutConstraint(
            item: secondaryScreenView!,
            attribute: .width,
            relatedBy: .equal,
            toItem: secondaryScreenView!,
            attribute: .height,
            multiplier: multiplier,
            constant: 0)
        
        secondaryScreenView.addConstraint(secondaryScreenHeight!)
        NSLayoutConstraint.activate([secondaryScreenHeight!])
        
        view.layoutIfNeeded()
    }
}



extension VideoConferenceViewController: VideoConferenceVMOutput {
    func vmDidUnBindLocalScreen(for session: AmazonChimeSDK.DefaultMeetingSession, tileId: Int) {
    }
    
    func vmDidUnBindContentScreen(for session: AmazonChimeSDK.DefaultMeetingSession, tileId: Int) {
        maskSecondaryScreenView.isHidden = false
    }
    
    func vmDidBindLocalScreen(for session: AmazonChimeSDK.DefaultMeetingSession, tileId: Int) {
        session.audioVideo.bindVideoView(videoView: prymaryScreenView, tileId: tileId)
    }
    
    func vmDidBindContentScreen(for session: AmazonChimeSDK.DefaultMeetingSession, tileId: Int) {
        maskSecondaryScreenView.isHidden = true
        session.audioVideo.bindVideoView(videoView: secondaryScreenView, tileId: tileId)
    }
    
    func vmSessionDidEnd() {
        DialogVC.show(from: self, type: .Info, message: "CONFERENCE.MESSAGE_SESSION_END".localized(), onYes:  { [weak self] in
            self?.dismiss(animated: true)
        })
    }
    
    func vmVideoTileSizeDidChange(for session: DefaultMeetingSession, tileState: VideoTileState) {
        
        var multiplier: CGFloat = 130/170
        
        let height = tileState.videoStreamContentHeight
        let width = tileState.videoStreamContentWidth
        
        if height > 0 && width > 0 {
            multiplier = CGFloat(width) / CGFloat(height)
        }
        
        setRatioSecondaryScreen(multiplier)
    }
}
