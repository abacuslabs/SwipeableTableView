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

/**
 @discussion The block that is called when a swipe is actually completed.
 For a "parent" cell, this is the place action should be taken on all items
 represented by "child" cells as well.
 */
@property (nonatomic, copy) void(^triggerHandler)(AbacusSwipeableTableViewCellDirection);

@property (nonatomic, copy) void(^onSwipeHandler)(AbacusSwipeableTableViewCell *c, CGFloat offset, BOOL animated);

/**
 @discussion A Block that when executed is expected to return an NSArray of
 AbacusSwipeableTableViewCell instances. These instances will be offset to the same value
 as this cell is currently being swiped.
 
 This is the block that "defines" an instance of this cell as a "parent" cell. The instances returned
 by this block, are the cells that are visually its "children" (i.e. they will follow the visual swipe effect)
 */
@property (nonatomic, copy) NSArray *(^childTableViewCells)();

- (void)setSwipeOffsetPercentage:(CGFloat)offset
                        animated:(BOOL)animated
               completionHandler:(void(^)())completionHandler;

@end
