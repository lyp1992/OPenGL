//
//  YPVideoCamera.m
//  视频采集
//
//  Created by 赖永鹏 on 2019/1/22.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import "YPVideoCamera.h"

@interface YPVideoCamera ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureConnection *captureConnection;
@end

@implementation YPVideoCamera

- (instancetype)init
{
    self = [super init];
    if (self) {
//        1. 创建回话
        [self createCaptureSession];
//        2.创建输入输出
        [self addVideoInput];
//        3.t添加视频输出
        [self addVideoOutput];
        
    }
    return self;
}


-(void)startCamera{
    [self.captureSession startRunning];
}

-(void)createCaptureSession{
    AVCaptureSession *captureS = [[AVCaptureSession alloc]init];
    self.captureSession = captureS;
    self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
}
-(void)addVideoInput{
    //    2.1 获取摄像头
    AVCaptureDevice *videoDevice = [self deviceWithPosition:AVCaptureDevicePositionFront];
    //    2.2 设置输入对象
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    
    //    2.3 给回话添加输入
    if ([self.captureSession canAddInput:videoInput]) {
        
        [self.captureSession addInput:videoInput];
    }
}

-(void)addVideoOutput{
    // 苹果不支持YUA渲染,只支持RGB渲染 -> YUV => RGB
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc]init];
    
    //    设置帧率 1秒多少帧
    videoOutput.minFrameDuration = CMTimeMake(1, 10);
    
    // videoSettings:设置视频原数据格式 YUV FULL
    videoOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
    
    //    3.1 设置代理:获取帧数据
    // 队列:串行
    dispatch_queue_t queue = dispatch_queue_create("SERIAL", DISPATCH_QUEUE_SERIAL);
    [videoOutput setSampleBufferDelegate:self queue:queue];
    
    
    //    3.2 给回话添加输出对象
    if ([self.captureSession canAddOutput:videoOutput]) {
        [self.captureSession addOutput:videoOutput];
    }
    
    //   3.3 获取数据输入输出连接
    AVCaptureConnection *captureConnection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
    //    设置采集数据的方向，镜像
    captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    captureConnection.videoMirrored = YES;
    captureConnection.automaticallyAdjustsVideoMirroring = NO;
    _captureConnection = captureConnection;
}
- (void)setVideoOrientation:(AVCaptureVideoOrientation)videoOrientation
{
    _videoOrientation = videoOrientation;
    _captureConnection.videoOrientation = _videoOrientation;
}
-(AVCaptureDevice *)deviceWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

// 获取帧数据
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (_sampleBufferBlock) {
        _sampleBufferBlock(sampleBuffer);
    }
    
}


@end
