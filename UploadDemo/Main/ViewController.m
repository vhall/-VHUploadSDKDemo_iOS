//
//  ViewController.m
//  UploadDemo
//
//  Created by xiongchao on 2020/3/10.
//  Copyright © 2020 vhall. All rights reserved.
//
#import "Macro.h"
#import "MBProgressHUD+JJ.h"
#import "ViewController.h"
#import "VHUploadViewController.h"
#import <VHSaaSVodUploadSDK/VHUploaderClient.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *appKeyTextF;
@property (weak, nonatomic) IBOutlet UITextField *appSecretKeyTextF;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appKeyTextF.text = AppKey;
    self.appSecretKeyTextF.text = SecretKey;
}


- (IBAction)enterBtnClick:(id)sender {
    if(self.appKeyTextF.text.length == 0) {
        [MBProgressHUD showMessage:@"请输入AppKey"];
        return;
    }
    if(self.appSecretKeyTextF.text.length == 0) {
        [MBProgressHUD showMessage:@"请输入SecretKey"];
        return;
    }

    //注册
    [VHUploaderClient registerAppKey:self.appKeyTextF.text appSecretKey:self.appSecretKeyTextF.text];
    //开启日志
    [VHUploaderClient logEnable:YES];
    NSLog(@"VHUploaderClient SDK版本号：%@",[VHUploaderClient getSDKVersion]);
    
    
    VHUploadViewController *uploadVC = [[VHUploadViewController alloc] init];
    uploadVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:uploadVC animated:YES completion:nil];
    
}

@end
