//
//  GLView.h
//  MeituiOS_Learning_OpenGLES
//
//  Created by ZhangXiaoJun on 16/8/1.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLProgram,GLTexture;

@interface GLView : UIView
{
    __unsafe_unretained CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _framebuffer, _renderbuffer;
    
    CGSize _oldSize;
    
    GLProgram *_glProgram;
    GLuint _position,_color,_inputImageTexture,_inputTextureCoordinate;
//    GLuint _bufferData;
//    GLuint _indexsBuffer;
    
    GLfloat *_positions;
    GLTexture *_texture;
    
}


- (void)open:(NSTimeInterval)duration
  completion:(void (^)())completion;

- (void)close:(NSTimeInterval)duration
   completion:(void (^)())completion;

@end
