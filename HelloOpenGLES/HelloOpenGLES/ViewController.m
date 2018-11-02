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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
