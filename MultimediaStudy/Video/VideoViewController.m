//
//  VideoViewController.m
//  MultimediaStudy
//
//  Created by Shao Jie on 16/7/7.
//  Copyright © 2016年 yourangroup. All rights reserved.
//

#import "VideoViewController.h"
#import "VideoPlayView.h"
@interface VideoViewController ()
@property (nonatomic,strong) VideoPlayView * playView;
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    VideoPlayView * playView = [VideoPlayView defaultWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200)];
    playView.videoPath = @"http://baobab.wdjcdn.com/1455782903700jy.mp4";
    self.playView = playView;
    [self.view addSubview:playView];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.playView exit];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
//    [self.playView removeFromSuperview];
//    self.playView = nil;
}




- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        
//        self.navigationController.navigationBar.hidden = NO;
//        [UIApplication sharedApplication].statusBarHidden = NO;
        self.view.backgroundColor = [UIColor whiteColor];
        
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
//        self.navigationController.navigationBar.hidden = YES;
//        [UIApplication sharedApplication].statusBarHidden = YES;
        self.view.backgroundColor = [UIColor blackColor];
        
    }
}
// 哪些页面支持自动转屏
- (BOOL)shouldAutorotate{
    NSLog(@"shouldAutorotate");
    return YES;
}

// viewcontroller支持哪些转屏方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    NSLog(@"supportedInterfaceOrientations");
    // MoviePlayerViewController这个页面支持转屏方向
    return UIInterfaceOrientationMaskAllButUpsideDown;
    
}
- (void)dealloc{
    NSLog(@"%s",__func__);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
