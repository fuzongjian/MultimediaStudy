//
//  VideoPlayView.m
//  MultimediaStudy
//
//  Created by Shao Jie on 16/7/11.
//  Copyright © 2016年 yourangroup. All rights reserved.
//

#import "VideoPlayView.h"
#import <AVFoundation/AVFoundation.h>
static VideoPlayView * playView;
@interface VideoPlayView ()<UIGestureRecognizerDelegate>
/**
 *  @brief 播放器
 */
@property (nonatomic,strong) AVPlayer * player;
/**
 *  @brief 播放器的Layer
 */
@property (nonatomic,weak) AVPlayerLayer * playerLayer;
/**
 *  @brief playerItem
 */
@property (nonatomic,weak) AVPlayerItem * playerItem;
/**
 *  @brief 背景图片
 */
@property (nonatomic,strong) UIImageView * bgImageView;
/**
 *  @brief 工具栏
 */
@property (nonatomic,strong) UIView * toolView;
/**
 *  @brief 开始结束按钮
 */
@property (nonatomic,strong) UIButton * startOrStopButton;
/**
 *  @brief 显示时间的滑动条
 */
@property (nonatomic,strong) UISlider * progressSlider;
/**
 *  @brief 缓冲进度条
 */
@property (nonatomic,strong) UIProgressView * progressView;
/**
 *  @brief 是否拖拽进度条
 */
@property (nonatomic,assign) BOOL isDrag;
@property (nonatomic,assign) BOOL isUserPause;
/**
 *  @brief 时间显示
 */
@property (nonatomic,strong) UILabel * startTimeLable;
@property (nonatomic,strong) UILabel * endTimeLable;
/**
 *  @brief 是否大屏播放
 */
@property (nonatomic,strong) UIButton * isBigButton;
/**
 *  @brief 转动加载
 */
@property (nonatomic,strong) UIActivityIndicatorView * activity;
/**
 *  @brief  视屏播放状态
 */
@property (nonatomic,assign) PlayerState playerState;
/**
 *  @brief 拖动方向
 */
@property (nonatomic,assign) PanDirection panDirection;
/**
 *  @brief 正常屏幕/大屏播放
 */
@property (nonatomic,assign) CGRect normalFrame;
@property (nonatomic,assign) CGRect selectedFrame;
/**
 *  @brief 工具栏是否显示
 */
@property (nonatomic,assign) BOOL isShowToolView;
@end
@implementation VideoPlayView
+ (instancetype)defaultWithFrame:(CGRect)frame{
    playView = [[VideoPlayView alloc] initWithFrame:frame];
    return playView;
}
- (void)pause{
    [self.player pause];
}
- (void)play{
    [self.player play];
}
- (void)exit{
//    NSLog(@"---exit");
//    [self.player.currentItem cancelPendingSeeks];
//    [self.player.currentItem.asset cancelLoading];
//    [self.player pause];
//    self.player = nil;
//    self.playerItem = nil;
//    self.playerLayer = nil;
//    [self removeFromSuperview];
    
}
- (instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        self.normalFrame = frame;
        self.selectedFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        self.player = [AVPlayer playerWithURL:[NSURL URLWithString:@""]];
        
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        
        if ([self.playerLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        }else{
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        }
        [self.layer insertSublayer:self.playerLayer atIndex:0];
        
        [self updatePlayTimeAndProgressSlider];
        
        //背景图片添加
        [self addSubview:self.bgImageView];
        
        // 添加手势控制音量、亮度、快进快退（中心偏右音量、中心偏左亮度）
        UIPanGestureRecognizer * pangesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureClicked:)];
        pangesture.delegate = self;
        [self addGestureRecognizer:pangesture];
        //屏幕点击控制工具栏的隐藏或者显示
        UITapGestureRecognizer * tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClicked:)];
        [self addGestureRecognizer:tapgesture];
        //添加工具栏
        [self addSubview:self.toolView];
        
        // 转动加载
        [self addSubview:self.activity];
        
        //应用进入前后台通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
        //监听设备旋转方向
        [self registerListenRotate];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.playerLayer.frame = self.bounds;
    
}
#pragma mark --- 事件处理
// 设置播放时间和进度条
- (void)updatePlayTimeAndProgressSlider{
    __weak __typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        // 有拖拽事件不执行
        if (weakSelf.isDrag) return ;
        
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds([weakSelf.playerItem duration]);
        
        if (current) {
            [weakSelf.progressSlider setValue:(current/total) animated:YES];
        }
        
        //当前时分秒
        NSInteger currentSec = (NSInteger)current % 60;
        NSInteger currentMin = (NSInteger)current / 60 % 60;
        NSInteger currentHou = (NSInteger)current / 60 / 60;
        //总的时分秒
        NSInteger totalSec = (NSInteger)total % 60;
        NSInteger totalMin = (NSInteger)total / 60 % 60;
        NSInteger totalHou = (NSInteger)total / 60 / 60;
        
        weakSelf.startTimeLable.text = [NSString stringWithFormat:@"%02zd:%02zd:%02zd",currentHou,currentMin,currentSec];
        weakSelf.endTimeLable.text = [NSString stringWithFormat:@"%02zd:%02zd:%02zd",totalHou,totalMin,totalSec];
    }];
}
// 开关点击事件
- (void)startOrStopButtonClicked:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.isUserPause = NO;
        [self.player play];
        self.playerState = PlayerStatePlaying;
    }else{
        self.isUserPause = YES;
        [self.player pause];
        self.playerState = PlayerStatePause;
    }
    
}
- (void)isBigButtonClicked:(UIButton *)sender{
    sender.selected = !sender.selected;
    [self interfaceOrientation:(sender.selected == YES)?UIInterfaceOrientationLandscapeRight:UIInterfaceOrientationPortrait];
}
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation{
    // arc下
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}
- (void)tapGestureClicked:(UITapGestureRecognizer *)tap{
    NSLog(@"tapGestureClicked");
    __weak __typeof (self)weakSelf = self;
    if (self.isShowToolView) {
        
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.toolView.frame = CGRectMake(0, self.bounds.size.height - 0.5, self.bounds.size.width, 0.5);
            weakSelf.toolView.alpha = 0.0;
        } completion:^(BOOL finished) {
            weakSelf.isShowToolView = NO;
        }];
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.toolView.frame = CGRectMake(0, self.bounds.size.height - 40, self.bounds.size.width, 40);
            weakSelf.toolView.alpha = 1.0;
        } completion:^(BOOL finished) {
            weakSelf.isShowToolView = YES;
        }];
    }
}
#pragma mark --- slider 方法
- (void)progressSliderTouchBegan:(UISlider *)slider{
    self.isDrag = YES;
}
- (void)progressSliderValueChanged:(UISlider *)slider{
    CGFloat total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
    CGFloat current = total * slider.value;
    //当前时分秒
    NSInteger currentSec = (NSInteger)current % 60;
    NSInteger currentMin = (NSInteger)current / 60 % 60;
    NSInteger currentHou = (NSInteger)current / 60 / 60;
    self.startTimeLable.text = [NSString stringWithFormat:@"%02zd:%02zd:%02zd",currentHou,currentMin,currentSec];
}
//滑动结束视频跳转
- (void)progressSliderTouchEnded:(UISlider *)slider{
    //计算出拖动的当前秒数
    CGFloat total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
    NSInteger dragedSec = floorf(total*slider.value);
    //转换成CMTtime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(dragedSec, 1);
    
    //视频跳转
    [self.player pause];
    [self.activity startAnimating];
    __weak __typeof(self) weakSelf = self;
    [self.player seekToTime:dragedCMTime completionHandler:^(BOOL finished) {
        [weakSelf.activity stopAnimating];
        if (weakSelf.isUserPause) {
            weakSelf.isDrag = NO;
            return ;
        }
        if (weakSelf.progressView.progress - weakSelf.progressSlider.value > 0.01) {
            [weakSelf.activity stopAnimating];
            [weakSelf.player play];
        }else{
            [weakSelf bufferingMethod];
        }
        weakSelf.isDrag = NO;
    }];
    
    NSLog(@"progressSliderTouchEnded%.2f",slider.value);
}
- (void)panGestureClicked:(UIPanGestureRecognizer *)pan{
    NSLog(@"patGestureClicked");
    //响应水平与垂直方向上的移动
    //根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
    //判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            //使用绝对值来判断移动方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) {//水平移动
                self.panDirection = PlayerStateHorizontalMoved;
                self.isDrag = YES;
            }else if (x < y){//垂直移动
                self.panDirection = PlayerStateVerticalMoved;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{//移动过程中
            switch (self.panDirection) {
                case PlayerStateHorizontalMoved:{
                    self.progressSlider.value += veloctyPoint.x / 10000;//播放进度调节
                    [self progressSliderValueChanged:self.progressSlider];
                    break;
                }
                case PlayerStateVerticalMoved:{
#warning 垂直方向音量调节
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{
            //移动结束也需要判断垂直或者平移
            //如水平移动结束时，要快进到指定位置，如果没有判断的话，当我们音量调节完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case PlayerStateHorizontalMoved:{
                    [self progressSliderTouchEnded:self.progressSlider];
                    break;
                }
                case PlayerStateVerticalMoved:{
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}


#pragma mark --- 通知方法
// 播放完成方法
- (void)videoPlayDidEnd:(NSNotification *)notify{
    __weak __typeof(self)weakSelf = self;
    [self.player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finished) {
        [weakSelf.progressSlider setValue:0.0 animated:YES];
        weakSelf.startTimeLable.text = @"00:00:00";
//        weakSelf.bgImageView.hidden = NO;
    }];
    self.playerState = PlayerStateStopped;
    self.startOrStopButton.selected = NO;
}
//应用退到后台
- (void)applicationDidEnterBackground{
    [self.player pause];
}
//应用回到前台
- (void)applicationDidEnterPlayGround{
    if (self.playerState == PlayerStatePlaying) {
        [self.player play];
    }
}
- (void)onDeviceOrientationChange{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        self.frame = self.normalFrame;
        [self customLayoutSubviews];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        self.frame = self.selectedFrame;
        [self customLayoutSubviews];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}
- (void)customLayoutSubviews{
    _toolView.frame = CGRectMake(0, self.bounds.size.height - 40, self.bounds.size.width, 40);
    _startOrStopButton.frame = CGRectMake(12.5, 12.5, 15, 15);
    _startTimeLable.frame = CGRectMake(self.startOrStopButton.right + 10, 25, 70, 15);
    _isBigButton.frame = CGRectMake(self.toolView.width - (12.5 + 15), 12.5, 15, 15);
    _progressSlider.frame = CGRectMake(self.startOrStopButton.right + 10, 5, self.isBigButton.left - self.startOrStopButton.right - (10 + 10), 15);
    _progressView.frame = CGRectMake(0, 0, self.isBigButton.left - self.startOrStopButton.right - (10 + 10 + 3), (15));
    _progressView.center = self.progressSlider.center;
    _endTimeLable.frame = CGRectMake(self.isBigButton.left - (10 + 70), (25), (70), (15));
    _activity.center = CGPointMake(self.width/2, self.height/2);
}
#pragma mark --- 监听设备旋转方向
- (void)registerListenRotate{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}
#pragma mark --- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"status"]) {//准备状态
            if (self.player.status == AVPlayerStatusReadyToPlay) {
//                NSLog(@"即将播放");
                self.bgImageView.hidden = YES;
                [self.activity stopAnimating];
                self.playerState = PlayerStatePlaying;
            }else if (self.player.status == AVPlayerStatusFailed){
//                NSLog(@"稍等");
                [self.activity startAnimating];
                
            }
        }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){//视频缓冲
//            NSLog(@"获得缓冲进度");
            NSTimeInterval timeInterval = [self getAvailableDuration];//计算缓冲进度
            CMTime duration = self.playerItem.duration;
            CGFloat totalDuration = CMTimeGetSeconds(duration);
            [self.progressView setProgress:timeInterval / totalDuration animated:NO];
        }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){//当缓冲区为空时
            if (self.playerItem.playbackBufferEmpty) {
//                NSLog(@"当缓冲区为空时,进入缓冲");
                [self bufferingMethod];
                self.playerState = PlayerStateBuffering;
            }
        }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){//缓冲好进入播放
            if (self.playerItem.playbackLikelyToKeepUp) {
//                NSLog(@"缓冲好进入播放");
                self.playerState = PlayerStatePlaying;
            }
        }
    }
}
//缓冲进度
- (NSTimeInterval)getAvailableDuration{
    NSArray * loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];//获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    return startSeconds + durationSeconds;//返回计算缓冲总进度
}
//当缓冲区为空的时候，进行缓冲、显示缓冲动画
- (void)bufferingMethod{
    [self.activity startAnimating];
    //playbackBufferEmpty 会反复进入，因此在调用bufferingMethod延时播放执行之前再调用bufferingMethod都忽略
    static BOOL isBuffering = NO;
    if (isBuffering) return;
    isBuffering = YES;
    //缓冲的时候暂停一会儿，否则网络状态不好的时候时间在走，声音播放不出来
    [self.player pause];
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.isUserPause) {// 如果用户暂停，此时不需要再开启播放了
            isBuffering = NO;
            return ;
        }
        // 如果执行了play还是没有播放则说明还没有缓冲好，则需要再次缓冲一段时间
        isBuffering = NO;
        //如果缓冲一段时间后，则进行播放，否则继续播放
        if ((weakSelf.progressView.progress - weakSelf.progressSlider.value) > 0.01) {
            [weakSelf.player play];
            weakSelf.playerState = PlayerStatePlaying;
            [weakSelf.activity stopAnimating];
        }else{
            [weakSelf bufferingMethod];
        }
    });
}
#pragma mark --- setter方法
- (void)setVideoPath:(NSString *)videoPath{
    // 移除之前的监听
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    self.playerItem = nil;
    
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:videoPath]];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
    //AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    // 监听播放状态
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    //监听loadedTimeRanges属性
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    // Will warn you when your buffer is empty
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    // Will warn you when your buffer is good to go again.
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.player play];
    self.startOrStopButton.selected = YES;
    [self.activity startAnimating];
    
}
-(void)dealloc
{
    
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    self.playerItem = nil;
    self.playerLayer = nil;
    [self.toolView removeFromSuperview];
    self.toolView = nil;
    
    NSLog(@"---%s",__func__);
    
}
#pragma mark ---  懒加载
- (UIImageView *)bgImageView{
    if (_bgImageView == nil) {
        _bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _bgImageView.image = [UIImage imageNamed:@"loading_bgView"];
    }
    return _bgImageView;
}
- (UIView *)toolView{
    if (_toolView == nil) {
        _toolView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - (40), self.frame.size.width, (40))];
        _toolView.backgroundColor = [UIColor grayColor];
        
        
        // 开关
        [_toolView addSubview:self.startOrStopButton];
        
        //开始时间
        [_toolView addSubview:self.startTimeLable];
        
        //大屏小屏
        [_toolView addSubview:self.isBigButton];
        
        //滑动条
        [_toolView addSubview:self.progressSlider];
        
        //进度条
        [_toolView addSubview:self.progressView];
        
        // 结束时间
        [_toolView addSubview:self.endTimeLable];
        
        //默认工具栏显示
        self.isShowToolView = YES;
        
    }
    return _toolView;
}
- (UIButton *)startOrStopButton{
    if (_startOrStopButton == nil) {
        _startOrStopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _startOrStopButton.frame = CGRectMake((12.5), (12.5), (15), (15));
        [_startOrStopButton setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_startOrStopButton setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
        [_startOrStopButton addTarget:self action:@selector(startOrStopButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startOrStopButton;
}
- (UILabel *)startTimeLable{
    if (_startTimeLable == nil) {
        _startTimeLable =[[UILabel alloc] initWithFrame:CGRectMake(self.startOrStopButton.right + (10), (25), (70), (15))];
        _startTimeLable.text = @"00:00:00";
        _startTimeLable.textColor = [UIColor whiteColor];
        _startTimeLable.textAlignment = NSTextAlignmentCenter;
        _startTimeLable.font = [UIFont systemFontOfSize:(15)];
    }
    return _startTimeLable;
    
}
- (UIButton *)isBigButton{
    if (_isBigButton == nil) {
        _isBigButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _isBigButton.frame = CGRectMake(self.toolView.width - (12.5 + 15), (12.5), (15), (15));
        [_isBigButton setBackgroundImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateSelected];
        [_isBigButton setBackgroundImage:[UIImage imageNamed:@"shrinkscreen"] forState:UIControlStateNormal];
        [_isBigButton addTarget:self action:@selector(isBigButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _isBigButton;
}
- (UILabel *)endTimeLable{
    if (_endTimeLable == nil) {
        _endTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(self.isBigButton.left - (10 + 70), (25), (70), (15))];
        _endTimeLable.textAlignment = NSTextAlignmentCenter;
        _endTimeLable.font = [UIFont systemFontOfSize:(15)];
        _endTimeLable.textColor = [UIColor whiteColor];
        _endTimeLable.text = @"00:00:00";
    }
    return _endTimeLable;
}
- (UISlider *)progressSlider{
    if (_progressSlider == nil) {
        _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(self.startOrStopButton.right + (10), (5), self.isBigButton.left - self.startOrStopButton.right - (10 + 10), (15))];
        _progressSlider.minimumValue = 0.0;
        _progressSlider.maximumValue = 1;
        [_progressSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
        _progressSlider.minimumTrackTintColor = [UIColor whiteColor];
        _progressSlider.maximumTrackTintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
        [_progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        [_progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchCancel|UIControlEventTouchUpOutside];
    }
    return _progressSlider;
}
- (UIProgressView *)progressView{
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.isBigButton.left - self.startOrStopButton.right - (10 + 10 + 3), (15))];
        _progressView.center = self.progressSlider.center;
        _progressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
        _progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressView;
}
- (UIActivityIndicatorView *)activity{
    if (_activity == nil) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activity.frame = CGRectMake(0, 0, 30, 30);
        _activity.center = CGPointMake(self.width/2, self.height/2);
        _activity.hidesWhenStopped = YES;
    }
    return _activity;
}
@end












#pragma mark --- 分类
@implementation UIView (Extension)
// 可读属性的实现
- (CGPoint) bottomRight
{
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint) bottomLeft
{
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint) topRight
{
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y;
    return CGPointMake(x, y);
}
// 可读可写的属性实现
- (CGFloat) height
{
    return self.frame.size.height;
}

- (void) setHeight: (CGFloat) newheight
{
    CGRect newframe = self.frame;
    newframe.size.height = newheight;
    self.frame = newframe;
}

- (CGFloat) width
{
    return self.frame.size.width;
}

- (void) setWidth: (CGFloat) newwidth
{
    CGRect newframe = self.frame;
    newframe.size.width = newwidth;
    self.frame = newframe;
}

- (CGFloat) top
{
    return self.frame.origin.y;
}

- (void) setTop: (CGFloat) newtop
{
    CGRect newframe = self.frame;
    newframe.origin.y = newtop;
    self.frame = newframe;
}


- (CGFloat) left
{
    return self.frame.origin.x;
}

- (void) setLeft: (CGFloat) newleft
{
    CGRect newframe = self.frame;
    newframe.origin.x = newleft;
    self.frame = newframe;
}

- (CGFloat) bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void) setBottom: (CGFloat) newbottom
{
    CGRect newframe = self.frame;
    newframe.origin.y = newbottom - self.frame.size.height;
    self.frame = newframe;
}

- (CGFloat) right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void) setRight: (CGFloat) newright
{
    CGFloat delta = newright - (self.frame.origin.x + self.frame.size.width);
    CGRect newframe = self.frame;
    newframe.origin.x += delta ;
    self.frame = newframe;
}

@end

