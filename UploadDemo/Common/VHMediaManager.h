//
//  VHMediaManager.h
//  jiaoyou
//
//  Created by 熊超 on 2017/12/27.
//  Copyright © 2017年 . All rights reserved.
//
typedef NS_ENUM(NSUInteger, MediaFromType) {
    MediaFromType_Camera, //拍摄
    MediaFromType_Album, //相册
};

#import <UIKit/UIKit.h>
#import "Singleton.h"
@interface VHMediaManager : NSObject
SingletonH
//选择照片,回调选择的照片文件路径
-(void)getImageWithType:(MediaFromType)type fromVc:(UIViewController *)viewController result:(void(^)(NSString *photoPath))resultBlock;

//选择视频,回调选择的视频文件路径
-(void)getvideoWithType:(MediaFromType)type fromVc:(UIViewController *)viewController result:(void(^)(NSString *videoPath , NSString *videoImgPath))resultBlock;

//判断是否拥有相机权限
-(BOOL)isGetCameraAuthority:(UIViewController *)vc;

//判断是否拥有相册权限
- (BOOL)isGetPhotoAuthority:(UIViewController *)vc;
@end

