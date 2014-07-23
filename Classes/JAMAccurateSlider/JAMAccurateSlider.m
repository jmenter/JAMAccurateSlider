
/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JAMAccurateSlider.h"

@interface JAMAccurateSlider ()
@property (nonatomic) UIView *leftCaliperView;
@property (nonatomic) UIView *rightCaliperView;
@property (nonatomic) UIView *leftTrackView;
@property (nonatomic) UIView *rightTrackView;
@end

@implementation JAMAccurateSlider

static const float kAnimationFadeInDuration = 0.2;
static const float kAnimationIntraFadeDuration = 0.1;
static const float kAnimationFadeOutDuration = 0.4;

#pragma mark - View Setup

- (void)didMoveToSuperview;
{
    self.leftCaliperView = [self styledCaliperView];
    self.rightCaliperView = [self styledCaliperView];
    self.leftTrackView = [self styledTrackView];
    self.rightTrackView = [self styledTrackView];
    [self applyCaliperAndTrackAlpha:0];
    
    [self.superview addSubview:self.leftTrackView];
    [self.superview addSubview:self.leftCaliperView];
    [self.superview addSubview:self.rightTrackView];
    [self.superview addSubview:self.rightCaliperView];
    [self resetCaliperRects];
    
    [self performSelector:@selector(applyTrackColors) withObject:nil afterDelay:0.0];
}

- (UIView *)styledCaliperView;
{
    UIView *styledCaliperView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 2, 28)];
    styledCaliperView.backgroundColor = UIColor.whiteColor;
    styledCaliperView.layer.shadowColor = UIColor.blackColor.CGColor;
    styledCaliperView.layer.shadowRadius = 1;
    styledCaliperView.layer.shadowOpacity = 0.5;
    styledCaliperView.layer.shadowOffset = CGSizeMake(0, 0.5);
    styledCaliperView.layer.cornerRadius = 1;
    return styledCaliperView;
}

- (UIView *)styledTrackView;
{
    UIView *styledTrackView = UIView.new;
    styledTrackView.layer.cornerRadius = 1;
    return styledTrackView;
}

- (void)applyCaliperAndTrackAlpha:(CGFloat)alpha;
{
    self.leftCaliperView.alpha = alpha;
    self.leftTrackView.alpha = alpha;
    self.rightCaliperView.alpha = alpha;
    self.rightTrackView.alpha = alpha;
}

- (void)applyTrackColors;
{
    self.leftTrackView.backgroundColor = [self.superview.backgroundColor colorWithAlphaComponent:0.75];
    self.rightTrackView.backgroundColor = [self.superview.backgroundColor colorWithAlphaComponent:0.75];
}

- (void)resetCaliperRects;
{
    self.leftCaliperView.frame = CGRectMake(self.frame.origin.x + 2,
                                            self.frame.origin.y + 1,
                                            self.leftCaliperView.frame.size.width,
                                            self.leftCaliperView.frame.size.height);
    self.leftTrackView.frame = CGRectMake(self.frame.origin.x + 2, self.frame.origin.y + 15,
                                          2, 2);
    self.rightCaliperView.frame = CGRectMake(self.frame.origin.x + self.frame.size.width -
                                             self.rightCaliperView.frame.size.width - 2,
                                             self.frame.origin.y + 1,
                                             self.rightCaliperView.frame.size.width,
                                             self.rightCaliperView.frame.size.height);
    self.rightTrackView.frame = CGRectMake(self.frame.origin.x + self.frame.size.width - 2,
                                           self.frame.origin.y + 15,
                                           -2, 2);
}

#pragma mark - UIControl Touch Tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event;
{
    [self resetCaliperRects];
    [UIView animateWithDuration:kAnimationFadeInDuration animations:^{
        [self applyCaliperAndTrackAlpha:1];
    }];
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event;
{
    CGFloat verticalTouchDelta = fabsf([touch locationInView:self].y - (self.frame.size.height / 2.f));
    if (verticalTouchDelta > self.frame.size.height * 2.f) {
        CGFloat trackingHorizontalDistance = [touch locationInView:self].x - [touch previousLocationInView:self].x;
        CGFloat valueDivisor = fabsf(verticalTouchDelta / self.frame.size.height);
        CGFloat valueRange = self.maximumValue - self.minimumValue;
        CGFloat valuePerPoint = valueRange / self.frame.size.width;
        self.value += (trackingHorizontalDistance * valuePerPoint) / valueDivisor;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        
        CGFloat leftPercentage = (self.value - self.minimumValue) / valueRange;
        CGFloat rightPercentage = (self.maximumValue - self.value) / valueRange;
        CGFloat leftOffset = self.frame.size.width * leftPercentage / (valueDivisor / 2.f);
        CGFloat rightOffset = self.frame.size.width * rightPercentage / (valueDivisor / 2.f);
        
        CGRect leftCaliperRect = self.leftCaliperView.frame;
        leftCaliperRect.origin.x = (int)(self.frame.origin.x + (self.frame.size.width * leftPercentage) - leftOffset + 2);
        
        CGRect leftTrackRect = self.leftTrackView.frame;
        leftTrackRect.size.width = self.frame.origin.x + (self.frame.size.width * leftPercentage) - leftOffset - 17;
        
        CGRect rightCaliperRect = self.rightCaliperView.frame;
        rightCaliperRect.origin.x = (int)(self.frame.origin.x + self.frame.size.width - self.rightCaliperView.frame.size.width - (self.frame.size.width * rightPercentage) + rightOffset - 2);
        
        CGRect rightTrackRect = self.rightTrackView.frame;
        rightTrackRect.origin.x = self.frame.origin.x + self.frame.size.width - 2 - (self.frame.origin.x + (self.frame.size.width * rightPercentage) - rightOffset - 17);
        rightTrackRect.size.width = self.frame.origin.x + (self.frame.size.width * rightPercentage) - rightOffset - 17;
        [UIView animateWithDuration:kAnimationIntraFadeDuration animations:^{
            self.leftCaliperView.frame = leftCaliperRect;
            self.leftTrackView.frame = leftTrackRect;
            self.rightCaliperView.frame = rightCaliperRect;
            self.rightTrackView.frame = rightTrackRect;
        }];
        return YES;
    } else {
        [UIView animateWithDuration:kAnimationIntraFadeDuration animations:^{
            [self resetCaliperRects];
        }];
        return [super continueTrackingWithTouch:touch withEvent:event];
    }
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event;
{
    [UIView animateWithDuration:kAnimationFadeOutDuration animations:^{
        [self resetCaliperRects];
        [self applyCaliperAndTrackAlpha:0];
    }];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event;
{
    [UIView animateWithDuration:kAnimationFadeOutDuration animations:^{
        [self resetCaliperRects];
        [self applyCaliperAndTrackAlpha:0];
    }];
}

@end
