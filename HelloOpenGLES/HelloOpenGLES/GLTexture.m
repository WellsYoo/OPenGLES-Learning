//
//  GLTexture.m
//  HelloOpenGLES
//
//  Created by ZhangXiaoJun on 16/9/22.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import "GLTexture.h"
@import OpenGLES;

@implementation GLTexture

+ (instancetype)texture:(UIImage *)image
{
    return [[self alloc] initWithImage:image];
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        [self craeteTexture:image];
    }
    return self;
}

- (void)craeteTexture:(UIImage *)image
{
    size_t width = CGImageGetWidth(image.CGImage);
    size_t height = CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    
    CGContextRef context = CGBitmapContextCreate(imageData,
                                                 width,
                                                 height,
                                                 8,
                                                 4 * width,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
    CGContextRelease(context);
    
    
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RGBA,
                 (GLint)width,
                 (GLint)height,
                 0,
                 GL_RGBA,
                 GL_UNSIGNED_BYTE,
                 imageData);
    free(imageData);
    
    _size = CGSizeMake(width, height);
}

- (GLuint)texture
{
    return _texture;
}

@end

@implementation UIImage (GLTexture)

- (GLTexture *)texture
{
    return [GLTexture texture:self];
}

@end
