//
//  AudioReader.m
//  MultimediaStudy
//
//  Created by Shao Jie on 16/7/7.
//  Copyright © 2016年 yourangroup. All rights reserved.
//

#import "AudioReader.h"
#import <AVFoundation/AVFoundation.h>
@interface AudioReader ()
@property (nonatomic,strong)AVSpeechSynthesizer * synthesizer;//语音合成器
@end
@implementation AudioReader
+ (instancetype)defalutReaderManager{
    static AudioReader * readerManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        readerManager = [[self alloc] init];
    });
    return readerManager;
}
- (void)startReaderText:(NSString *)content{
    // AVSpeechUtterance文本转化成语音
    AVSpeechUtterance * speech = [[AVSpeechUtterance alloc] initWithString:content];
    speech.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];//语种配置
    speech.rate = 0.3f;//语速
    speech.pitchMultiplier = 1.0f;//音高
    speech.postUtteranceDelay = 0.1f;//上一句与下一句的播放间隔
    [self.synthesizer speakUtterance:speech];//生成语音
}
- (void)pauseReader{
    [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}
- (void)stopReader{
    [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    self.synthesizer = nil;
}
- (void)continueReader{
    [self.synthesizer continueSpeaking];
}
- (AVSpeechSynthesizer *)synthesizer{
    if (_synthesizer == nil) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    return _synthesizer;
}
#warning 错误提示
//   问题：
/*  AXSpeechAssetDownloader|error| ASAssetQuery error fetching results (for com.apple.MobileAsset.MacinTalkVoiceAssets) Error Domain=ASError Code=21 "Unable to copy asset information" UserInfo={NSDescription=Unable to copy asset information}  */
//  解决方案
/*  进入iPhone的 设置 > 通用 > 辅助功能 > 语音，开启“朗读所选项”，并在“嗓音”中选择“中文（台湾）”  */

//"[AVSpeechSynthesisVoice 0x978a0b0] Language: th-TH",
//"[AVSpeechSynthesisVoice 0x977a450] Language: pt-BR",
//"[AVSpeechSynthesisVoice 0x977a480] Language: sk-SK",
//"[AVSpeechSynthesisVoice 0x978ad50] Language: fr-CA",
//"[AVSpeechSynthesisVoice 0x978ada0] Language: ro-RO",
//"[AVSpeechSynthesisVoice 0x97823f0] Language: no-NO",
//"[AVSpeechSynthesisVoice 0x978e7b0] Language: fi-FI",
//"[AVSpeechSynthesisVoice 0x978af50] Language: pl-PL",
//"[AVSpeechSynthesisVoice 0x978afa0] Language: de-DE",
//"[AVSpeechSynthesisVoice 0x978e390] Language: nl-NL",
//"[AVSpeechSynthesisVoice 0x978b030] Language: id-ID",
//"[AVSpeechSynthesisVoice 0x978b080] Language: tr-TR",
//"[AVSpeechSynthesisVoice 0x978b0d0] Language: it-IT",
//"[AVSpeechSynthesisVoice 0x978b120] Language: pt-PT",
//"[AVSpeechSynthesisVoice 0x978b170] Language: fr-FR",
//"[AVSpeechSynthesisVoice 0x978b1c0] Language: ru-RU",
//"[AVSpeechSynthesisVoice 0x978b210] Language: es-MX",
//"[AVSpeechSynthesisVoice 0x978b2d0] Language: zh-HK",  中文(香港) 粤语
//"[AVSpeechSynthesisVoice 0x978b320] Language: sv-SE",
//"[AVSpeechSynthesisVoice 0x978b010] Language: hu-HU",
//"[AVSpeechSynthesisVoice 0x978b440] Language: zh-TW",  中文(台湾)
//"[AVSpeechSynthesisVoice 0x978b490] Language: es-ES",
//"[AVSpeechSynthesisVoice 0x978b4e0] Language: zh-CN",  中文(普通话)
//"[AVSpeechSynthesisVoice 0x978b530] Language: nl-BE",
//"[AVSpeechSynthesisVoice 0x978b580] Language: en-GB",  英语(英国)
//"[AVSpeechSynthesisVoice 0x978b5d0] Language: ar-SA",
//"[AVSpeechSynthesisVoice 0x978b620] Language: ko-KR",
//"[AVSpeechSynthesisVoice 0x978b670] Language: cs-CZ",
//"[AVSpeechSynthesisVoice 0x978b6c0] Language: en-ZA",
//"[AVSpeechSynthesisVoice 0x978aed0] Language: en-AU",
//"[AVSpeechSynthesisVoice 0x978af20] Language: da-DK",
//"[AVSpeechSynthesisVoice 0x978b810] Language: en-US",  英语(美国)
//"[AVSpeechSynthesisVoice 0x978b860] Language: en-IE",
//"[AVSpeechSynthesisVoice 0x978b8b0] Language: hi-IN",
//"[AVSpeechSynthesisVoice 0x978b900] Language: el-GR",
//"[AVSpeechSynthesisVoice 0x978b950] Language: ja-JP" )
@end
