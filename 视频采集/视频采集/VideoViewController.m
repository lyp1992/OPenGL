//
//  VideoViewController.m
//  视频采集
//
//  Created by 赖永鹏 on 2019/1/22.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import "VideoViewController.h"
#import "YPVideoTool/YPVideoCamera.h"
#import "YPVideoTool/OpenGLView.h"

@interface VideoViewController ()

@property (nonatomic, strong) YPVideoCamera *videoCamera;
@property (nonatomic, strong) UIImageView *imageV;
@property (nonatomic, strong) OpenGLView *openGLView;

@end

@implementation VideoViewController

-(UIImageView *)imageV{
    if (!_imageV) {
        _imageV = [[UIImageView alloc]initWithFrame:self.view.bounds];
        [self.view addSubview:_imageV];
    }
    return _imageV;
}

-(OpenGLView *)openGLView{
    if (!_openGLView) {
        _openGLView = [[OpenGLView alloc]initWithFrame:self.view.bounds];
        [self.view addSubview:_openGLView];
    }
    return _openGLView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self openGLView];
    
    NSLog(@"%@",[self.openGLView.layer class]);
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.videoCamera = [[YPVideoCamera alloc]init];
    self.videoCamera.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
//    获取帧数据
    __weak typeof(self) weakSelf = self;
    [self.videoCamera setSampleBufferBlock:^(CMSampleBufferRef  _Nonnull sampleBuffer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
//        [strongSelf processWithSampleBuffer:sampleBuffer];
        [strongSelf.openGLView processWithSampleBuffer:sampleBuffer];
    }];
    
    [self.videoCamera startCamera];
    
    [self imageV];
}

-(void)processWithSampleBuffer:(CMSampleBufferRef)sampleBuffer{
//    NSLog(@"%@",sampleBuffer);
    
//   1. 获取帧数据
    CVImageBufferRef imagebuf = CMSampleBufferGetImageBuffer(sampleBuffer);
//    2.将帧数据转成CIimage
    CIImage *cvimage = [CIImage imageWithCVImageBuffer:imagebuf];
    
    EAGLContext *ctx = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    CIContext *context = [CIContext contextWithEAGLContext:ctx];
    CGImageRef imageRef = [context createCGImage:cvimage fromRect:cvimage.extent];
    
//    UIImage *image = [UIImage imageWithCIImage:cvimage];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        self.imageV.image = image;
    });
}

@end
