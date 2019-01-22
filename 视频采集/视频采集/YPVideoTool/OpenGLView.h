//
//  OpenGLView.h
//  视频采集
//
//  Created by 赖永鹏 on 2019/1/22.
//  Copyright © 2019年 LYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface OpenGLView : UIView

-(void)processWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

NS_ASSUME_NONNULL_END
