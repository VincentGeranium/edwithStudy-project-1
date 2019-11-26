//
//  ViewController.swift
//  musicApp
//
//  Created by 김광준 on 20/09/2019.
//  Copyright © 2019 VincentGeranium. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    
    var player = AVAudioPlayer()
    var timer = Timer()
    let playPauseButton = UIButton(type: .custom)
    let timeLabel = UILabel()
    let slider = UISlider()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        initSoundPlayer()
        addViewsWithCode()
        addConfigure()
        
    }
    
    private func addViewsWithCode() {
        addPlayAndPauseButton()
        addTimeLabel()
        addProgressSlider()
    }
    
    private func addConfigure() {
        labelConfigure()
        sliderConfigure()
    }
    
    private func initSoundPlayer() {
        
        guard let soundAsset: NSDataAsset = NSDataAsset.init(name: "sound") else {
            print("Error: sound 음원을 가져올 수 없습니다")
            return
        }
        
        do {
            try self.player = AVAudioPlayer(data: soundAsset.data)
            self.player.delegate = self
        } catch let error as NSError {
            print("Error: 플레이어 초기화 실패")
            print("Error Code: \(error.code), Message: \(error.localizedDescription)")
        }
        
    }
    
    private func sliderConfigure() {
        
        self.slider.maximumValue = Float(self.player.duration)
        self.slider.minimumValue = 0
        self.slider.value = Float(self.player.currentTime)
    }
    
    private func addPlayAndPauseButton() {
        
        guard let playButtonImage: UIImage = UIImage.init(named: "button_play") else {
            print("Error: button_play 이미지를 가져올 수 없습니다")
            return
        }
        
        guard let pauseButtonImage: UIImage = UIImage.init(named: "button_pause") else {
            print("Error: button_pause 이미지를 가져올 수 없습니다")
            return
        }
        
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(playPauseButton)
        
        playPauseButton.setImage(playButtonImage, for: .normal)
        playPauseButton.setImage(pauseButtonImage, for: .selected)
        
        let guide = view.safeAreaLayoutGuide
        
        let btnWidthSize = (view.bounds.size.width - (view.bounds.size.width - 200))
        let btnHeightSize = (view.bounds.size.height - (view.bounds.size.height - 200))
        
        let btnTop: NSLayoutConstraint
        btnTop = playPauseButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: 50)
        
        let btnCenterX: NSLayoutConstraint
        btnCenterX = playPauseButton.centerXAnchor.constraint(equalTo: guide.centerXAnchor)
        
        let btnWidth: NSLayoutConstraint
        btnWidth = playPauseButton.widthAnchor.constraint(equalToConstant: btnWidthSize)
        
        let btnHeight: NSLayoutConstraint
        btnHeight = playPauseButton.heightAnchor.constraint(equalToConstant: btnHeightSize)
        
        playPauseButton.addTarget(self, action: #selector(didTapPlayPauseBtn(_:)), for: .touchUpInside)
        
        btnTop.isActive = true
        btnCenterX.isActive = true
        btnWidth.isActive = true
        btnHeight.isActive = true
    }
    
    @objc private func didTapPlayPauseBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.player.play()
        } else {
            self.player.pause()
        }
        
        if sender.isSelected {
            self.makeAndFireTimer()
        } else {
            self.invalidateTimer()
        }
    }
    
    private func addTimeLabel() {
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(timeLabel)
        
        timeLabel.text = "00:00:00"
        
        let guide = view.safeAreaLayoutGuide
        
        let labelCenterX: NSLayoutConstraint
        labelCenterX = timeLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor)
        
        let labelTop: NSLayoutConstraint
        labelTop = timeLabel.topAnchor.constraint(equalTo: playPauseButton.bottomAnchor , constant: 6)
        
        let labelWidth: NSLayoutConstraint
        labelWidth = timeLabel.widthAnchor.constraint(equalTo: playPauseButton.widthAnchor, multiplier: 1.0)
        
        labelCenterX.isActive = true
        labelTop.isActive = true
        labelWidth.isActive = true
        
    }
    
    private func addProgressSlider() {
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(slider)
        
        let guide = view.safeAreaLayoutGuide
        
        let sliderCenterX: NSLayoutConstraint
        sliderCenterX = slider.centerXAnchor.constraint(equalTo: guide.centerXAnchor)
        
        let sliderTop: NSLayoutConstraint
        sliderTop = slider.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 6)

        let sliderLeading: NSLayoutConstraint
        sliderLeading = slider.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16)
        
        let sliderTrailing: NSLayoutConstraint
        sliderTrailing = slider.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16)
        
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        
        sliderCenterX.isActive = true
        sliderTop.isActive = true
        sliderLeading.isActive = true
        sliderTrailing.isActive = true
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        self.updateTimeLabelText(time: TimeInterval(sender.value))
        if sender.isTracking { return }
        self.player.currentTime = TimeInterval(sender.value)
    }
    
    private func labelConfigure() {
        timeLabel.textAlignment = .center
        timeLabel.font = .systemFont(ofSize: 23)
    }
    
    private func updateTimeLabelText(time: TimeInterval) {
        let minute: Int = Int(time / 60)
        let second: Int = Int(time.truncatingRemainder(dividingBy: 60))
        let milisecond: Int = Int(time.truncatingRemainder(dividingBy: 1) * 100)
        
        let timeText: String = String(format: "%02ld:%02ld:%02ld", minute, second, milisecond)
        
        self.timeLabel.text = timeText
    }
    
    private func makeAndFireTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [unowned self](timer: Timer) in
            if self.slider.isTracking { return }
            
            self.updateTimeLabelText(time: self.player.currentTime)
            self.slider.value = Float(self.player.currentTime)
        })
        self.timer.fire()
    }
    
    private func invalidateTimer() {
        self.timer.invalidate()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playPauseButton.isSelected = false
        self.slider.value = 0
        self.updateTimeLabelText(time: 0)
        self.invalidateTimer()
    }

}

