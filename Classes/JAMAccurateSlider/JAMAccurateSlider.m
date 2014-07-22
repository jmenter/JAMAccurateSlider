
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
        CGFloat valuePerPoint = (self.maximumValue - self.minimumValue) / self.frame.size.width;
        self.value += (trackingHorizontalDistance * valuePerPoint) / valueDivisor;
        
        [UIView animateWithDuration:kAnimationIntraFadeDuration animations:^{
            CGFloat halfValueDivisor = valueDivisor / 2.f;
            CGFloat valueRange = self.maximumValue - self.minimumValue;
            
            CGFloat leftPercentage = (self.value - self.minimumValue) / valueRange;
            CGFloat rightPercentage = (self.maximumValue - self.value) / valueRange;

            CGFloat leftOffset = self.frame.size.width * leftPercentage / halfValueDivisor;
            CGFloat rightOffset = self.frame.size.width * rightPercentage / halfValueDivisor;
            
            CGRect leftCaliperRect = self.leftCaliperView.frame;
            leftCaliperRect.origin.x = (int)(self.frame.origin.x + (self.frame.size.width * leftPercentage) - leftOffset + 2);
            self.leftCaliperView.frame = leftCaliperRect;
            
            CGRect leftTrackRect = self.leftTrackView.frame;
            leftTrackRect.size.width = self.frame.origin.x + (self.frame.size.width * leftPercentage) - leftOffset - 17;
            self.leftTrackView.frame = leftTrackRect;
            
            CGRect rightCaliperRect = self.rightCaliperView.frame;
            rightCaliperRect.origin.x = (int)(self.frame.origin.x + self.frame.size.width - self.rightCaliperView.frame.size.width - (self.frame.size.width * rightPercentage) + rightOffset - 2);
            self.rightCaliperView.frame = rightCaliperRect;
            
            CGRect rightTrackRect = self.rightTrackView.frame;
            rightTrackRect.origin.x = self.frame.origin.x + self.frame.size.width - 2 - (self.frame.origin.x + (self.frame.size.width * rightPercentage) - rightOffset - 17);
            rightTrackRect.size.width = self.frame.origin.x + (self.frame.size.width * rightPercentage) - rightOffset - 17;
            self.rightTrackView.frame = rightTrackRect;
        }];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        return YES;
    }
    [UIView animateWithDuration:kAnimationIntraFadeDuration animations:^{
        [self resetCaliperRects];
    }];
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event;
{
    [UIView animateWithDuration:kAnimationFadeOutDuration animations:^{
        [self resetCaliperRects];
        [self applyCaliperAndTrackAlpha:0];
    }];
}

@end
