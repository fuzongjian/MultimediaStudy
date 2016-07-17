//
//  VideoPlayView.h
//  MultimediaStudy
//
//  Created by Shao Jie on 16/7/11.
//  Copyright © 2016年 yourangroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)
//只读属性
@property (nonatomic,readonly) CGPoint bottomLeft;
@property (nonatomic,readonly) CGPoint bottomRight;
@property (nonatomic,readonly) CGPoint topRight;
//可读可写属性
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGFloat width;
/**相当于x属性*/
@property (nonatomic,assign) CGFloat left;
/**相当于y属性*/
@property (nonatomic,assign) CGFloat top;
/**相当于top＋height属性*/
@property (nonatomic,assign) CGFloat bottom;
/**相当于left＋width属性*/
@property (nonatomic,assign) CGFloat right;
@end
typedef NS_ENUM(NSInteger,PlayerState) {
    PlayerStateBuffering,//缓冲
    PlayerStatePlaying,//播放
    PlayerStateStopped,//停止播放
    PlayerStatePause//暂停播放
};
typedef NS_ENUM(NSInteger,PanDirection){
    PlayerStateHorizontalMoved,//水平移动
    PlayerStateVerticalMoved//纵向移动
};
@interface VideoPlayView : UIView

@property (nonatomic,strong) NSString * videoPath;
+ (instancetype)defaultWithFrame:(CGRect)frame;
- (void)pause;
- (void)play;
- (void)exit;
@end
