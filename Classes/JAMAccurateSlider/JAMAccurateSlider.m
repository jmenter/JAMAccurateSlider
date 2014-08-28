
/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JAMAccurateSlider.h"

@interface UIView (Utilities)
- (void)setFrameOrigin:(CGPoint)origin;
- (void)setFrameSize:(CGSize)size;
- (void)setFrameWidth:(CGFloat)width;
- (void)setFrameOriginX:(CGFloat)originX;
@end

@implementation UIView (Utilities)
- (void)setFrameOrigin:(CGPoint)origin;
{
    self.frame = CGRectMake(origin.x, origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setFrameSize:(CGSize)size;
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

- (void)setFrameWidth:(CGFloat)width;
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (void)setFrameOriginX:(CGFloat)originX;
{
    self.frame = CGRectMake(originX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

@end
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

static const float kCaliperWidth = 2.0;
static const float kCaliperHeight = 28.0;

static const float kHorizontalCaliperTrackEdgeOffset = 2.0;
static const float kVerticalCaliperEdgeOffset = 1.0;

#pragma mark - View Setup

CGRect CGRectReplaceOrigin(CGRect originalRect, CGPoint newOrigin) {
    return CGRectMake(newOrigin.x, newOrigin.y, originalRect.size.width, originalRect.size.height);
}

- (void)didMoveToSuperview;
{
    self.leftCaliperView = [self styledCaliperView];
    self.rightCaliperView = [self styledCaliperView];
    self.leftTrackView = [self styledTrackView];
    self.rightTrackView = [self styledTrackView];
    [self applyCaliperAndTrackAlpha:0];
    
    for (UIView *view in self.calipersAndTracks) {
        [self.superview addSubview:view];
    }
    
    [self resetCaliperRects];
    
    [self performSelector:@selector(applyTrackColors) withObject:nil afterDelay:0.0];
}

- (NSArray *)calipersAndTracks;
{
    return @[self.leftTrackView, self.leftCaliperView, self.rightTrackView, self.rightCaliperView];
}

- (UIView *)styledCaliperView;
{
    UIView *styledCaliperView = [UIView.alloc initWithFrame:CGRectMake(0, 0, kCaliperWidth, kCaliperHeight)];
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
    for (UIView *view in self.calipersAndTracks) {
        view.alpha = alpha;
    }
}

- (void)applyTrackColors;
{
    self.leftTrackView.backgroundColor =
    self.rightTrackView.backgroundColor = [self.superview.backgroundColor colorWithAlphaComponent:0.75];
}

- (void)resetCaliperRects;
{
    CGPoint frameOrigin = self.frame.origin;
    CGSize frameSize = self.frame.size;
    CGSize caliperSize = self.leftCaliperView.frame.size;
    [self.leftCaliperView setFrameOrigin:CGPointMake(frameOrigin.x + kHorizontalCaliperTrackEdgeOffset,
                                                     frameOrigin.y + kVerticalCaliperEdgeOffset)];
    self.leftTrackView.frame = CGRectMake(frameOrigin.x + kHorizontalCaliperTrackEdgeOffset,
                                          frameOrigin.y + 15, 2, 2);
    [self.rightCaliperView setFrameOrigin:CGPointMake(frameOrigin.x + frameSize.width - caliperSize.width - 2,
                                                      frameOrigin.y + 1)];
    self.rightTrackView.frame = CGRectMake(frameOrigin.x + frameSize.width - 2, frameOrigin.y + 15, -2, 2);
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
    CGSize frameSize = self.frame.size;
    CGPoint frameOrigin = self.frame.origin;
    
    CGFloat verticalTouchDelta = fabsf([touch locationInView:self].y - (frameSize.height / 2.f));
    BOOL touchExceededThreshold = verticalTouchDelta > frameSize.height * 2.f;
    
    if (touchExceededThreshold) {
        CGFloat trackingHorizontalDistance = [touch locationInView:self].x - [touch previousLocationInView:self].x;
        CGFloat valueDivisor = fabsf(verticalTouchDelta / frameSize.height);
        CGFloat valueRange = self.maximumValue - self.minimumValue;
        CGFloat valuePerPoint = valueRange / frameSize.width;
        
        self.value += (trackingHorizontalDistance * valuePerPoint) / valueDivisor;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        
        CGFloat leftPercentage = (self.value - self.minimumValue) / valueRange;
        CGFloat rightPercentage = (self.maximumValue - self.value) / valueRange;
        CGFloat leftOffset = frameSize.width * leftPercentage / (valueDivisor / 2.f);
        CGFloat rightOffset = frameSize.width * rightPercentage / (valueDivisor / 2.f);

        [UIView animateWithDuration:kAnimationIntraFadeDuration animations:^{
            [self.leftCaliperView setFrameOriginX:(int)(frameOrigin.x + (frameSize.width * leftPercentage) - leftOffset + 2)];
            [self.leftTrackView setFrameWidth:(frameSize.width * leftPercentage) - leftOffset];
            
            [self.rightCaliperView setFrameOriginX:(int)(frameOrigin.x + frameSize.width - kCaliperWidth - (frameSize.width * rightPercentage) + rightOffset - 2)];
            [self.rightTrackView setFrameOriginX:frameOrigin.x + frameSize.width - 2 - self.rightTrackView.frame.size.width];
            [self.rightTrackView setFrameWidth:(frameSize.width * rightPercentage) - rightOffset];
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
    [self finishTracking];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event;
{
    [self finishTracking];
}

- (void)finishTracking;
{
    [UIView animateWithDuration:kAnimationFadeOutDuration animations:^{
        [self resetCaliperRects];
        [self applyCaliperAndTrackAlpha:0];
    }];
}

@end
