
/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JAMAccurateSlider.h"

@implementation UIView (Utilities)
- (void)setFrameOrigin:(CGPoint)origin {
    self.frame = CGRectMake(origin.x, origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setFrameOriginX:(CGFloat)originX {
    self.frame = CGRectMake(originX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setFrameSize:(CGSize)size {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

- (void)setFrameWidth:(CGFloat)width {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

@end
@interface JAMAccurateSlider ()
@property (nonatomic) UIView *leftCaliperView;
@property (nonatomic) UIView *rightCaliperView;
@property (nonatomic) UIView *leftTrackView;
@property (nonatomic) UIView *rightTrackView;
@property CGRect trackRect;
@end

@implementation JAMAccurateSlider

static const float kAnimationFadeInDuration = 0.2;
static const float kAnimationFadeOutDuration = 0.4;

static const float kCaliperWidth = 2.0;
static const float kCaliperHeight = 28.0;
static const float kTrackInitialWidth = 2.0;

static const float kHorizontalCaliperTrackEdgeOffset = 2.0;
static const float kVerticalCaliperEdgeOffset = 1.0;

static void * kObservationContext = &kObservationContext;

#pragma mark - View Setup

- (void)didMoveToSuperview;
{
    [self.superview addObserver:self forKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionOld context:kObservationContext];
    self.trackRect = [self trackRectForBounds:self.bounds];
    self.leftCaliperView = [self styledCaliperView];
    self.rightCaliperView = [self styledCaliperView];
    self.leftTrackView = [self styledTrackView];
    self.rightTrackView = [self styledTrackView];
    self.caliperAndTrackAlpha = 0;
    
    for (UIView *view in self.caliperAndTrackViews) {
        [self.superview addSubview:view];
    }
    
    [self resetCaliperRects];
    [self performSelector:@selector(applyTrackColors) withObject:nil afterDelay:0.0];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kObservationContext) {
        [self applyTrackColors];
    }
}

- (NSArray *)caliperAndTrackViews;
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

- (void)setCaliperAndTrackAlpha:(CGFloat)alpha;
{
    for (UIView *view in self.caliperAndTrackViews) {
        view.alpha = alpha;
    }
}

- (void)applyTrackColors;
{
    UIColor *background = self.superview.backgroundColor ?: UIColor.whiteColor;
    if ([background isEqual:UIColor.clearColor]) {
        background = UIColor.whiteColor;
    }
    self.leftTrackView.backgroundColor = [background colorWithAlphaComponent:0.75];
    self.rightTrackView.backgroundColor = [background colorWithAlphaComponent:0.75];
}

- (void)resetCaliperRects;
{
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    CGFloat width = self.frame.size.width;
    
    self.leftCaliperView.frameOrigin = CGPointMake(x + kHorizontalCaliperTrackEdgeOffset, y + kVerticalCaliperEdgeOffset);
    self.rightCaliperView.frameOrigin = CGPointMake(x + width - kCaliperWidth - 2, y + kVerticalCaliperEdgeOffset);
    
    self.leftTrackView.frame = CGRectMake(x + self.trackRect.origin.x, y + self.trackRect.origin.y,
                                          kTrackInitialWidth, self.trackRect.size.height);
    self.rightTrackView.frame = CGRectMake(x + width - kTrackInitialWidth - self.trackRect.origin.x,
                                           y + self.trackRect.origin.y,
                                           kTrackInitialWidth, self.trackRect.size.height);
}

#pragma mark - UIControl Touch Tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event;
{
    [self resetCaliperRects];
    [UIView animateWithDuration:kAnimationFadeInDuration animations:^{
        self.caliperAndTrackAlpha = 1;
    }];
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event;
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat x = self.frame.origin.x;
    CGFloat verticalTouchDelta = fabsf([touch locationInView:self].y - (height / 2.f));
    
    if (verticalTouchDelta < height * 2.f) { // normal tracking
        [UIView animateWithDuration:kAnimationFadeOutDuration animations:^{ [self resetCaliperRects]; }];
        return [super continueTrackingWithTouch:touch withEvent:event];
    }
    
    CGFloat trackingHorizontalDelta = [touch locationInView:self].x - [touch previousLocationInView:self].x;
    CGFloat valueDivisor = fabsf(verticalTouchDelta / height);
    CGFloat valueRange = self.maximumValue - self.minimumValue;
    CGFloat valuePerPoint = valueRange / width;
    
    self.value += (trackingHorizontalDelta * valuePerPoint) / valueDivisor;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    CGFloat leftPercentage = (self.value - self.minimumValue) / valueRange;
    CGFloat rightPercentage = (self.maximumValue - self.value) / valueRange;
    CGFloat leftOffset = width * leftPercentage / (valueDivisor / 2.f);
    CGFloat rightOffset = width * rightPercentage / (valueDivisor / 2.f);
    
    // int values make the calipers and track align to point values just like the slider thumb
    self.leftCaliperView.frameOriginX = (int)(x + (width * leftPercentage) - leftOffset + 2);
    self.rightCaliperView.frameOriginX = (int)(x + width - kCaliperWidth - (width * rightPercentage) + rightOffset - 2);
    self.leftTrackView.frameWidth = (int)((width * leftPercentage) - leftOffset + 1);
    self.rightTrackView.frameWidth = (int)((width * rightPercentage) - rightOffset + 1);
    self.rightTrackView.frameOriginX = (int)(x + width - 2 - self.rightTrackView.frame.size.width);
    
    return YES;
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
        self.caliperAndTrackAlpha = 0;
    }];
}

- (void)dealloc {
    [self.superview removeObserver:self forKeyPath:@"backgroundColor"];
}

@end
