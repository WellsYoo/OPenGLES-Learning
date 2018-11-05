//
//  MTTimerTask.m
//  HelloOpenGLES
//
//  Created by ZhangXiaoJun on 16/8/23.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import "MTTimerTask.h"

@implementation MTTimerTask

- (instancetype)initWithDuration:(CFAbsoluteTime)duration
{
    self = [super init];
    if (self) {
        _duration = duration;
        _refreshRate = 60;
        _easingFunction = &LinearInterpolation;
    }
    return self;
}

- (void)start
{
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(callback:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    _displayLink.frameInterval = 60 / self.refreshRate;
    _startTime = CFAbsoluteTimeGetCurrent();
    _endTTime = _startTime + self.duration;
}

- (void)stop
{
    _startTime = 0;
    _endTTime = 0;
    [_displayLink invalidate];
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)callback:(CADisplayLink *)displayLink
{
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    CGFloat progress = (currentTime - _startTime) / self.duration;
    progress = self.easingFunction(progress);
    
    if ([self.delegate respondsToSelector:@selector(timerTaskDidUpdate:progress:)]) {
        [self.delegate timerTaskDidUpdate:self progress:progress];
    }
    
    if (self.updateCallback) {
        self.updateCallback(progress);
    }
    
    if (currentTime >= self->_endTTime) {
        [self stop];
        
        if ([self.delegate respondsToSelector:@selector(timerTaskDidComplete:)]) {
            [self.delegate timerTaskDidComplete:self];
        }
        
        if (self.completion) {
            self.completion();
        }
    }
}

- (void)setRefreshRate:(NSUInteger)refreshRate
{
    NSAssert(refreshRate > 0 && refreshRate <= 60 && 60 % refreshRate == 0, @"刷新率不正常~~~~~");
    _refreshRate = refreshRate;
}

@end
