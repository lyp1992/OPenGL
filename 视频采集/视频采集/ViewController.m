//
//  ViewController.m
//  视频采集
//
//  Created by 赖永鹏 on 2019/1/16.
//  Copyright © 2019年 LYP. All rights reserved.
//

/**
  AVFoundation 的几个类
 AVCaptureDevice ： 摄像头，麦克风
 AVCaptureInput： 输入
 AVCaptureOutput：输出
 AVCaptureSession：管理输入输出数据流
 AVCaptureVideoPreviewLayer：展示采集 预览view
 
 **/

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) UIImageView *imageV;

@end

@implementation ViewController

-(UIImageView *)imageV{
    if (!_imageV) {
        _imageV = [[UIImageView alloc]initWithFrame:self.view.bounds];
        [self.view addSubview:_imageV];
    }
    return _imageV;
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
}

-(void)createPreviewLayer{
    AVCaptureVideoPreviewLayer *videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    videoPreviewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:videoPreviewLayer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//  1.创建回话，设置分辨率
    [self createCaptureSession];
    
//    2.建立输入输出通道
    [self addVideoInput];
    
    // 3 视频输出:设置视频原数据格式:YUV,RGB YUV
    [self addVideoOutput];
    
//    4 开启会话
    [self.captureSession startRunning];
    
//    5 采集的数据显示
    [self createPreviewLayer];
    
    [self imageV];
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
    // 把这个数据渲染出来 显示
//    NSLog(@"%@",sampleBuffer);
    
//    1.获取帧图片数据
    CVImageBufferRef imageBuf = CMSampleBufferGetImageBuffer(sampleBuffer);
//    2.将帧图片数据转成CIimage
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:imageBuf];
    
////    opGL 上下文
//    EAGLContext *ctx = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
////    coreImage 上下文
//    CIContext *context = [CIContext contextWithEAGLContext:ctx];
////                       CGImage
////    ciImage.extent 获取图片尺寸 GPU 生成一张图片
//    CGImageRef imageRef = [context createCGImage:ciImage fromRect:ciImage.extent];
    
    CIFilter *filter = [CIFilter filterWithName:@"CINoiseReduction"];
    [filter setValue:ciImage forKey:@"inputImage"];
    ciImage = filter.outputImage;
    
//    3. 转成UIimage
    UIImage *image = [UIImage imageWithCIImage:ciImage];
//    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageV.image = image;
        
    });
    
}

/**
 GPU 显存：OpenGL
 **/

@end
