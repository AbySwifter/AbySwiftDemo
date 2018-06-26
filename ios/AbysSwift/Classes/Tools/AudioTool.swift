//
//  AudioTool.swift
//  AbysSwift
//  处理录音事件的单例
//  Created by aby on 2018/5/3.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import AVFoundation // 录音的框架
import DTTools

protocol AudioToolDelegate {
    func audioToolRecording(progress: Double) -> Void
    func audioToolRecorded(path: String, duration: Double, name: String) -> Void
}

extension AudioToolDelegate {
    func audioToolRecording(progress: Double) -> Void {
        DTLog("当前录音的秒数\(progress)")
    }
    func audioToolRecorded(path: String, duration: Double, name: String) -> Void {
        DTLog("录音完毕：\(path) 时长: \(duration) 文件名: \(name)")
    }
    func audioToolRecordError(error: Error?) -> Void {
        DTLog("录音出错：")
    }
}



class AudioTool: NSObject {
    static let defaut: AudioTool = AudioTool.init()
    private override init() {}
    // MARK: - 存储属性
    /// 录制时间
    var duration: Double = 0
    /// 录音计时器(在主线程)
    lazy var timer: DispatchSourceTimer = {
        return DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    }()
    /// 录音机
    var recorder: AVAudioRecorder?
    /// 播放器
    var player: AVAudioPlayer?
    // 播完完毕的回调
    var playFinished: (()->(Void))?
    /// 当前录音文件的路径
    var filePath: String?
    /// 当前录音的文件名
    var fileName: String?
    /// 是否正在录音
    var isRecording: Bool = false
    /// 是否获取了麦克风权限
    var hasPermisssion: PermissonStatus = PermissonStatus.undetermined
    /// 录音的代理
    var delegate: AudioToolDelegate?
    // MARK: - 计算属性
    var defaultPath: String {
        return fileManager.accountAudioPath // 默认存在cache文件夹下
    }
    /// 是否停止了录音
    var recordStoped: Bool {
        return !isRecording
    }
    
    // MARK: -懒加载
    /// 文件管理者
    lazy var fileManager: KKFileManager = {
        return KKFileManager.distance
    }()
    /// AudioSession录音会话
    lazy var audioSession: AVAudioSession = {
        return AVAudioSession.sharedInstance()
    }()
    deinit {
        if !self.timer.isCancelled {
            self.timer.cancel()
        }
    }
    // 检测是否授权
    func checkPermission() -> Void {
        let status: AVAudioSessionRecordPermission = self.audioSession.recordPermission() //询问麦克风权限
        var result: PermissonStatus = .undetermined
        switch status {
        case .denied:
            result = .denied
        case .granted:
            result = .granted
        default:
            break
        }
        hasPermisssion = result
    }
}

// MARK: - 录音相关
extension AudioTool {
    /// 准备录音的文件路径
    func parperRecord(file: String) -> Bool {
        checkPermission()
        guard hasPermisssion == .granted else { return false }
        // 设置Session类型
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            DTLog("设置录音会话失败：\(error)")
            return false
        }
        // 设置Session动作(激活Session)
        do {
            try audioSession.setActive(true)
        } catch {
            DTLog("激活会话失败：\(error)")
            return false
        }
        // 录音的参数设置
        let recordSetting: [String: Any] = [
            AVSampleRateKey: NSNumber(value: 22050),//采样率
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),//音频格式 aac格式
            AVLinearPCMBitDepthKey: NSNumber(value: 16),//采样位数
            AVNumberOfChannelsKey: NSNumber(value: 1),//通道数
            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.min.rawValue) //录音质量
        ]
        let url = URL.init(fileURLWithPath: file)
        DTLog("文件路径\(url)")
        do {
            recorder = try AVAudioRecorder.init(url: url, settings: recordSetting)
            recorder?.delegate = self
            if recorder != nil {
                return recorder!.prepareToRecord()
            } else {
                return false
            }
        } catch {
            DTLog("准备录音出错\(error)")
            return false
        }
       
    }
    /// 开始录音，录音前设置录音的位置
    func startRecord(name: String = "default") -> Void {
        fileName = name
        if filePath == nil {
            filePath = defaultPath.appending("/\(name).aac")
        } else {
            filePath = filePath?.appending("/\(name).aac")
        }
        guard parperRecord(file: filePath!) else { return }
        recorder?.record()
        setStatus(true)
        distpatchTimer() /// 开启定时器
    }
    /// 停止录音
    func stopRecrod() -> Void {
        guard let recorder = self.recorder else { return }
        if recorder.isRecording {
            stopTimer() // 停止定时器
            recorder.stop() // 停止录音
        }
    }
    
    /// 播放声音
    func play(url: String) -> Void {
        stopPlay()
        var path: URL?
        if url.contains("http") {
            path = URL.init(string: url)
        } else {
            path = URL.init(fileURLWithPath: url)
        }
        guard path != nil else { DTLog("路径有问题"); return }
        do {
            let data = try Data.init(contentsOf: path!)
            self.player = try AVAudioPlayer.init(data: data)
            self.player?.numberOfLoops = 0 // 播放次数
            self.player?.volume = 1.0
            self.player?.delegate = self
            if (self.player?.prepareToPlay())! {
                self.player?.play()
            }
        } catch {
            DTLog("播放初始化失败\(error)");
            stopPlay()
        }
    }
    /// 停止播放
    func stopPlay() -> Void {
        playFinishedAction()
        if let player = self.player {
            player.stop()
            self.player = nil
        }
    }
    
    func playFinishedAction() -> Void {
        if let block = self.playFinished {
            block()
            self.playFinished = nil
        }
    }
    
    /// 开启定时器
    private func distpatchTimer() -> Void {
        timer.schedule(deadline: .now(), repeating: 0.5) // 每隔1秒执行一次
        timer.setEventHandler {
            self.setRecordTime()
        }
        if !timer.isCancelled {
            timer.resume()
        }
    }
    /// 关闭定时器
    private func stopTimer() -> Void {
        guard !timer.isCancelled else { return }
        timer.suspend()
    }
    /// 定时器轮询设置录音时间
    private func setRecordTime() -> Void {
        guard let time = self.recorder?.currentTime else { return }
        let number = lround(time * 100)
        self.duration = Double(number) / 100
        self.delegate?.audioToolRecording(progress: self.duration)
    }
    /// 设置录音的状态
    private func setStatus(_ status: Bool) -> Void {
        isRecording = status
        if recordStoped {
            self.fileName = nil
            self.filePath = nil
            self.duration = 0
        }
    }
}

// MARK: - 权限相关
extension AudioTool {
    /// 请求麦克风权限
    func requestAccessForAudio() -> Void {
        // 请求麦克风权限
        self.audioSession.requestRecordPermission { (grated) in
            self.hasPermisssion = grated ? .granted : .denied
        }
    }
}

extension AudioTool:  AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    // 录音出错的回调
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        // 录音完成的回调
        self.delegate?.audioToolRecordError(error: error)
        self.filePath = nil
        self.duration = 0
        self.fileName = nil
    }
    // 录音完成的回调
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let path = self.filePath ?? ""
        let duration = self.duration
        let name = self.fileName ?? ""
        self.delegate?.audioToolRecorded(path: path, duration: duration, name: name)
        setStatus(false) // 改变状态
    }
    
    // 播放完成的回调
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playFinishedAction()
        self.player = nil
    }
    
    // 播放出错的回调
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        self.player?.stop()
        self.player = nil
    }
}
