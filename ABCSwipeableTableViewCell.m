#import "ABCSwipeableTableViewCell.h"



/**
 Created by Jan Sichermann on 11/26/14. Copyright (c) 2014 Abacus. All rights reserved.
 */



@interface ABCSwipeableTableViewCell ()
<
UIGestureRecognizerDelegate
>
@property (nonatomic) CGFloat offset;
@end



static const CGFloat threshold = 0.25f;
static const CGFloat layoutAnimationDuration = 0.2f;
static const CGFloat alphaAnimationDuration = 0.3;



CGFloat ABCSwipeableTableViewCellNoOffset = 0.f;
CGFloat ABCSwipeableTableViewCellOffsetRight = 1.f;
CGFloat ABCSwipeableTableViewCellOffsetLeft = -1.f;



@implementation ABCSwipeableTableViewCell

+ (CGFloat)heightForModel:(__unused id)model
              inTableView:(__unused UITableView *)tableView {
    return 128.f;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    
    if (!self) {
        return nil;
    }
    
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    UIPanGestureRecognizer *pr =
    [[UIPanGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(panSwipeView:)];
    pr.delegate = self;
    [self.contentView addGestureRecognizer:pr];
    
    self.contentView.backgroundColor = [UIColor greenColor];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutSubviewsAnimated:NO
               completionHandler:nil];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    if ([self.leftTriggerView respondsToSelector:@selector(prepareForReuse)]) {
        [self.leftTriggerView prepareForReuse];
    }
    
    if ([self.rightTriggerView respondsToSelector:@selector(prepareForReuse)]) {
        [self.rightTriggerView prepareForReuse];
    }
    
    [self setSwipeOffsetPercentage:ABCSwipeableTableViewCellNoOffset
                          animated:NO
                 completionHandler:nil];
    
    [self setNeedsLayout];
}

- (void)setLeftTriggerViewInsets:(UIEdgeInsets)leftTriggerViewInsets {
    _leftTriggerViewInsets = leftTriggerViewInsets;
    [self setNeedsLayout];
}

- (void)setRightTriggerViewInsets:(UIEdgeInsets)rightTriggerViewInsets {
    _rightTriggerViewInsets = rightTriggerViewInsets;
    [self setNeedsLayout];
}

- (void)setLeftTriggerView:(UIView<ABCSwipeableTableViewCellReusableView> *)leftTriggerView {
    [self.leftTriggerView removeFromSuperview];
    [self.backgroundView addSubview:leftTriggerView];
    _leftTriggerView = leftTriggerView;
}

- (void)setRightTriggerView:(UIView<ABCSwipeableTableViewCellReusableView> *)rightTriggerView {
    [self.rightTriggerView removeFromSuperview];
    [self.backgroundView addSubview:rightTriggerView];
    _rightTriggerView = rightTriggerView;
}

- (void)layoutSubviewsAnimated:(BOOL)animated
             completionHandler:(void(^)())completionHandler {
    [self _layoutContentView:animated
           completionHandler:completionHandler];
    [self _updateBackgroundColor:animated];
    [self layoutTriggerViews:animated];
}

- (void)_layoutContentView:(BOOL)animated
         completionHandler:(void(^)())completionHandler {
    void(^layoutBlock)() = ^{
        self.contentView.frame = CGRectMake(self.offset * self.bounds.size.width,
                                            0.f,
                                            self.contentView.bounds.size.width,
                                            self.contentView.bounds.size.height);
    };
    
    if (animated) {
        [UIView animateWithDuration:layoutAnimationDuration
                         animations:layoutBlock
                         completion:completionHandler == nil ? nil :
         ^(BOOL finished) {
             if (finished) {
                 completionHandler();
             }
         }];
    }
    else {
        layoutBlock();
    }
}

- (void)_layoutTriggerView:(UIView *)view
                  withSize:(CGSize)s
                    insets:(UIEdgeInsets)insets
                      left:(CGFloat)left
                     alpha:(CGFloat)alpha
                  animated:(BOOL)animated {
    
    void(^layoutBlock)() = ^{
        view.frame = CGRectMake(left,
                                (self.backgroundView.bounds.size.height / 2.f) - (s.height / 2.f) + insets.top + insets.bottom,
                                s.width,
                                s.height);
        
    };
    
    void(^visibilityBlock)() = nil;
    if (fabs(view.alpha - alpha) < 0.01) {
        visibilityBlock = ^{
            view.alpha = alpha;
        };
    }
    
    if (animated) {
        [UIView animateWithDuration:layoutAnimationDuration
                         animations:layoutBlock
                         completion:visibilityBlock == nil ? nil : ^(BOOL finished) {
                             if (finished) {
                                 [UIView animateWithDuration:alphaAnimationDuration
                                                  animations:visibilityBlock];
                             }
                         }];
    }
    else {
        layoutBlock();
        if (visibilityBlock) {
            visibilityBlock();
        }
    }
    
}

- (void)_layoutLeftTriggerView:(BOOL)animated {
    
    CGSize s = [self.leftTriggerView sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    
    CGFloat left = MAX(self.leftTriggerViewInsets.left,
                       self.contentView.frame.origin.x - s.width - self.leftTriggerViewInsets.right);
    
    CGFloat alpha = 1.f;
    if (fabs(self.contentView.frame.origin.x - ABCSwipeableTableViewCellOffsetRight * self.bounds.size.width)
        < 0.01) {
        alpha = 0.f;
    }
    
    self.leftTriggerView.hidden = self.contentView.frame.origin.x < -threshold;
    
    [self _layoutTriggerView:self.leftTriggerView
                    withSize:s
                      insets:self.leftTriggerViewInsets
                        left:left
                       alpha:alpha
                    animated:animated];
}

- (void)_layoutRightTriggerView:(BOOL)animated {
    CGSize s = [self.rightTriggerView sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    
    CGFloat left = MIN(self.backgroundView.bounds.size.width - s.width - self.rightTriggerViewInsets.right,
                       self.contentView.frame.origin.x + self.contentView.frame.size.width + self.rightTriggerViewInsets.left);
    
    
    CGFloat alpha = 1.f;
    if (fabs(self.contentView.frame.origin.x - ABCSwipeableTableViewCellOffsetLeft * self.bounds.size.width) < 0.01) {
        alpha = 0.f;
    }
    
    self.rightTriggerView.hidden = self.contentView.frame.origin.x > threshold;
    
    [self _layoutTriggerView:self.rightTriggerView
                    withSize:s
                      insets:self.rightTriggerViewInsets
                        left:left
                       alpha:alpha
                    animated:animated];
}

- (void)layoutTriggerViews:(BOOL)animated {
    [self _layoutLeftTriggerView:animated];
    [self _layoutRightTriggerView:animated];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)pr {
    if ([pr isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        CGPoint point = [(UIPanGestureRecognizer *)pr velocityInView:self];
        return fabs(point.x) > fabs(point.y);
    }
    return NO;
}

- (void)panSwipeView:(UIPanGestureRecognizer *)pr {
    NSParameterAssert([pr isKindOfClass:[UIPanGestureRecognizer class]]);
    
    CGFloat translation = [pr translationInView:self.contentView].x;
    CGFloat offset =
    (translation / self.contentView.bounds.size.width);
    
    
    
    ABCSwipeableTableViewCellDirection dir = offset < ABCSwipeableTableViewCellNoOffset ? ABCSwipeableTableViewCellOffsetLeft : ABCSwipeableTableViewCellOffsetRight;
    
    if (!(self.swipeableDirections & dir)) {
        offset = ABCSwipeableTableViewCellNoOffset;
    }
    
    if (pr.state == UIGestureRecognizerStateChanged) {
        [self setSwipeOffsetPercentage:offset
                              animated:NO
                     completionHandler:nil];
    }
    else if (pr.state == UIGestureRecognizerStateCancelled) {
        [self setSwipeOffsetPercentage:ABCSwipeableTableViewCellNoOffset
                              animated:YES
                     completionHandler:nil];
    }
    else if (pr.state == UIGestureRecognizerStateEnded) {
        if (offset > threshold || offset < -threshold) {
            ABCSwipeableTableViewCell *weakSelf = self;
            [self setSwipeOffsetPercentage:dir
                                  animated:YES
                         completionHandler:^{
                             ABCSwipeableTableViewCell *strongSelf = weakSelf;
                             [strongSelf swipeTriggered:dir];
                         }];
        }
        else {
            [self setSwipeOffsetPercentage:ABCSwipeableTableViewCellNoOffset
                                  animated:YES
                         completionHandler:nil];
        }
    }
}

- (void)setSwipeOffsetPercentage:(CGFloat)offset
                        animated:(BOOL)animated
               completionHandler:(void(^)())completionHandler {
    NSParameterAssert(offset >= ABCSwipeableTableViewCellOffsetLeft);
    NSParameterAssert(offset <= ABCSwipeableTableViewCellOffsetRight);
    
    self.offset = offset;
    [self layoutSubviewsAnimated:animated
               completionHandler:completionHandler];
}

- (void)swipeTriggered:(ABCSwipeableTableViewCellDirection)direction {
    if (self.triggerHandler) {
        self.triggerHandler(direction);
    }
}

- (void)_updateBackgroundColor:(BOOL)animated {
    UIColor *c = [self colorForOffset:self.offset];
    if ([self.backgroundView.backgroundColor isEqual:c]) {
        return;
    }
    
    void(^colorBlock)() = ^{
        self.backgroundView.backgroundColor = c;
    };
    if (animated) {
        [UIView animateWithDuration:alphaAnimationDuration
                         animations:^{
                             colorBlock();
                         }];
    }
    else {
        colorBlock();
    }
}

- (UIColor *)colorForOffset:(CGFloat)offset {
    if (offset < ABCSwipeableTableViewCellNoOffset - threshold &&
        self.rightTriggerColor) {
        return self.rightTriggerColor;
    }
    else if (offset > ABCSwipeableTableViewCellNoOffset + threshold &&
             self.leftTriggerColor) {
        return self.leftTriggerColor;
    }
    return self.defaultColor;
}

- (void)setDefaultColor:(UIColor *)defaultColor {
    _defaultColor = defaultColor;
    [self setNeedsLayout];
}

- (void)setLeftTriggerColor:(UIColor *)leftTriggerColor {
    _leftTriggerColor = leftTriggerColor;
    [self setNeedsLayout];
}

- (void)setRightTriggerColor:(UIColor *)rightTriggerColor {
    _rightTriggerColor = rightTriggerColor;
    [self setNeedsLayout];
}

@end
