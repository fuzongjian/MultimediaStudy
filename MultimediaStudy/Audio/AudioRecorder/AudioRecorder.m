//
//  AudioRecorder.m
//  MultimediaStudy
//
//  Created by Shao Jie on 16/7/7.
//  Copyright © 2016年 yourangroup. All rights reserved.
//

#import "AudioRecorder.h"
#import "MeterTable.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioRecorder ()<AVAudioRecorderDelegate>
@property (nonatomic,strong) AVAudioPlayer * player;//播放
@property (nonatomic,strong) AVAudioRecorder * recorder;//记录
@property (nonatomic,strong) MeterTable * meterTable;
@end
@implementation AudioRecorder
+ (instancetype)defaultRecorderManager{
    static AudioRecorder * audioRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioRecorder = [[self alloc] init];
    });
    return audioRecorder;
}
- (void)startRecorder{
    [self.recorder record];
}
- (void)stopRecorder{
    [self.recorder stop];
}
- (void)saveRecorderFileName:(NSString *)fileName completion:(void(^)(BOOL success,id object))completion{
    NSTimeInterval timeStamp = [NSDate timeIntervalSinceReferenceDate];
    NSString * filename = [NSString stringWithFormat:@"%@-%f.m4a",fileName,timeStamp];
    NSString * dstPath = [[self documentsDirectory] stringByAppendingPathComponent:filename];
    NSLog(@"---%@",dstPath);
    NSURL * srcURL = self.recorder.url;
    NSURL * dstURL = [NSURL fileURLWithPath:dstPath];
    NSError * error;
    BOOL success = [[NSFileManager defaultManager] copyItemAtURL:srcURL toURL:dstURL error:&error];
    if (success) {
        completion(success,[RecordModel initWithTitle:fileName url:dstURL]);
    }else{
        completion(success,[error localizedDescription]);
    }
}
- (void)playRecorder:(RecordModel *)model{
    NSLog(@"%@",model.url);
    if ([self.player isPlaying]) {
        [self.player pause];
    }
    
    NSError * error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:model.url error:&error];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    if (self.player) {
        [self.player play];
    }else{
        NSLog(@"Error:%@",[error localizedDescription]);
    }
}

- (MeterLavel *)meterLevel{
    
    [self.recorder updateMeters];
    
    CGFloat avgPower    = [self.recorder averagePowerForChannel:0];
    CGFloat peakPower   = [self.recorder peakPowerForChannel:0];
    CGFloat linearLevel = [self.meterTable valueForPower:avgPower];
    CGFloat peakLevel   = [self.meterTable valueForPower:peakPower];
    
    return [MeterLavel levelsWithLevel:linearLevel peakLevel:peakLevel];
}
- (MeterTable *)meterTable{
    if (_meterTable == nil) {
        _meterTable = [[MeterTable alloc] init];
    }
    return _meterTable;
}
#pragma mark --- 懒加载
- (AVAudioRecorder *)recorder{
    if (_recorder == nil) {
        //路径拼接
        NSString * temp = NSTemporaryDirectory();
        NSString * filePath = [temp stringByAppendingPathComponent:@"AudioRecorder.caf"];
        NSURL * fileUrl = [NSURL fileURLWithPath:filePath];
        /**
         1.音频格式
         AVFormatIDKey 键定义了写入内容的音频格式(coreAudioType.h)
         kAudioFormatLinearPCM 文件大 高保真
         kAudioFormatMPEG4AAC 显著压缩文件，并保证高质量的音频内容
         kAudioFormatAppleIMA4 显著压缩文件，并保证高质量的音频内容
         kAudioFormatiLBC
         kAudioFormatULaw
         
         2.采样率
         AVSampleRateKey 用于定义音频的采样率
         采样率越高 内容质量越高 相应文件越大
         标准采样率8000 16000 22050 44100(CD采样率)
         
         3.通道数
         AVNumberOfChannelsKey
         设值为1:意味着使用单声道录音
         设值为2:意味着使用立体声录制
         除非使用外部硬件进行录制，一般是用单声道录制
         
         4.编码器位深度
         5.编码器音频质量

         */
        NSDictionary * setting = @{
                                   AVFormatIDKey : @(kAudioFormatAppleIMA4),
                                   AVSampleRateKey : @44100.0f,
                                   AVNumberOfChannelsKey : @1,
                                   AVEncoderBitDepthHintKey : @16,
                                   AVEncoderAudioQualityKey : @(AVAudioQualityMedium)
                                   };
        NSError * error;
        _recorder = [[AVAudioRecorder alloc] initWithURL:fileUrl settings:setting error:&error];
        // 声音通过听筒输出
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        if (_recorder) {
            _recorder.delegate = self;
            _recorder.meteringEnabled = YES;
            [_recorder prepareToRecord];
        }else{
            NSLog(@"Error:%@",[error localizedDescription]);
        }
   
    }
    return _recorder;
}


- (NSString *)documentsDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}
@end
