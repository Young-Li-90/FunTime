//
//  TEFunTimePlayerView.swift
//  takeEasy
//
//  Created by Gordon on 2017/8/5.
//  Copyright © 2017年 Gordon. All rights reserved.
//

import UIKit
import Kingfisher
import Jukebox
import AVFoundation

class TEFunTimePlayerView: UIView, JukeboxDelegate {

    var funTimeModel = TEFunTimeListModel() {
        didSet {
            
            guard let imgUrl = URL.init(string: funTimeModel.imgsrc) else {
                d_print("imgSrc is illegal")
                return
            }
            bgImgView.kf.setImage(with: imgUrl, placeholder: nil, options: nil, progressBlock: nil) { [weak self](image, error, url, data) in
                if error == nil {
                    self?.bgImgView.image = image?.blur()
                    self?.effectView.removeFromSuperview()
                }
            }
        }
    }
    var detailModel = TEFunTimDetailModel() {
        didSet {
            guard let url = detailModel.mp3Url else {
                return
            }
            if detailModel.isDownload {
                self.downloadBtn.isUserInteractionEnabled = false
                self.downloadBtn.isSelected = true
                self.circleProgress.isHidden = true
            }
            
            player = Jukebox.init(delegate: self, items: [JukeboxItem.init(URL: url, localTitle: detailModel.alt)])
            
//            avPlayer = AVPlayer.init(url: url)
//            if #available(iOS 10.0, *) {
//                avPlayer?.automaticallyWaitsToMinimizeStalling = false
//            } else {
//                // Fallback on earlier versions
//            }
//            d_print("playItem : \(String(describing: avPlayer?.currentItem))")
        }
    }
    private var player: Jukebox?
    private var bgImgView: UIImageView!
    private var effectView: UIVisualEffectView!
    private var playBgView: UIImageView!
    private var playBtn: LYFrameButton!
    private var downloadBtn: LYFrameButton!
    private var circleProgress: LYCircleProgressView!
    
//    private var avPlayer: AVPlayer?
    
    // MARK: - ********* Player delegate
    func jukeboxStateDidChange(_ jukebox: Jukebox) {
        
    }
    func jukeboxPlaybackProgressDidChange(_ jukebox: Jukebox) {
        
    }
    func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {
        
    }
    func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {
        
    }
    // MARK: - ********* Actions
    // MARK: - ********* 点击播放/暂停
    func p_actionPlayBtn() {
        if detailModel.url_m3u8 == "" { return }
        playBtn.isSelected = !playBtn.isSelected
        if playBtn.isSelected {
            playBgView.layer.ly.rotate360degree(duration: 12, repeatCount: MAXFLOAT)
            if #available(iOS 10.0, *) {
                player?.play()
            } else {
                
            }
        } else {
            playBgView.layer.ly.stopRotate360()
            player?.pause()
        }
        
    }
    // MARK: - ********* 点击下载
    func p_actionDownloadBtn() {
        
        if detailModel.url_m3u8 == "" { return }
        downloadBtn.isUserInteractionEnabled = false
        downloadBtn.setImage(nil, for: .normal)
        circleProgress.isHidden = false
        self.p_actionStartDownload()
    }
    // MARK: - ********* 开始下载
    func p_actionStartDownload() {
        
        LYNetWorkRequest.ly_downloadFile(atPath: detailModel.url_m3u8, downProgress: { [weak self](progress, fileName) in
            self?.circleProgress.progress = progress.percent
        }) { [weak self](fileUrl) in
            self?.circleProgress.progress = 1
            self?.downloadBtn.isSelected = true
            self?.circleProgress.isHidden = true
            self?.detailModel.mp3Url = fileUrl
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.ly_size = CGSize.init(width: kScreenWid(), height: kFitCeilWid(188))
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        
        bgImgView = UIImageView.init(frame: self.bounds)
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.image = UIImage.init(named: "ft_play_bg")
        self.addSubview(bgImgView)
        let effect = UIBlurEffect.init(style: .light)
        effectView = UIVisualEffectView.init(effect: effect)
        effectView.frame = bgImgView.bounds
        bgImgView.addSubview(effectView)
        
        let bgPlay = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kFitCeilWid(116), height: kFitCeilWid(116)))
        bgPlay.layer.ly.setRoundRect()
        bgPlay.center = CGPoint.init(x: self.middleX, y: self.middleY - kFitCeilWid(5))
        bgPlay.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
        self.addSubview(bgPlay)
        
        playBgView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: kFitCeilWid(105), height: kFitCeilWid(105)))
        playBgView.center = bgPlay.center
        playBgView.contentMode = .scaleAspectFill
        playBgView.image = UIImage.init(named: "ft_play_cover")
        playBgView.layer.ly.setRoundRect()
        self.addSubview(playBgView)
        
        playBtn = LYFrameButton.init(frame: playBgView.frame)
        playBtn.layer.ly.setRoundRect()
        playBtn.backgroundColor = UIColor.init(white: 0, alpha: 0.2)
        playBtn.setImage(UIImage.init(named: "ft_palyer_play")?.ly_image(tintColor: UIColor.init(white: 1, alpha: 0.8)), for: .normal)
        playBtn.setImage(UIImage.init(named: "ft_palyer_pause")?.ly_image(tintColor: UIColor.init(white: 1, alpha: 0.8)), for: .selected)
        playBtn.addTarget(self, action: #selector(p_actionPlayBtn), for: .touchUpInside)
        self.addSubview(playBtn)
        
        
        let sliderView = LYPlaySlider.init(frame: CGRect.init(x: kFitCeilWid(20), y: self.height - kFitCeilWid(25), width: self.width - kFitCeilWid(40), height: kFitCeilWid(25)))
        self.addSubview(sliderView)
        
        
        downloadBtn = LYFrameButton.init(frame: CGRect.init(x: self.width - kFitCeilWid(44), y: 0, width: kFitCeilWid(44), height: kFitCeilWid(44)))
        downloadBtn.lyImageViewFrame = downloadBtn.bounds
        downloadBtn.imageView?.contentMode = .center
        downloadBtn.setImage(UIImage.init(named: "ft_play_download")?.ly_image(tintColor: UIColor.init(white: 1, alpha: 0.8)), for: .normal)
        downloadBtn.setImage(UIImage.init(named: "ft_play_havDownload")?.ly_image(tintColor: UIColor.init(white: 1, alpha: 0.8)), for: .selected)
        downloadBtn.addTarget(self, action: #selector(p_actionDownloadBtn), for: .touchUpInside)
        self.addSubview(downloadBtn)
        
        circleProgress = LYCircleProgressView.init(frame: CGRect.init(x: 0, y: 0, width: kFitCeilWid(34), height: kFitCeilWid(34)))
        circleProgress.center = downloadBtn.b_center
        circleProgress.isUserInteractionEnabled = false
        downloadBtn.addSubview(circleProgress)
        circleProgress.isHidden = true
    
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
