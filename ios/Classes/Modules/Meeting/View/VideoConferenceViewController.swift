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

class VideoConferenceViewController: UIViewController {
    var viewModel: VideoConferenceVM!
    
    @IBOutlet weak var prymaryScreenView: DefaultVideoRenderView!
    @IBOutlet weak var secondaryScreenView: DefaultVideoRenderView!
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var recordTimeLabel: UILabel!
    
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var scriptButton: UIButton!
    
    @IBOutlet weak var scriptContentView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var bottomConstraintSecondVideoView: NSLayoutConstraint!
    
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
        setupUI()
        viewModel.addObserver()
        viewModel.output = self
        viewModel.startMeeting {[weak self] isSuccess in
            guard isSuccess, let self else { return }
            self.viewModel.startLocalVideo()
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func didTapEndButton(_ sender: UIButton) {
        viewModel.requestEndMeeting()
    }
    
    @IBAction func didTapMicBUtton(_ sender: UIButton) {
        self.viewModel.isMute = !self.viewModel.isMute
        self.viewModel.isMute ? sender.setTitle("Unmute", for: .normal) : sender.setTitle("Mute", for: .normal)
    }
    
    // MARK: Private
    private func resetState() {
        indicatorView.isHidden = true
        recordTimeLabel.isHidden = true
        recordTimeLabel.text = ""
        scriptContentView.isHidden = true
    }
    
    private func showRecordTime() {
        indicatorView.isHidden = false
        recordTimeLabel.isHidden = false
    }
    
    private func setupUI() {
        prymaryScreenView.backgroundColor = .white
        secondaryScreenView.backgroundColor = .clear
        
        endButton.setTitle("", for: .normal)
        micButton.setTitle("", for: .normal)
        scriptButton.setTitle("", for: .normal)
        
        scriptContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        resetState()
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
}



extension VideoConferenceViewController: VideoConferenceVMOutput {
    func vmDidBindLocalScreen(for session: AmazonChimeSDK.DefaultMeetingSession, tileId: Int) {
        session.audioVideo.bindVideoView(videoView: prymaryScreenView, tileId: tileId)
    }
    
    func vmDidBindContentScreen(for session: AmazonChimeSDK.DefaultMeetingSession, tileId: Int) {
        session.audioVideo.bindVideoView(videoView: secondaryScreenView, tileId: tileId)
    }
}
