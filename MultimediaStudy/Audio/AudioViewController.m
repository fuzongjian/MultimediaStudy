//
//  AudioViewController.m
//  MultimediaStudy
//
//  Created by Shao Jie on 16/7/7.
//  Copyright © 2016年 yourangroup. All rights reserved.
//

#import "AudioViewController.h"
#import "AudioReader.h"
#import "AudioRecorder.h"
#import "RecordModel.h"

#import "MeterView.h"

@interface AudioViewController ()<UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIView *voiceLevelView;
@property (weak, nonatomic) IBOutlet UIView *displayView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) AudioRecorder * recorder;
@property (nonatomic,strong) NSMutableArray * dataArray;
@property (nonatomic,strong) UITableView * recorderTableView;
@property (nonatomic,strong) MeterView * meterView;
@property (nonatomic,strong) CADisplayLink * meterTimer;
@end

@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.displayView addSubview:self.recorderTableView];
    self.displayView.backgroundColor = [UIColor grayColor];

}
#pragma mark ---  音频朗读
- (IBAction)startAudioReader:(id)sender {
    [[AudioReader defalutReaderManager] startReaderText:self.contentTextView.text];
}
- (IBAction)pauseAudioReader:(id)sender {
    [[AudioReader defalutReaderManager] pauseReader];
}
- (IBAction)continueAudioReader:(id)sender {
    [[AudioReader defalutReaderManager] continueReader];
}
- (IBAction)stopAudioReader:(id)sender {
    [[AudioReader defalutReaderManager] stopReader];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[AudioReader defalutReaderManager] stopReader];
}

#pragma mark --- 录音
- (IBAction)startOrStopRecord:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {//开始录音
        [self.recorder startRecorder];
        [self.activityIndicator startAnimating];
        
        [self.voiceLevelView addSubview:self.meterView];
        [self startMeterTimer];
    }else{
        [self.recorder stopRecorder];
        [self.activityIndicator stopAnimating];
        [self showChooseView];
        
        [self stopMeterTimer];
    }
}
- (void)showChooseView{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"save?" message:@"give filename" delegate:self cancelButtonTitle:@"cancle" otherButtonTitles:@"sure", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * textField = [alertView textFieldAtIndex:0];
    textField.text = @"录音－01";
    [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString * name = [[alertView textFieldAtIndex:0] text];
        [self.recorder saveRecorderFileName:name completion:^(BOOL success, id object) {
            if (success) {
                [self.dataArray addObject:object];
                [self archive];
                [self.recorderTableView reloadData];
            }
        }];
    }
}
- (void)archive{
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:self.dataArray];
    [data writeToURL:[self archivePath] atomically:YES];
}
- (NSURL *)archivePath{
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * newPath = [path stringByAppendingPathComponent:@"recorder.plist"];
    return [NSURL fileURLWithPath:newPath];
}
#pragma mark --- meter voice
- (void)startMeterTimer{
    [self.meterTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}
-(void)stopMeterTimer{
    [self.meterTimer invalidate];
    self.meterTimer = nil;
    [self.meterView resetMeterLevel];
}
- (void)updateMeter{
    MeterLavel * meterlevel = [self.recorder meterLevel];
    self.meterView.level = meterlevel.level;
    self.meterView.peakLevel = meterlevel.peakLevel;
    [self.meterView setNeedsDisplay];
}
- (CADisplayLink *)meterTimer{
    if (_meterTimer == nil) {
        _meterTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeter)];
        _meterTimer.frameInterval = 5;
    }
    return _meterTimer;
}
#pragma  mark --- UITabelViewDelegate 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    RecordModel * model = self.dataArray[indexPath.row];
    cell.textLabel.text = model.title;
    cell.textLabel.font = [UIFont systemFontOfSize:10];
    cell.detailTextLabel.text = model.dateString;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RecordModel * model = self.dataArray[indexPath.row];
    [self.recorder playRecorder:model];
}
- (AudioRecorder *)recorder{
    if (_recorder == nil) {
        _recorder = [AudioRecorder defaultRecorderManager];
    }
    return _recorder;
}
- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
        NSData * data = [NSData dataWithContentsOfURL:[self archivePath]];
        _dataArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _dataArray;
}
- (UITableView *)recorderTableView{
    if (_recorderTableView == nil) {
        _recorderTableView = [[UITableView alloc] initWithFrame:CGRectMake(2, 2, self.view.bounds.size.width - 14, self.displayView.frame.size.height - 37) style:UITableViewStylePlain];
        _recorderTableView.delegate = self;
        _recorderTableView.dataSource = self;
        _recorderTableView.tableFooterView = [UIView new];
    }
    return _recorderTableView;
}
- (MeterView *)meterView{
    if (_meterView == nil) {
        CGRect bounces = self.voiceLevelView.bounds;
        _meterView = [[MeterView alloc] initWithFrame:CGRectMake(0, 0, bounces.size.width, bounces.size.height - 10)];
    }
    return _meterView;
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
