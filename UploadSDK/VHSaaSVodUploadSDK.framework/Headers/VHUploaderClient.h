//
//  VHUploaderClient.h
//  VHVODUpload
//
//  Created by vhall on 2019/10/22.
//  Copyright © 2019 vhall. All rights reserved.
//

//上传失败回调 VHUploaderClientError Code码：
//10000：上传初始化失败，请检查AppKey或SecretKey正确性
//10001：上传文件路径不能为空
//10002：文件超出了大小限制，禁止上传，普通上传需<5G
//10003：上传临时文件写入失败(准备上传的文件会临时保存一份在沙盒Caches目录，上传成功或失败后会自动删除)
//10004：视频文件上传成功，生成回放失败，请稍后重试
//10005：已取消上传

#import <Foundation/Foundation.h>
#import "VHUploaderModel.h"

@class VHUploaderClient;

NS_ASSUME_NONNULL_BEGIN

/**
 文件上传进度回调
 @param fileInfo     当前上传的文件
 @param uploadedSize 当前已上传段长度
 @param totalSize    一共需要上传的总长度，即当前文件大小
 @warning 上传进度计算：float progress = 1.f * uploadedSize / totalSize;
 */
typedef void (^OnUploadProgressCallback) (VHUploadFileInfo*  _Nullable fileInfo, int64_t uploadedSize, int64_t totalSize);

///上传成功回调
typedef void (^OnUploadSucessCallback) (VHUploadFileInfo* _Nullable fileInfo);

///上传失败回调
typedef void (^OnUploadFailedCallback) (VHUploadFileInfo* _Nullable fileInfo, NSError *error);


///上传SDK 上传类
@interface VHUploaderClient : NSObject

/**
 获取SDK版本号
 */
+ (NSString *)getSDKVersion;


/// 注册，确保在使用之前，任意地方注册一次即可
/// @param appKey appKey  (微吼直播控制台获取AppKey)
/// @param appSecretKey appSecretKey  (微吼直播控制台获取SecretKey(API使用))
+ (void)registerAppKey:(NSString *)appKey appSecretKey:(NSString *)appSecretKey;

/**
 设置日志打印
 */
+ (void)logEnable:(BOOL)enable;


/**
 普通上传 (适合较小文件)
 @param filePath 文件路径，不可为空
 @param vodInfo  文件信息
 @param progressCallback 上传进度回调
 @param successCallback  上传成功回调
 @param failedCallback   上传失败回调
 @warning 异步函数。支持文件大小<5g。上传进度回调是在子线程中，如果有UI处理请注意返回主线程。
 */
- (void)uploadFilePath:(NSString *)filePath
               vodInfo:(VHVodInfo *)vodInfo
              progress:(OnUploadProgressCallback)progressCallback
               success:(OnUploadSucessCallback)successCallback
               failure:(OnUploadFailedCallback)failedCallback;


/**
 断点续传上传 (适合较大文件)
 @param filePath 文件路径，不可为空
 @param vodInfo  文件信息，不可为空
 @param progressCallback 上传进度回调
 @param successCallback  上传成功回调
 @param failedCallback   上传失败回调
 @warning 异步函数。支持文件大小<5g。上传进度回调是在子线程中，如果有UI处理请注意返回主线程。当次上传任务，断网或取消上传后，重新上传时会从上次进度开始上传
 */
- (void)resumableUpload:(NSString *)filePath
                vodInfo:(VHVodInfo *)vodInfo
               progress:(OnUploadProgressCallback)progressCallback
                success:(OnUploadSucessCallback)successCallback
                failure:(OnUploadFailedCallback)failedCallback;


/// 取消上传后，可在上传失败的回调中监听错误回调
- (void)cancelUpload;
@end

NS_ASSUME_NONNULL_END
