//
//  GesturesUnlockView.m
//  UnlockView
//
//  Created by mac on 2019/8/27.
//  Copyright © 2019 com.beng.XX. All rights reserved.
//

#import "GesturesUnlockView.h"
#import "GesturesPointView.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <sys/utsname.h>
#define HEXRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]
#define HEXRGB_Alpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:a]

@implementation TMGesturesConfig

+ (TMGesturesConfig *)defaultConfig {
    TMGesturesConfig *config = [[TMGesturesConfig alloc] init];
    config.borderWidth = 5.0;
    config.lineWidth = 4.0;
    config.circleRadius = 20.0;
    config.circleColorNormal = HEXRGB(0xCED0D9);
    config.circleColorSelected = HEXRGB(0xFAE44C);
    config.circleColorIncorrect = HEXRGB(0xFDDDD6);
    config.borderColorNormal = HEXRGB(0xFAFAFB);
    config.borderColorSelected = HEXRGB(0x4B4B4B);
    config.borderColorIncorrect = HEXRGB(0xF75730);
    config.lineColorSelected = HEXRGB(0x4B4B4B);
    config.lineColorIncorrect = HEXRGB(0xF75730);
    return config;
}
@end

@interface GesturesUnlockView ()
@property (nonatomic, assign) TMGesturePointViewState state;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, strong) NSMutableArray *selectedArr;
@property (nonatomic, assign) NSInteger inputNum;
@property (nonatomic, assign) NSInteger resetInputNum;
@property (nonatomic, assign) NSInteger errorInputNum;
@property (nonatomic, strong) NSString *firstPassword;
@property (nonatomic, strong) UIColor *lineColor;
@end

@implementation GesturesUnlockView

- (instancetype)initWithFrame:(CGRect)frame gestureType:(TMGestureTypes)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        self.state = GesturePointViewStateNormal;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.type = GestureTypeSet;
        self.state = GesturePointViewStateNormal;
    }
    return self;
}

- (void)initUI {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.backgroundColor = UIColor.clearColor;
    CGFloat width = self.config.circleRadius * 2.0;
    CGFloat margin = (self.frame.size.width - width * 3) / 2.0;
    for (int i = 0; i < 9; i++) {
        NSInteger row = i / 3, col = i % 3;
        GesturesPointView *pointView = [[GesturesPointView alloc] initWithFrame:CGRectMake((width + margin) * col, (width + margin) * row, width, width)];
        pointView.config = self.config;
        pointView.state = GesturePointViewStateNormal;
        pointView.backgroundColor = UIColor.clearColor;
        [pointView setTag:i+1];
        [self addSubview:pointView];
    }
    if(self.gestureIds) {
        self.gestureIds = _gestureIds;
    }
}

- (void)layoutSubviews {
    [self initUI];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if ([self.selectedArr count] == 0) {
        return;
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path setLineWidth:self.config.lineWidth];
    [self.lineColor set];
    [path setLineJoinStyle:kCGLineJoinRound];
    [path setLineCapStyle:kCGLineCapRound];
    for (NSInteger i = 0; i < self.selectedArr.count; i ++) {
        GesturesPointView *view = self.selectedArr[i];
        if (i == 0) {
            [path moveToPoint:[view center]];
        }else{
            [path addLineToPoint:[view center]];
        }
    }
    if(_type != GestureTypeMemory) {
        [path addLineToPoint:self.currentPoint];
    }
    [path stroke];
}

#pragma mark touchAction
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    self.currentPoint = point;
    for (GesturesPointView *view in self.subviews) {
        if (CGRectContainsPoint(view.frame, point)) {
            view.state = GesturePointViewSelected;
            if (![self.selectedArr containsObject:view]) {
                [self.selectedArr addObject:view];
            }
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    self.currentPoint = point;
    for (GesturesPointView *view in self.subviews) {
        if (CGRectContainsPoint(view.frame, point)) {
            view.state = GesturePointViewSelected;
            if (![self.selectedArr containsObject:view]) {
                [self.selectedArr addObject:view];
            }
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (self.selectedArr.count < 4) {
        self.state = GesturePointViewIncorrect;
        if(self.gestureResult) {
            self.gestureResult(GestureLessInput, NO, @"");
        }
        
    } else if (self.type == GestureTypeSet) {
        [self setPasswordBlock];
        
    } else if(self.type == GestureTypeReset) {
        NSString *password = [self getPassword];
        if (self.resetInputNum == 0) {
            NSString *inputPassword = [self getCurPointId];
            NSString *md5Pwd = [NSString md5StringFromString:inputPassword];
            if ([md5Pwd isEqualToString:password]) {
                self.resetInputNum += 1;
                [self delayResetButtons];
                if(self.gestureResult) {
                    self.gestureResult(GestureVerify, YES, inputPassword);
                }
                
            } else {
                self.errorInputNum ++;
                self.state = GesturePointViewIncorrect;
                if(self.gestureResult) {
                    self.gestureResult(GestureVerify, NO, @"");
                }
            }
        } else if (self.resetInputNum == 1){
            [self setPasswordBlock];
        }
        
    } else if(self.type == GestureTypeLogin){
        NSString *password = [self getPassword];
        NSString *inputPassword = [self getCurPointId];
        NSString *md5Pwd = [NSString md5StringFromString:inputPassword];
        if(self.gestureResult) {
            if ([md5Pwd isEqualToString:password]) {
                self.gestureResult(GestureLogin, YES, inputPassword);
                self.state = GesturePointViewStateNormal;
            } else {
                self.errorInputNum ++;
                self.gestureResult(GestureLogin, NO, @"");
                self.state = GesturePointViewIncorrect;
            }
        }
    }
    GesturesPointView *view = [self.selectedArr lastObject];
    [self setCurrentPoint:view.center];
    [self setNeedsDisplay];
}

#pragma mark Logic
- (void)setPasswordBlock {
    if (self.inputNum == 0) {
        self.firstPassword = [self getCurPointId];
        self.inputNum += 1;
        [self delayResetButtons];
        if(self.gestureResult) {
            self.gestureResult(GestureSet, YES, self.firstPassword);
        }
    } else {
        NSString *secondPassword = [self getCurPointId];
        if ([self.firstPassword isEqualToString:secondPassword]) {
            [self savePassWord:secondPassword];
            [self delayResetButtons];
            if(self.gestureResult) {
                self.gestureResult(GestureSetAgain, YES, self.firstPassword);
            }
        } else {
            self.state = GesturePointViewIncorrect;
            self.inputNum -= 1;
            if(self.gestureResult) {
                self.gestureResult(GestureSetAgain, NO, @"");
            }
        }
    }
}

- (void)setErrorInputNum:(NSInteger)errorInputNum {
    _errorInputNum = errorInputNum;
    if (errorInputNum == 3) {
        NSLog(@"手势密码错误，您还可以尝试2次");
    } else if (errorInputNum == 5) {
        NSLog(@"手势密码错误，您需要重新登录");
        //退出登录
    }
}

- (void)lockState:(NSArray *)states {
    NSNumber *stateNumber = [states objectAtIndex:0];
    self.state = [stateNumber integerValue];
}

- (void)resetButtons {
    for (GesturesPointView *view in self.selectedArr) {
        view.state = GesturePointViewStateNormal;
    }
    [self.selectedArr removeAllObjects];
    [self setNeedsDisplay];
}

- (void)delayResetButtons {
    [self performSelector:@selector(lockState:) withObject:[NSArray arrayWithObject:[NSNumber numberWithInteger:GesturePointViewStateNormal]] afterDelay:0.5f];
}

- (NSString *)getCurPointId {
    NSString *string = [[NSString alloc] init];
    for (GesturesPointView *btn in self.selectedArr) {
        string = [string stringByAppendingFormat:@"%@",@(btn.tag)];
    }
    return string;
}

#pragma mark password
- (void)savePassWord:(NSString *)password {
    NSString *md5Pwd = [NSString md5StringFromString:password];
    [[NSUserDefaults standardUserDefaults] setObject:md5Pwd forKey:@"TMFGestureKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];}

- (NSString *)getPassword {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"TMFGestureKey"];
}

- (void)setGestureIds:(NSString *)gestureIds {
    if(!gestureIds) {
        return;
    }
    _gestureIds = gestureIds;
    [self resetButtons];
    for(int i = 0; i < gestureIds.length; i++) {
        NSInteger tag = [[gestureIds substringWithRange:NSMakeRange(i, 1)] integerValue];
        GesturesPointView *view = [self viewWithTag:tag];
        if(view && ![self.selectedArr containsObject:view]) {
            view.state = GesturePointViewSelected;
            [self.selectedArr addObject:view];
        }
    }
    [self setNeedsDisplay];
}

- (void)setState:(TMGesturePointViewState)state {
    _state = state;
    switch (state) {
        case GesturePointViewStateNormal:
            [self resetButtons];
            self.lineColor = self.config.lineColorSelected;
            break;
        case GesturePointViewSelected:
            self.lineColor = self.config.lineColorSelected;
            break;
        case GesturePointViewIncorrect:
            self.lineColor = self.config.lineColorIncorrect;
            for (GesturesPointView *view in self.selectedArr) {
                view.state = GesturePointViewIncorrect;
            }
            [self delayResetButtons];
            break;
        default:
            break;
    }
}

- (void)setType:(TMGestureTypes)type {
    _type = type;
    self.userInteractionEnabled = type != GestureTypeMemory;
}

- (TMGesturesConfig *)config {
    if(!_config) {
        _config = TMGesturesConfig.defaultConfig;
        if (_type == GestureTypeMemory) {
            _config.borderWidth = 0;
            _config.lineWidth = 2.0;
            _config.circleRadius = 4.0;
            _config.circleColorSelected = HEXRGB(0x4B4B4B);
        }
    }
    return _config;
}

- (NSMutableArray *)selectedArr {
    if(!_selectedArr) {
        _selectedArr = [NSMutableArray array];
    }
    return _selectedArr;
}

@end


@implementation NSString (Extend)

+ (NSString *)md5StringFromString:(NSString *)string {
    NSParameterAssert(string != nil && [string length] > 0);
    
    const char *value = [string UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }
    
    return outputString;
}
@end
