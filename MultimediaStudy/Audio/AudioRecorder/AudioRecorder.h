//
//  AudioRecorder.h
//  MultimediaStudy
//
//  Created by Shao Jie on 16/7/7.
//  Copyright © 2016年 yourangroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecordModel.h"
#import "MeterLavel.h"
/**  录音器  */
@protocol AudioRecorderDelegate <NSObject>

@end
@interface AudioRecorder : NSObject
+ (instancetype)defaultRecorderManager;
- (void)startRecorder;
- (void)stopRecorder;
- (void)saveRecorderFileName:(NSString *)fileName completion:(void(^)(BOOL success,id object))completion;
- (void)playRecorder:(RecordModel *)model;

//  meter voice
- (MeterLavel *)meterLevel;
@end
