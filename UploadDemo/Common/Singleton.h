//
//  Singleton.h
//  cornerios
//
//  Created by 熊超 on 16/9/20.
//  Copyright © 2018年 . All rights reserved.
//

 //便利创建单例,使用时只需在  .h写上SingletonH  .m写上SingletonM
#define SingletonH + (instancetype)sharedInstance;

#define SingletonM \
static id _instance; \
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
\
+ (instancetype)sharedInstance \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return _instance; \
}\
\
- (id)mutableCopyWithZone:(NSZone *)zone { \
return _instance; \
}
