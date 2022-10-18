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
    
    @IBOutlet weak var viewTapBar: UIView!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var optionButton: UIButton!

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
    
    @IBAction func didTapSoundButton(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapCameraButton(_ sender: UIButton) {
        self.viewModel.enableCamera = !self.viewModel.enableCamera
        self.viewModel.enableCamera ? sender.setTitle("Disable", for: .normal) : sender.setTitle("Enable", for: .normal)
    }
    
    @IBAction func didTapEndButton(_ sender: UIButton) {
//        viewModel.stopMeeting()
//        self.dismiss(animated: true)
        viewModel.requestEndMeeting()
    }
    
    @IBAction func didTapMicBUtton(_ sender: UIButton) {
        self.viewModel.isMute = !self.viewModel.isMute
        self.viewModel.isMute ? sender.setTitle("Unmute", for: .normal) : sender.setTitle("Mute", for: .normal)
    }
    
    @IBAction func didTapOptionButton(_ sender: UIButton) {
        
    }
    
    // MARK: Private
    private func setupUI() {
        updateLayoutTabBar()
        
        soundButton.setTitle("", for: .normal)
        cameraButton.setTitle("", for: .normal)
        endButton.setTitle("", for: .normal)
        micButton.setTitle("", for: .normal)
        optionButton.setTitle("", for: .normal)
    }
    
    private func updateLayoutTabBar() {
        viewTapBar.layer.cornerRadius = viewTapBar.frame.height / 2
        viewTapBar.backgroundColor = Colors.primary
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
