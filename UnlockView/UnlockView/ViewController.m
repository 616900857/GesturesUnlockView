//
//  ViewController.m
//  UnlockView
//
//  Created by mac on 2019/8/27.
//  Copyright © 2019 com.beng.XX. All rights reserved.
//

#import "ViewController.h"
#import "GesturesUnlockView.h"

@interface ViewController ()

@property (strong, nonatomic) GesturesUnlockView *gestureView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.gestureView.gestureResult = ^(TMGestureResultTypes type, BOOL result, NSString * _Nonnull gestureId) {
        switch (type) {
            case GestureLessInput: //手势密码小于4位数
                
                break;
            case GestureLogin:
                if (result) {
                    
                }
                break;
            default:
                break;
        }
    };
}

- (GesturesUnlockView *)gestureView {
    if(!_gestureView) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        _gestureView = [[GesturesUnlockView alloc] initWithFrame:CGRectMake(0, 0, width-150, width-150) gestureType:GestureTypeLogin];
        _gestureView.center = self.view.center;
        [self.view addSubview:_gestureView];
    }
    return _gestureView;
}

@end
