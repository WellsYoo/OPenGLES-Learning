//
//  GLView.m
//  MeituiOS_Learning_OpenGLES
//
//  Created by ZhangXiaoJun on 16/8/1.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import "GLView.h"
#import "GLProgram.h"
#import <GLKit/GLKit.h>
#import "GLTexture.h"

@import OpenGLES;

@implementation GLView

- (void)dealloc
{
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    
    if (_renderbuffer) {
        glDeleteRenderbuffers(1, &_renderbuffer);
        _renderbuffer = 0;
    }
}

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)setup
{
    // 用于显示的layer
    _eaglLayer = (CAEAGLLayer *)self.layer;
    
    //  CALayer默认是透明的，而透明的层对性能负荷很大。所以将其关闭。
    _eaglLayer.opaque = YES;
    
    if (!_context) {
        // 创建GL环境上下文
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    
    NSAssert(_context && [EAGLContext setCurrentContext:_context], @"初始化GL环境失败");
    
    // 释放旧的renderbuffer
    if (_renderbuffer) {
        glDeleteRenderbuffers(1, &_renderbuffer);
        _renderbuffer = 0;
    }
    
    // 释放旧的framebuffer
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    
    // 生成renderbuffer
    glGenRenderbuffers(1, &_renderbuffer);
    
    // 绑定renderbuffer
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    
    
    // GL_RENDERBUFFER的内容存储到实现EAGLDrawable协议的CAEAGLLayer
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    // 生成framebuffer
    glGenFramebuffers(1, &_framebuffer);
    
    // 绑定Fraembuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    
    // framebuffer不对绘制的内容做存储，所以这一步是将framebuffer绑定到renderbuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _renderbuffer);
    
    // 检查framebuffer是否创建成功
    NSError *error;
    NSAssert1([self checkFramebuffer:&error], @"%@",error.userInfo[@"ErrorMessage"]);
    
    
    // 载入指定的shader
    _glProgram = [[GLProgram alloc] initWithVertexShaderFilename:@"1"
                                          fragmentShaderFilename:@"1"];
    if (!_glProgram.initialized)
    {
        // 绑定顶点属性到一个指定的id
        [_glProgram addAttribute:@"position"];
        [_glProgram addAttribute:@"color"];
        [_glProgram addAttribute:@"inputTextureCoordinate"];
        
        // 链接Program
        if (![_glProgram link])
        {
            // 失败 输出日志
            NSString *progLog = [_glProgram programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [_glProgram fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [_glProgram vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            _glProgram = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
    }
    
    // 获取顶点属性的id
    _position = [_glProgram attributeIndex:@"position"];
    _color = [_glProgram attributeIndex:@"color"];
    _inputTextureCoordinate = [_glProgram attributeIndex:@"inputTextureCoordinate"];
    
    _inputImageTexture = [_glProgram uniformIndex:@"inputImageTexture"];
    
    
    _texture = [[UIImage imageNamed:@"img_cheryl.jpg"] texture];
    //    _texture = [[UIImage imageNamed:@"123.jpg"] texture];
    
    GLint width,height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER,GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER,GL_RENDERBUFFER_HEIGHT, &height);
    _renderbufferSize = CGSizeMake(width, height);
}

- (BOOL)checkFramebuffer:(NSError *__autoreleasing *)error
{
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSString *errorMessage = nil;
    BOOL result = NO;
    
    switch (status)
    {
        case GL_FRAMEBUFFER_UNSUPPORTED:
            errorMessage = @"framebuffer不支持该格式";
            result = NO;
            break;
        case GL_FRAMEBUFFER_COMPLETE:
            NSLog(@"framebuffer 创建成功");
            result = YES;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
            errorMessage = @"Framebuffer不完整 缺失组件";
            result = NO;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS:
            errorMessage = @"Framebuffer 不完整, 附加图片必须要指定大小";
            result = NO;
            break;
        default:
            // 一般是超出GL纹理的最大限制
            errorMessage = @"未知错误 error !!!!";
            result = NO;
            break;
    }
    
    NSLog(@"%@",errorMessage ? errorMessage : @"");
    *error = errorMessage ? [NSError errorWithDomain:@"com.meitu.error"
                                                code:status
                                            userInfo:@{@"ErrorMessage" : errorMessage}] : nil;
    
    return result;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.frame.size;
    if (CGSizeEqualToSize(_oldSize, CGSizeZero) ||
        !CGSizeEqualToSize(_oldSize, size)) {
        [self setup];
        _oldSize = size;
    }
    
    [self render];
}

- (void)render
{
    // 因为GL的所有API都是基于最后一次绑定的对象作为作用对象。有很多错误是因为没有绑定或者绑定了错误的对象导致得到了错误的结果。
    // 所以每次在修改GL对象时，先绑定一次要修改的对象。
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    
    glClearColor(0, 1, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    // viewPort关系着GL坐标系的大小及位置
    glViewport(0, 0, _renderbufferSize.width, _renderbufferSize.height);
    
    // 使用program
    [_glProgram use];
    
    //启用顶点属性
    glEnableVertexAttribArray(_position);
    glEnableVertexAttribArray(_color);
    glEnableVertexAttribArray(_inputTextureCoordinate);
    
    // 包含3个4维向量的数组
    static const GLfloat g_color_buffer_data[] =
    {
        1.0,1.0,1.0,1.0,
        1.0,1.0,1.0,1.0,
        1.0,1.0,1.0,1.0,
        1.0,1.0,1.0,1.0,
        
        
        0.0,0.0,0.0,1.0,
        0.0,0.0,0.0,1.0,
        0.0,0.0,0.0,1.0,
        0.0,0.0,0.0,1.0,
    };
    
    static const GLubyte gl_index_buffer_data[] =
    {
        0,1,2,
        1,2,3,
        
        4,5,6,
        5,6,7
    };
    
    
    CGRect textureFrame = CGRectMake(0, 100, _texture.size.width * 3, _texture.size.height * 3);
    GLKVector2 *position = CGRectConvertToVertex(textureFrame, _renderbufferSize);
    GLKVector2 texCoord[] = {0.0f,0.0f,
        3.0f,0.0f,
        0.0f,3.0f,
        3.0f,3.0f};
    
    
    glActiveTexture(GL_TEXTURE0);
    glBindBuffer(GL_TEXTURE_2D, [_texture texture]);
    glUniform1i(_inputImageTexture, 0);
    
    //向顶点属性传递数据
    glVertexAttribPointer(_position, 2, GL_FLOAT, NO, 0, position);
    glVertexAttribPointer(_color, 4, GL_FLOAT, NO, 0, g_color_buffer_data);
    glVertexAttribPointer(_inputTextureCoordinate, 2, GL_FLOAT, NO, 0, texCoord);
    
    //调用glDrawArrays
    glDrawElements(GL_TRIANGLES, sizeof(gl_index_buffer_data) / sizeof(GLubyte), GL_UNSIGNED_BYTE, gl_index_buffer_data);
    
    // 做完所有绘制操作后，最终呈现到屏幕上
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    free(position);
}


GLKVector2 * CGRectConvertToTexCoord(CGRect rect, CGSize spaceSize)
{
    GLKVector2 *texcoord = calloc(4, sizeof(GLKVector2));
    
    CGPoint topLeft = rect.origin;
    CGPoint topRight = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    CGPoint bottomRight = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGPoint bottomLeft = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
    
    texcoord[0] = GLKVector2Make(bottomLeft.x / spaceSize.width , bottomLeft.y / spaceSize.height);
    texcoord[1] = GLKVector2Make(bottomRight.x / spaceSize.width , bottomRight.y / spaceSize.height);
    texcoord[2] = GLKVector2Make(topLeft.x / spaceSize.width , topLeft.y / spaceSize.height);
    texcoord[3] = GLKVector2Make(topRight.x / spaceSize.width , topRight.y / spaceSize.height);
    
    return texcoord;
}

void texCoordToVertex(GLKVector2 *texcoord,uint count)
{
    for (uint i = 0; i < count; i++) {
        GLKVector2 temp = GLKVector2Make((texcoord[i].x - 0.5) / 0.5, (texcoord[i].y - 0.5) / 0.5);
        texcoord[i] = temp;
    }
}

GLKVector2 * CGRectConvertToVertex(CGRect rect, CGSize spaceSize)
{
    GLKVector2 *texCoord = CGRectConvertToTexCoord(rect, spaceSize);
    texCoordToVertex(texCoord, 4);
    return texCoord;
}

@end
