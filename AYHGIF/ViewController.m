//
//  ViewController.m
//  AYHGIF
//
//  Created by alimysoyang on 15-2-4.
//  Copyright (c) 2015年 alimysoyang. All rights reserved.
//

#import "ViewController.h"
#import "AYHGIFView.h"

@interface ViewController ()

@property (strong, nonatomic) AYHGIFView *gifView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.gifView = [[AYHGIFView alloc] initWithFrame:CGRectZero ContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mugen" ofType:@"gif"]];
    self.gifView.frame = CGRectMake((self.view.frame.size.width - self.gifView.gifSize.width / 2.0) / 2.0, 60.0, self.gifView.gifSize.width / 2.0, self.gifView.gifSize.height / 2.0);
    [self.view addSubview:self.gifView];
    [self.gifView play];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(self.gifView.frame.origin.x, self.gifView.frame.size.height + 70.0, self.gifView.frame.size.width, 37.0)];
    [button setTitle:@"pause" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.layer.borderColor = [UIColor grayColor].CGColor;
    button.layer.borderWidth = 1.0;
    button.layer.cornerRadius = 6.0;
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) buttonClicked:(id) sender
{
    [self.gifView pause];
    UIButton *button = (UIButton *)sender;
    if (self.gifView.gifStatus == kGIFPause)
        [button setTitle:@"play" forState:UIControlStateNormal];
    else
        [button setTitle:@"pause" forState:UIControlStateNormal];
}
@end
