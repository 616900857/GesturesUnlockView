//
//  GesturesPointView.m
//  UnlockView
//
//  Created by mac on 2019/8/27.
//  Copyright © 2019 com.beng.XX. All rights reserved.
//

#import "GesturesPointView.h"
#import "GesturesUnlockView.h"

@interface GesturesPointView()
@property (nonatomic, strong)UIColor *borderColor;
@property (nonatomic, strong)UIColor *circleColor;
@property (nonatomic, assign)CGFloat borderWidth;
@end

@implementation GesturesPointView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat width = rect.size.width;
    CGRect frame = CGRectMake(_borderWidth, _borderWidth, width - _borderWidth * 2, width - _borderWidth * 2 );
    CGContextAddEllipseInRect(context, frame);
    [self.circleColor set];
    CGContextFillPath(context);
    CGContextSetLineWidth(context, _borderWidth);
    CGContextAddEllipseInRect(context, frame);
    [self.borderColor set];
    CGContextStrokePath(context);
}

- (void)setState:(TMGesturePointViewState)state {
    self.borderWidth = self.config.borderWidth;
    switch (state) {
        case GesturePointViewStateNormal:
            self.circleColor = self.config.circleColorNormal;
            self.borderColor = self.config.borderColorNormal;
            break;
        case GesturePointViewSelected:
            self.circleColor = self.config.circleColorSelected;
            self.borderColor = self.config.borderColorSelected;
            break;
        case GesturePointViewIncorrect:
            self.circleColor = self.config.circleColorIncorrect;
            self.borderColor = self.config.borderColorIncorrect;
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

@end
