//
//  YPVideoCamera.h
//  视频采集
//
//  Created by 赖永鹏 on 2019/1/22.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface YPVideoCamera : NSObject

@property (nonatomic, strong) AVCaptureSession *captureSession;
/*
 分辨率,帧率,视频原数据,采集视频方向,镜像
 帧率,视频原数据 : outPut
 分辨率: 会话
 采集视频方向,镜像: 连接
 */
@property (nonatomic, strong) NSString *sessionPreset;

// 当采集到每一帧的时候，自动执行block
@property (nonatomic, strong) void(^sampleBufferBlock)(CMSampleBufferRef sampleBuffer);
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;
//开启相机
-(void)startCamera;


@end

NS_ASSUME_NONNULL_END
