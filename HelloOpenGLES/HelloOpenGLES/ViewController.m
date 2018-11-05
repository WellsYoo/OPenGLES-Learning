//
//  ViewController.m
//  HelloOpenGLES
//
//  Created by ZhangXiaoJun on 16/8/2.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import "ViewController.h"
#import "GLView.h"

@interface ViewController ()
@property (nonatomic, strong) GLView *glView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.glView = [[GLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self open];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)open {
    [self.glView open:3.0
           completion:^() {
               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                   [self close];
               });
           }];
}

- (void)close {
    [self.glView close:3.0
            completion:^() {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self open];
                });
            }];
}

@end
