//
//  AudioReader.h
//  MultimediaStudy
//
//  Created by Shao Jie on 16/7/7.
//  Copyright © 2016年 yourangroup. All rights reserved.
//

#import <Foundation/Foundation.h>
/**   朗读器   */
@interface AudioReader : NSObject
//项目中只允许有一个朗读器
+ (instancetype)defalutReaderManager;
- (void)startReaderText:(NSString *)content;//开始
- (void)pauseReader;//暂停
- (void)stopReader;//停止
- (void)continueReader;//继续
@end
