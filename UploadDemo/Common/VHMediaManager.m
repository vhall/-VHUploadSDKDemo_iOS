//
//  VHMediaManager.m
//  jiaoyou
//
//  Created by 熊超 on 2017/12/27.
//  Copyright © 2017年 . All rights reserved.
//

#import <AVFoundation/AVAssetImageGenerator.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVAsset.h>
#import "VHMediaManager.h"
#import <Photos/Photos.h>  //判断相机/相册权限(iOS8~)


typedef NS_ENUM(NSUInteger, MediaType) {
    MediaType_Photo,
    MediaType_Video,
};

@interface VHMediaManager()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
/** 照片选择控制器 */
@property (nonatomic,strong) UIImagePickerController *imgPickerVC;
/** 视频url路径 */
@property (nonatomic,copy) void(^videoPathBlock)(NSString *videoPath , NSString *videoImgPath);
/** 图片路径 */
@property (nonatomic,copy) void(^photoPathBlock)(NSString *photoPath);
/** 视频某帧图片地址 */
@property (nonatomic,strong) NSString *videoImgPath;
@end


@implementation VHMediaManager

SingletonM

//开始选择照片,回调选择的照片文件路径
-(void)getImageWithType:(MediaFromType)type fromVc:(UIViewController *)viewController result:(void(^)(NSString *))resultBlock{
    self.photoPathBlock = resultBlock;
    if(type == MediaFromType_Camera){ //拍照
        if(![self isGetCameraAuthority:viewController])
        {//没有相机权限
            return ;
        }
        [self presentImgPickerVcWithSourceType:UIImagePickerControllerSourceTypeCamera withVc:viewController withMediaType:MediaType_Photo];
    }else if(type == MediaFromType_Album) {//从相册选取
        if(![self isGetPhotoAuthority:viewController])
        {//没有相册权限
            return ;
        }
        [self presentImgPickerVcWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary withVc:viewController withMediaType:MediaType_Photo];
    }
}

//开始选择视频,回调选择的视频文件路径
-(void)getvideoWithType:(MediaFromType)type fromVc:(UIViewController *)viewController result:(void(^)(NSString *videoPath , NSString *videoImgPath))resultBlock{
    self.videoPathBlock = resultBlock;
    if(type == MediaFromType_Camera){ //拍摄
        if(![self isGetCameraAuthority:viewController])
        {//没有相机权限
            return ;
        }
        [self presentImgPickerVcWithSourceType:UIImagePickerControllerSourceTypeCamera withVc:viewController withMediaType:MediaType_Video];
        
    }else if(type == MediaFromType_Album) {//从相册选取
        if(![self isGetPhotoAuthority:viewController])
        {//没有相册权限
            return ;
        }
        [self presentImgPickerVcWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary withVc:viewController withMediaType:MediaType_Video];
    }
}



-(void)presentImgPickerVcWithSourceType:(UIImagePickerControllerSourceType)sourceType withVc:(UIViewController *)viewController withMediaType:(MediaType)mediaType
{
    UIImagePickerController *imgPickerVc = [[UIImagePickerController alloc]init];
    if([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        imgPickerVc.delegate = self;
        imgPickerVc.navigationBar.tintColor = [UIColor whiteColor];
        imgPickerVc.sourceType = sourceType;
        // 产生的媒体文件是否可进行编辑
        imgPickerVc.allowsEditing = YES;
        if(mediaType == MediaType_Video){ //视频
            //设置mediaTypes录制的类型 为视频
            imgPickerVc.mediaTypes = @[(NSString*)kUTTypeMovie];
            //视频时长（系统默认10分钟），设置为120分钟
            imgPickerVc.videoMaximumDuration = 10 * 60 * 12;
            //设置摄像头模式（拍照，录制视频）
            //            imgPickerVc.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
            // 录像质量
            imgPickerVc.videoQuality = UIImagePickerControllerQualityTypeHigh;
        }else { //照片
            imgPickerVc.mediaTypes = @[(NSString*)kUTTypeImage];
            //            imgPickerVc.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        }
        imgPickerVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [viewController presentViewController:imgPickerVc animated:YES completion:nil];
    }
    self.imgPickerVC = imgPickerVc;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"取消");
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //文件管理器
    NSFileManager* fm = [NSFileManager defaultManager];
    //返回的媒体类型是照片或者视频
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image;
        //如果允许编辑则获得编辑后的照片，否则获取原始照片
        if (picker.allowsEditing) {
            image = [info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
        }else{
            image = [info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        }
        //创建图片的存放路径
        NSString * imgPath = [NSString stringWithFormat:@"%@image%.0f.png", NSTemporaryDirectory(), [NSDate timeIntervalSinceReferenceDate] * 1000];
        NSData *data = UIImageJPEGRepresentation(image,0.5);
        //通过文件管理器将照片存放到创建的路径中
        BOOL result = [fm createFileAtPath:imgPath contents:data attributes:nil];
        
        if(!result){
            NSLog(@"保存照片失败");
        }else {
            NSLog(@"保存照片在本地：%@",imgPath);
            self.photoPathBlock(imgPath);
        }
        //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
        
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        //视频的处理
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        //获取视频第一帧
        UIImage *image = [self thumbnailImageForVideo:videoUrl atTime:1];
        //创建图片的存放路径
        NSString * imgPath = [NSString stringWithFormat:@"%@VideoCoverImage%.0f.png", NSTemporaryDirectory(), [NSDate timeIntervalSinceReferenceDate] * 1000];
        NSData *data = UIImageJPEGRepresentation(image,0.5);
        //通过文件管理器将照片存放到创建的路径中
        BOOL result = [fm createFileAtPath:imgPath contents:data attributes:nil];
        if(!result){
            NSLog(@"保存视频某帧照片失败");
        }else {
            self.videoImgPath = imgPath;
            NSLog(@"保存视频某帧照片在本地成功：%@",imgPath);
        }
        //压缩并保存视频
        [self saveCompressVideo:videoUrl];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark ————————— 压缩并保存视频 —————————————

- (void)saveCompressVideo:(NSURL*)url {
    NSString *prePath = [url path];
    unsigned long long size = [[NSFileManager defaultManager] attributesOfItemAtPath:prePath error:nil].fileSize;
    NSLog(@"压缩之前大小:%.2fM---路径:%@",size/1024.0/1024.0,prePath);
    //使用媒体工具(AVFoundation框架下的)
    //Asset 资源可以是图片音频视频
    AVAsset *asset = [AVAsset assetWithURL:url];
    //设置压缩的格式
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetHighestQuality];//AVAssetExportPresetHighestQuality：高质量 AVAssetExportPresetMediumQuality：中等质量
    //导出路径
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[self getVideoNameBaseCurrentTime]];
    //创建文件管理类导出失败,删除已经导出的
    NSFileManager *manager = [[NSFileManager alloc]init];
    //删除已经存在的
    [manager removeItemAtPath:path error:NULL];
    //设置导出路径
    session.outputURL = [NSURL fileURLWithPath:path];
    //设置输出文件的类型
    session.outputFileType = AVFileTypeMPEG4;
    //开辟子线程处理耗时操作
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        unsigned long long fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
        NSLog(@"压缩导出完成!路径:%@---压缩之后视频大小%.2fM",path,fileSize/1024.0/1024.0);
        if ([session status] == AVAssetExportSessionStatusCompleted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoPathBlock ? self.videoPathBlock(path,self.videoImgPath) : nil;
            });
        }
    }];
    
}


#pragma mark ————————— 以当前时间合成视频名称 —————————————

- (NSString *)getVideoNameBaseCurrentTime {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    return [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@".mp4"];
}


/**
 //获取视频的某一帧图片
 @param videoURL 视频地址(本地/网络)
 @param time 第N帧
 @return 图片
 */
- (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode =AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    // CMTimeMake(a, b)可以理解为第a/b秒
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage:thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

//判断是否拥有相册权限
- (BOOL)isGetPhotoAuthority:(UIViewController *)vc
{
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    if (author == PHAuthorizationStatusRestricted  || author ==PHAuthorizationStatusDenied)
    {
        //无权限
        NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
        NSString*appName =[infoDict objectForKey:@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-照片\"选项中允许%@访问相册",appName];
        // 显示无权限提示
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"没有权限访问相册" message:message preferredStyle:UIAlertControllerStyleAlert];
        // 添加按钮
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            // 去设置界面
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        // 显示控制器
        [vc presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    return YES;
}


//判断是否拥有相机权限
-(BOOL)isGetCameraAuthority:(UIViewController *)vc
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        //无权限
        NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
        NSString*appName =[infoDict objectForKey:@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-相机\"选项中允许%@访问相机",appName];
        // 显示无权限提示
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"没有权限访问相机" message:message preferredStyle:UIAlertControllerStyleAlert];
        // 添加按钮
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            // 去设置界面，开启相机访问权限
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        // 显示控制器
        [vc presentViewController:alert animated:YES completion:nil];
        return NO;
    }else
    {
        return YES;
    }
}

@end

