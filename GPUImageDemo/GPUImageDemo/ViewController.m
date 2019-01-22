//
//  ViewController.m
//  GPUImageDemo
//
//  Created by 赖永鹏 on 2019/1/21.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImageFramework.h>

@interface ViewController ()

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    1. 创建视频源
    GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    
    self.videoCamera = videoCamera;
    self.videoCamera.outputImageOrientation = AVCaptureVideoOrientationPortrait | AVCaptureVideoOrientationLandscapeLeft | AVCaptureVideoOrientationLandscapeRight | AVCaptureVideoOrientationPortraitUpsideDown;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.horizontallyMirrorRearFacingCamera = YES;
    
//    2. 创建滤镜
    GPUImageBilateralFilter *bilateralFilter = [[GPUImageBilateralFilter alloc]init];
    bilateralFilter.distanceNormalizationFactor = 5;
    
//    3. 创建输入输出
    GPUImageView *imageV = [[GPUImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:imageV];
    
//    4. 设置处理链条
    [self.videoCamera addTarget:bilateralFilter];
    [bilateralFilter addTarget:imageV];
//    5. 开始录制
    [self.videoCamera startCameraCapture];
}


@end
