@import UIKit;



/**
 Created by Jan Sichermann on 11/26/14. Copyright (c) 2014 Abacus. All rights reserved.
 */


typedef NS_OPTIONS(NSInteger, AbacusSwipeableTableViewCellDirection) {
    AbacusSwipeableTableViewCellDirectionNone = 0,
    AbacusSwipeableTableViewCellDirectionLeft,
    AbacusSwipeableTableViewCellDirectionRight
};



@protocol AbacusSwipeableTableViewCellReusableView <NSObject>

@optional
- (void)prepareForReuse;

@end



extern CGFloat AbacusSwipeableTableViewCellNoOffset;
extern CGFloat AbacusSwipeableTableViewCellOffsetRight;
extern CGFloat AbacusSwipeableTableViewCellOffsetLeft;



@interface AbacusSwipeableTableViewCell : UITableViewCell
@property (nonatomic) AbacusSwipeableTableViewCellDirection swipeableDirections;

@property (nonatomic) UIView *leftTriggerView;
- (void)setReusableLeftTriggerView:(UIView <AbacusSwipeableTableViewCellReusableView> *)reusableView;
@property (nonatomic) UIView *rightTriggerView;
- (void)setReusableRightTriggerView:(UIView <AbacusSwipeableTableViewCellReusableView> *)reusableView;

@property (nonatomic) UIEdgeInsets leftTriggerViewInsets;
@property (nonatomic) UIEdgeInsets rightTriggerViewInsets;

@property (nonatomic) UIColor *defaultColor;

@property (nonatomic) UIColor *leftTriggerColor;
@property (nonatomic) UIColor *rightTriggerColor;

@property (nonatomic, copy) void(^triggerHandler)(AbacusSwipeableTableViewCellDirection);
@property (nonatomic, copy) void(^onSwipeHandler)(AbacusSwipeableTableViewCell *c, CGFloat offset, BOOL animated);
@property (nonatomic, copy) NSArray *(^childTableViewCells)();

- (void)setSwipeOffsetPercentage:(CGFloat)offset
                        animated:(BOOL)animated
               completionHandler:(void(^)())completionHandler;

@end
