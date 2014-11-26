#import "ABCSwipeableTableViewCell.h"



/**
 Created by Jan Sichermann on 11/26/14. Copyright (c) 2014 Abacus. All rights reserved.
 */



@interface ABCSwipeableTableViewCell ()
<
UIGestureRecognizerDelegate
>

@property (nonatomic) UILabel *leftLabel;
@property (nonatomic) UILabel *rightLabel;
@property (nonatomic) CGFloat offset;
@end



static const CGFloat threshold = 0.25f;
static const CGFloat labelInset = 10.f;
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
    
    
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.leftLabel = [[UILabel alloc] init];
    [v addSubview:self.leftLabel];
    
    self.rightLabel = [[UILabel alloc] init];
    [v addSubview:self.rightLabel];
    
    self.backgroundView = v;
    
    
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
    self.leftLabel.text = nil;
    self.rightLabel.text = nil;
    [self setSwipeOffsetPercentage:ABCSwipeableTableViewCellNoOffset
                          animated:NO
                 completionHandler:nil];
    [self setNeedsLayout];
}

- (void)layoutSubviewsAnimated:(BOOL)animated
             completionHandler:(void(^)())completionHandler {
    [self _layoutContentView:animated
           completionHandler:completionHandler];
    [self _updateBackgroundColor:animated];
    [self layoutLabels:animated];
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

- (void)_layoutLabel:(UILabel *)label
            withSize:(CGSize)s
                left:(CGFloat)left
               alpha:(CGFloat)alpha
            animated:(BOOL)animated {
    
    void(^layoutBlock)() = ^{
        label.frame = CGRectMake(left,
                                          0.f,
                                          s.width,
                                          self.backgroundView.bounds.size.height);
        
    };
    
    void(^visibilityBlock)() = nil;
    if (fabs(label.alpha - alpha) < 0.01) {
        visibilityBlock = ^{
            label.alpha = alpha;
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

- (void)_layoutLeftLabel:(BOOL)animated {
    
    CGSize s = [self.leftLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    
    CGFloat left = MAX(labelInset,
                           self.contentView.frame.origin.x - s.width - labelInset);
    
    CGFloat alpha = 1.f;
    if (fabs(self.contentView.frame.origin.x - ABCSwipeableTableViewCellOffsetRight * self.bounds.size.width)
        < 0.01) {
        alpha = 0.f;
    }
    
    self.leftLabel.hidden = self.contentView.frame.origin.x < -threshold;
    
    [self _layoutLabel:self.leftLabel
              withSize:s
                  left:left
                 alpha:alpha
              animated:animated];
}

- (void)_layoutRightLabel:(BOOL)animated {
    
    CGFloat left = MIN(self.backgroundView.bounds.size.width - self.rightLabel.bounds.size.width - labelInset,
                            self.contentView.frame.origin.x + self.contentView.frame.size.width + labelInset);
    
    CGSize s = [self.rightLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    
    
    CGFloat alpha = 1.f;
    if (fabs(self.contentView.frame.origin.x - ABCSwipeableTableViewCellOffsetLeft * self.bounds.size.width) < 0.01) {
        alpha = 0.f;
    }
    
    self.rightLabel.hidden = self.contentView.frame.origin.x > threshold;
    
    [self _layoutLabel:self.rightLabel
              withSize:s
                  left:left
                 alpha:alpha
              animated:animated];
    
    
}

- (void)layoutLabels:(BOOL)animated {
    [self _layoutLeftLabel:animated];
    [self _layoutRightLabel:animated];
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

- (void)setLeftAttributedTitle:(NSAttributedString *)leftAttributedTitle {
    self.leftLabel.attributedText = leftAttributedTitle;
    [self setNeedsLayout];
}

- (NSAttributedString *)leftAttributedTitle {
    return self.leftLabel.attributedText;
}

- (void)setRightAttributedTitle:(NSAttributedString *)rightAttributedTitle {
    self.rightLabel.attributedText = rightAttributedTitle;
    [self setNeedsLayout];
}

- (NSAttributedString *)rightAttributedTitle {
    return self.rightLabel.attributedText;
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
