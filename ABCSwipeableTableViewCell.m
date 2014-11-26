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
static const CGFloat animationDuration = 0.3f;

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
    
    
    v.backgroundColor = [UIColor redColor];
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
    self.contentView.frame = CGRectMake(self.offset * self.bounds.size.width,
                                        0.f,
                                        self.contentView.bounds.size.width,
                                        self.contentView.bounds.size.height);

    [self layoutLabels];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.leftLabel.text = nil;
    self.rightLabel.text = nil;
    [self setSwipeOffsetPercentage:ABCSwipeableTableViewCellNoOffset];
    [self setNeedsLayout];
}

- (void)layoutLabels {
    [self.leftLabel sizeToFit];
    
    CGFloat leftLeft = MAX(labelInset,
                           self.contentView.frame.origin.x - self.leftLabel.bounds.size.width - labelInset);
    
    self.leftLabel.frame = CGRectMake(leftLeft,
                                      0.f,
                                      self.leftLabel.bounds.size.width,
                                      self.backgroundView.bounds.size.height);
    
    self.leftLabel.hidden = self.contentView.frame.origin.x < -threshold;
    if (fabs(self.contentView.frame.origin.x - ABCSwipeableTableViewCellOffsetRight * self.bounds.size.width)
        < 0.01 &&
        self.leftLabel.alpha != 0.f) {
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             self.leftLabel.alpha = 0.f;
                         }];
    }
    else if (self.leftLabel.alpha != 1.f) {
        self.leftLabel.alpha = 1.f;
    }
    
    [self.rightLabel sizeToFit];
    
    CGFloat rightLeft = MIN(self.backgroundView.bounds.size.width - self.rightLabel.bounds.size.width - labelInset,
                            self.contentView.frame.origin.x + self.contentView.frame.size.width + labelInset);
    
    self.rightLabel.frame = CGRectMake(rightLeft,
                                       0.f,
                                       self.rightLabel.bounds.size.width,
                                       self.backgroundView.bounds.size.height);
    self.rightLabel.hidden = self.contentView.frame.origin.x > threshold;
    self.rightLabel.alpha = 1.f;
    
    if (fabs(self.contentView.frame.origin.x - ABCSwipeableTableViewCellOffsetLeft * self.bounds.size.width) < 0.01 &&
        self.rightLabel.alpha != 0.f) {
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             self.rightLabel.alpha = 0.f;
                         }];
    }
    else if (self.rightLabel.alpha != 1.f) {
        self.rightLabel.alpha = 1.f;
    }
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
        [self setSwipeOffsetPercentage:offset];
    }
    else if (pr.state == UIGestureRecognizerStateCancelled) {
        [self setSwipeOffsetPercentage:ABCSwipeableTableViewCellNoOffset];
    }
    else if (pr.state == UIGestureRecognizerStateEnded) {
        if (offset > threshold || offset < -threshold) {
            [self setSwipeOffsetPercentage:dir];
            [self swipeTriggered:dir];
        }
        else {
            [self setSwipeOffsetPercentage:ABCSwipeableTableViewCellNoOffset];
        }
    }
}

- (void)setSwipeOffsetPercentage:(CGFloat)offset {
    self.offset = offset;
    [self setNeedsLayout];
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

@end
