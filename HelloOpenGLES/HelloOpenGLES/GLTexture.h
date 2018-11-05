//
//  GLTexture.h
//  HelloOpenGLES
//
//  Created by ZhangXiaoJun on 16/9/22.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface GLTexture : NSObject
{
    GLuint _texture;
}

+ (instancetype)texture:(UIImage *)image;

- (instancetype)initWithImage:(UIImage *)image;

@property (nonatomic, readonly, assign) CGSize size;

- (GLuint)texture;

@end

@interface UIImage (GLTexture)

- (GLTexture *)texture;

@end
