# 微吼点播上传SDK，支持生成flash和h5的点播


## 目录结构
UploadDemo         demo示例
UploadSDK           微吼点播上传SDK库文件

### framework
`VHSaaSVodUploadSDK.framework`         点播上传SDK



## 版本记录

### 版本v1.0.0
1、上传点播视频支持flash和h5
2、上传方式含普通上传与断点续传



## 使用说明

将`VHSaaSVodUploadSDK.framework`导入到项目中
项目设置：Enable Bitcode 设置为NO
info.plist配置相机、相册权限

## 报错处理

1、Reason: image not found
```
dyld: Library not loaded: @rpath/VHSaaSVodUploadSDK.framework/VHSaaSVodUploadSDK
  Referenced from: /private/var/containers/Bundle/Application/94C43BE1-82F3-4547-8982-923F7044CD99/微吼直播 Upload.app/微吼直播 Upload
  Reason: image not found
```
在`TARGET->General->Frameworks, Libraries, and Embedded Content`下将`VHSaaSVodUploadSDK` Embed设置为`Embed & Sign`。


导入头文件`<VHSaaSVodUploadSDK/VHUploaderClient.h>`即可使用，使用详情见Demo。

1、初始化SDK （请确保在使用之前初始化一次即可）

```
/// 注册，确保在使用之前，任意地方注册一次即可
/// @param appKey appKey  (微吼直播控制台获取AppKey)
/// @param appSecretKey appSecretKey  (微吼直播控制台获取SecretKey(API使用))
+ (void)registerAppKey:(NSString *)appKey appSecretKey:(NSString *)appSecretKey;
```

2、初始化上传对象

```
_uploder = [[VHUploaderClient alloc] init];
```

3、普通上传
```
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
```

4、断点续传
```
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
```


## 注意事项

* 单文件上传大小限制<5G

* 文件不大的话使用普通上传即可

* 文件较大的话可使用断点续传



