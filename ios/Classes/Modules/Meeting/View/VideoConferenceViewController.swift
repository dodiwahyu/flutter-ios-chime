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
    
    @IBOutlet weak var bottomConstraintSecondVideoView: NSLayoutConstraint!
    
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
            title: "Warning",
            message: "Akah anda yakin ingin mengakhiri video conference",
            onYes: {[weak self] in
                self?.viewModel.requestEndMeeting()
            },
            onNo: nil
        )
    }
    
    @IBAction func didTapMicBUtton(_ sender: UIButton) {
        self.viewModel.isMute = !self.viewModel.isMute
        sender.backgroundColor = self.viewModel.isMute ? AppColors.grey : AppColors.primary
        let icon = Bundle.image(classType: Self.self, name: self.viewModel.isMute ? "icon_mic_mute" : "icon_mic_unmute")
        sender.setImage(icon, for: .normal)
    }
    
    @IBAction func didTapToggleScript(_ sender: UIButton) {
        self.toggleScript()
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        DialogVC.show(
            from: self,
            title: "Warning",
            message: "Akah anda yakin ingin mengakhiri video conference",
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
        scriptContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        maskSecondaryScreenView.backgroundColor = AppColors.grey
        maskSecondaryScreenView.isHidden = false
        
        settingButton.setTitle("", for: .normal)
        endButton.setTitle("", for: .normal)
        micButton.setTitle("", for: .normal)
        scriptButton.setTitle("", for: .normal)
        backButton.titleLabel?.font = AppFonts.font(size: 12, weight: .semibold)
        backButton.setTitleColor(AppColors.primary, for: .normal)
        
        titleLabel.font = AppFonts.font(size: 14.0, weight: .semibold)
        titleLabel.font = AppFonts.font(size: 14.0, weight: .semibold)
        backButton.titleLabel?.font = AppFonts.font(size: 14.0, weight: .semibold)
        backButton.titleLabel?.textColor = AppColors.primary
        textView.font = AppFonts.font(size: 12.0, weight: .medium)
        textView.textColor = AppColors.textColor
        
        recordTimeLabel.textColor = .black
        contentRecordingView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        
        connectivityView.backgroundColor = AppColors.red
        
        resetState()
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
        
        viewModel.onRecordingDidStarted = {[weak self] in
            print("Record did started")
        }
        viewModel.onRecordingDidStopped = {[weak self] in
            print("Record did stopped")
        }
        
        viewModel.onTimeDidTick = {[weak self] (args) in
            self?.showRecordingTime(args)
        }
        viewModel.onTimeAlert = {[weak self] (args) in
            self?.showStatusAlert(with: "Waktu recording tersisa \(args)")
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
            guard isSuccess, let self else { return }
            self.viewModel.startLocalVideo()
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
}



extension VideoConferenceViewController: VideoConferenceVMOutput {
    func vmDidBindLocalScreen(for session: AmazonChimeSDK.DefaultMeetingSession, tileId: Int) {
        session.audioVideo.bindVideoView(videoView: prymaryScreenView, tileId: tileId)
    }
    
    func vmDidBindContentScreen(for session: AmazonChimeSDK.DefaultMeetingSession, tileId: Int) {
        maskSecondaryScreenView.isHidden = true
        session.audioVideo.bindVideoView(videoView: secondaryScreenView, tileId: tileId)
    }
}
