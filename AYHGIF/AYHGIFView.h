//
//  AYHGIFView.h
//  AYHGIF
//
//  Created by alimysoyang on 15-2-4.
//  Copyright (c) 2015年 alimysoyang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum:NSUInteger
{
    kGIFPlay,
    kGIFPause,
    kGIFStop
} GIFStatus;

@interface AYHGIFView : UIView

@property (assign, nonatomic, readonly) CGSize gifSize;
@property (readonly, nonatomic) GIFStatus gifStatus;

- (id) initWithFrame:(CGRect)frame ContentsOfFile:(NSString *)path;
- (id) initWithFrame:(CGRect)frame Data:(NSData *) data;

/**
 *  播放GIF，无限循环播放
 */
- (void) play;
/**
 *  暂停播放GIF
 */
- (void) pause;
/**
 *  停止播放GIF
 */
- (void) stop;

@end
