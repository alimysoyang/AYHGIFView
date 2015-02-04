//
//  AYHGIFView.m
//  AYHGIF
//
//  Created by alimysoyang on 15-2-4.
//  Copyright (c) 2015年 alimysoyang. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AYHGIFView.h"

@interface AYHGIFView()
{
    CGImageSourceRef gifSource;
}

@property (assign, nonatomic) NSUInteger numberOfFrames;
@property (readwrite, nonatomic) NSTimeInterval *frameDurations;
@property (assign, nonatomic) NSTimeInterval totalDuration;
@property (assign, nonatomic) size_t frameIndex;

@property (assign, nonatomic) BOOL isPause;
@property (assign, nonatomic) BOOL isStop;

@end

@implementation AYHGIFView

inline static NSTimeInterval CGImageSourceGetGifFrameDelay(CGImageSourceRef imageSource, NSUInteger index)
{
    NSTimeInterval frameDuration = 0;
    CFDictionaryRef theImageProperties;
    if ((theImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL))) {
        CFDictionaryRef gifProperties;
        if (CFDictionaryGetValueIfPresent(theImageProperties, kCGImagePropertyGIFDictionary, (const void **)&gifProperties)) {
            const void *frameDurationValue;
            if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFUnclampedDelayTime, &frameDurationValue)) {
                frameDuration = [(__bridge NSNumber *)frameDurationValue doubleValue];
                if (frameDuration <= 0) {
                    if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFDelayTime, &frameDurationValue)) {
                        frameDuration = [(__bridge NSNumber *)frameDurationValue doubleValue];
                    }
                }
            }
        }
        CFRelease(theImageProperties);
    }
    
#ifndef OLExactGIFRepresentation
    if (frameDuration < 0.02 - FLT_EPSILON) {
        frameDuration = 0.1;
    }
#endif
    return frameDuration;
}

- (id) initWithFrame:(CGRect)frame ContentsOfFile:(NSString *)path
{
    return [self initWithFrame:frame Data:[NSData dataWithContentsOfFile:path]];
}

- (id) initWithFrame:(CGRect)frame Data:(NSData *)data
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.frameIndex = 0;
        self.isPause = NO;
        self.isStop = NO;
        _gifStatus = kGIFStop;
        UIImage *gifImage = [[UIImage alloc] initWithData:data];
        _gifSize = gifImage.size;
        gifImage = nil;
        
//        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _gifSize.width, _gifSize.height);
        
        gifSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
        //获取GIF的总帧数
        self.numberOfFrames = CGImageSourceGetCount(gifSource);
        //计算GIF每一帧的时长和GIF的总时长
        self.frameDurations = (NSTimeInterval *)malloc(self.numberOfFrames * sizeof(NSTimeInterval));
        for (NSUInteger i = 0;i < self.numberOfFrames;i++)
        {
            NSTimeInterval frameDuration = CGImageSourceGetGifFrameDelay(gifSource, i);
            self.frameDurations[i] = frameDuration;
            self.totalDuration += frameDuration;
        }
    }
    return self;
}

- (void) play
{
    if (self.isStop) return;
    
    _gifStatus = kGIFPlay;
    //获取GIF当前帧的图像，用于显示
    CGImageRef gifImageFrame = CGImageSourceCreateImageAtIndex(gifSource, self.frameIndex, NULL);
    self.layer.contents = (__bridge id)gifImageFrame;
    CFRelease(gifImageFrame);
    
    __weak typeof(self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(wself.frameDurations[wself.frameIndex] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        wself.frameIndex++;
        if (wself.frameIndex >= wself.numberOfFrames)
            wself.frameIndex = 0;
        if (!wself.isPause)
            [wself play];
    });
}

- (void) pause
{
    if (self.isPause)
        [self play];
    else
        _gifStatus = kGIFPause;
    self.isPause = !self.isPause;
}

- (void) stop
{
    self.isStop = YES;
    _gifStatus = kGIFStop;
    self.frameIndex = 0;
}

- (void) dealloc
{
    if (gifSource)
        CFRelease(gifSource);
    free(_frameDurations);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
