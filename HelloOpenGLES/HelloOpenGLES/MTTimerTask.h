//
//  MTTimerTask.h
//  HelloOpenGLES
//
//  Created by ZhangXiaoJun on 16/8/23.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <AHEasing/easing.h>


@class MTTimerTask;

@protocol MTTimerTaskDelegate <NSObject>

- (void)timerTaskDidUpdate:(MTTimerTask *)timerTask progress:(CGFloat)progress;
- (void)timerTaskDidComplete:(MTTimerTask *)timerTask;

@end

@interface MTTimerTask : NSObject
{
    CFAbsoluteTime _startTime;
    CFAbsoluteTime _endTTime;
    CADisplayLink *_displayLink;
}

@property (nonatomic, readonly, assign) CFAbsoluteTime duration;

@property (nonatomic, weak) id<MTTimerTaskDelegate> delegate;

@property (nonatomic, assign) NSUInteger refreshRate;

@property (nonatomic, copy) void (^updateCallback)(CGFloat progress);

@property (nonatomic, copy) void (^completion)();

@property (nonatomic, assign) AHEasingFunction easingFunction;

- (instancetype)initWithDuration:(CFAbsoluteTime)duration;

- (void)start;

- (void)stop;

@end
