
//
//  VHUploadViewController.m
//  UploadDemo
//
//  Created by xiongchao on 2020/3/11.
//  Copyright © 2020 vhall. All rights reserved.
//

#import "MBProgressHUD+JJ.h"
#import "VHUploadViewController.h"
#import "VHMediaManager.h"
#import <VHSaaSVodUploadSDK/VHUploaderClient.h>

@interface VHUploadViewController () <UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSArray *_uploadModeArr;
}
/** 生成类型 0：flash  1：h5 */
@property (nonatomic, assign) NSInteger vodType;
/** 上传进度 */
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
/** 进度值显示*/
@property (weak, nonatomic) IBOutlet UILabel *progressLab;
/** 回放名称 */
@property (weak, nonatomic) IBOutlet UITextField *vodNameTextF;
/** 活动名称 */
@property (weak, nonatomic) IBOutlet UITextField *activityNameTextF;
/** 视频封面 */
@property (weak, nonatomic) IBOutlet UIImageView *videoCoverImgView;
/** 上传结果 */
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
/** 上传方式 */
@property (weak, nonatomic) IBOutlet UIPickerView *uploadModePickerView;
/** 上传方式选择结果 0：普通上传 1：断点续传*/
@property (nonatomic, assign) NSInteger uploadModeType;

/** 选取的视频沙盒路径 */
@property (nonatomic, copy) NSString *videoPath;

/** 上传管理类 */
@property (nonatomic, strong) VHUploaderClient *uploder;
@end


@implementation VHUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.vodType = 0;
    self.uploadModeType = 0;
    _uploadModeArr = @[@"普通上传",@"断点续传"];
    self.vodNameTextF.text = @"这是回放名称";
    self.activityNameTextF.text = @"这是活动名称";
}


- (BOOL)canUpload {
    if(self.videoPath.length == 0) {
        [MBProgressHUD showMessage:@"请选择视频"];
        return NO;
    }

    if(self.vodNameTextF.text.length == 0) {
        [MBProgressHUD showMessage:@"请输入回放名称"];
        return NO;
    }

    if(self.activityNameTextF.text.length == 0) {
        [MBProgressHUD showMessage:@"请输入活动名称"];
        return NO;
    }
    return YES;
}


//选择视频
- (IBAction)selectVideoBtnClick:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"上传" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //兼容iPad
    alert.popoverPresentationController.sourceView = sender;
    alert.popoverPresentationController.sourceRect = sender.bounds;
    
    [alert addAction:[UIAlertAction actionWithTitle:@"选择视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getVideoFrom:MediaFromType_Album];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getVideoFrom:MediaFromType_Camera];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    alert.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:alert animated:YES completion:nil];
}

//生成点播类型选择
- (IBAction)vodTypeSelect:(UISegmentedControl *)sender {
    self.vodType = sender.selectedSegmentIndex;
}


//开始上传
- (IBAction)startUploadBtnClick:(UIButton *)sender {
    if(![self canUpload]) {
        return;
    }
    //测试代码
//    self.videoPath = [[NSBundle mainBundle] pathForResource:@"40s" ofType:@".mp4"];
//    [MBProgressHUD showActivityMessage:@"上传中"];
    sender.enabled = NO;
    __weak typeof(self) weakSelf = self;
    VHVodInfo *info = [[VHVodInfo alloc] init];
    info.vodPlayType = self.vodType == 0 ? VHVodPlayType_Flash : VHVodPlayType_H5;
    info.vod_name = self.vodNameTextF.text;
    info.activity_name = self.activityNameTextF.text;
    
    if(self.uploadModeType == 0) { //普通上传
        [self.uploder uploadFilePath:self.videoPath vodInfo:info progress:^(VHUploadFileInfo * _Nullable fileInfo, int64_t uploadedSize, int64_t totalSize) {
            //主线程刷新progress
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.progressView.progress = 1.f * uploadedSize / totalSize;
                weakSelf.progressLab.text = [NSString stringWithFormat:@"%.2f",weakSelf.progressView.progress];
            });
        } success:^(VHUploadFileInfo * _Nullable fileInfo) {
            [MBProgressHUD showMessage:@"上传成功"];
            self.resultTextView.text = [NSString stringWithFormat:@"点播id：%@\n活动id：%@",fileInfo.vodInfo.recordsId,fileInfo.vodInfo.webinarId];
            sender.enabled = YES;
        } failure:^(VHUploadFileInfo * _Nullable fileInfo, NSError * _Nonnull error) {
            NSLog(@"error.localizedDescription：%@",error.localizedDescription);
            [MBProgressHUD showMessage:error.localizedDescription];
            sender.enabled = YES;
        }];
    }else { //断点续传
        [self.uploder resumableUpload:self.videoPath vodInfo:info progress:^(VHUploadFileInfo * _Nullable fileInfo, int64_t uploadedSize, int64_t totalSize) {
            //主线程刷新progress
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.progressView.progress = 1.f * uploadedSize / totalSize;
                weakSelf.progressLab.text = [NSString stringWithFormat:@"%.2f",weakSelf.progressView.progress];
            });
        } success:^(VHUploadFileInfo * _Nullable fileInfo) {
            [MBProgressHUD showMessage:@"上传成功"];
            self.resultTextView.text = [NSString stringWithFormat:@"点播id：%@\n活动id：%@",fileInfo.vodInfo.recordsId,fileInfo.vodInfo.webinarId];
            sender.enabled = YES;
        } failure:^(VHUploadFileInfo * _Nullable fileInfo, NSError * _Nonnull error) {
            NSLog(@"error.localizedDescription：%@",error.localizedDescription);
            [MBProgressHUD showMessage:error.localizedDescription];
            sender.enabled = YES;
        }];
    }
}


//取消上传
- (IBAction)cancelUpload:(UIButton *)sender {
    [self.uploder cancelUpload];
}

//返回按钮
- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _uploadModeArr.count;
}

//列显示的数据
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger) row forComponent:(NSInteger)component {
    return _uploadModeArr[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.uploadModeType = row;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)getVideoFrom:(MediaFromType)fromType {
    [[VHMediaManager sharedInstance] getvideoWithType:fromType fromVc:self result:^(NSString *videoPath, NSString *videoImgPath) {
        NSLog(@"沙盒视频路径%@---视频某帧图片路径%@",videoPath,videoImgPath);
        
        self.videoPath = videoPath;
        self.videoCoverImgView.image = [UIImage imageWithContentsOfFile:videoImgPath];
        
    }];
}

- (VHUploaderClient *)uploder
{
    if (!_uploder)
    {
        _uploder = [[VHUploaderClient alloc] init];
    }
    return _uploder;
}
@end
