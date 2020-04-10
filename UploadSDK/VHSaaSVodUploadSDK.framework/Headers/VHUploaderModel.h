//
//  VHUploaderModel.h
//  VHUpload
//
//  Created by vhall on 2019/10/24.
//  Copyright © 2019 vhall. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///文件状态
typedef NS_ENUM(NSInteger,VHUploadFileState) {
    VHUploadFileStatePrepare,  //准备上传
    VHUploadFileStateUploding, //正在上传
    VHUploadFileStateFailed,   //上传失败
    VHUploadFileStateUploded,  //上传成功
};

///点播类型
typedef NS_ENUM(NSInteger,VHVodPlayType) {
    VHVodPlayType_Flash, //flash
    VHVodPlayType_H5, //h5
};

@interface VHVodInfo : NSObject

/** 回放标题（必须设置）*/
@property (nonatomic, copy) NSString *vod_name;
/** 活动标题 (必须设置) */
@property (nonatomic, copy) NSString *activity_name;
/** 设置生成点播视频的类型，如果不设置，默认为flash */
@property (nonatomic, assign) VHVodPlayType vodPlayType;

/** 上传视频后生成的回放id，上传成功的回调里可通过此字段获取 */
@property (nonatomic, copy) NSString *recordsId;
/** 上传视频后生成的活动id，上传成功的回调里可通过此字段获取 */
@property (nonatomic, copy) NSString *webinarId ;

@end

@interface VHUploadFileInfo : NSObject

/**
 文件状态
 */
@property (nonatomic, assign) VHUploadFileState fileState;
/**
 传入的文件路径
 */
@property (nonatomic, copy) NSString *filePath;
/**
 上传文件路径，内部使用
 */
@property (nonatomic, copy) NSString *uploadPath;
/**
 文件类型
 */
@property (nonatomic, copy) NSString *MIMEType;
/**
 文件大小
 */
@property (nonatomic, assign) int64_t totalBytes;
/**
 自定义参数，暂时未使用
 */
@property (nonatomic, strong, nullable) NSDictionary *callbackParam;
/**
 文件MD5
 */
@property (nonatomic, copy) NSString *fileMD5;
/**
 上传信息
 */
@property (nonatomic, strong) VHVodInfo *vodInfo;

@end

///上传SDK Model类
@interface VHUploaderModel : NSObject


/**
 获取文件大小
 @param filePath 文件路径
 @warning error 读取出错回调
 */
+ (unsigned long long)getSizeWithFilePath:(nonnull NSString *)filePath error:(NSError **)error;


@end

NS_ASSUME_NONNULL_END
