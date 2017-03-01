//
//  ViewController.m
//  DebugUISample
//
//  Created by Cong Can NGO on 3/1/17.
//  Copyright © 2017 vns. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+DebugUI.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addDebugScreen:@"help-and-feedback.png"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
