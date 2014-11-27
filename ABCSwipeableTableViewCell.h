@import UIKit;



/**
 Created by Jan Sichermann on 11/26/14. Copyright (c) 2014 Abacus. All rights reserved.
 */


typedef NS_OPTIONS(NSInteger, ABCSwipeableTableViewCellDirection) {
    ABCSwipeableTableViewCellDirectionNone = 0,
    ABCSwipeableTableViewCellDirectionLeft,
    ABCSwipeableTableViewCellDirectionRight
};



@protocol ABCSwipeableTableViewCellReusableView <NSObject>

@optional
- (void)prepareForReuse;

@end



@interface ABCSwipeableTableViewCell : UITableViewCell
@property (nonatomic) ABCSwipeableTableViewCellDirection swipeableDirections;

@property (nonatomic) UIView<ABCSwipeableTableViewCellReusableView> *leftTriggerView;
@property (nonatomic) UIEdgeInsets leftTriggerViewInsets;
@property (nonatomic) UIColor *leftTriggerColor;

@property (nonatomic) UIView<ABCSwipeableTableViewCellReusableView> *rightTriggerView;
@property (nonatomic) UIEdgeInsets rightTriggerViewInsets;
@property (nonatomic) UIColor *rightTriggerColor;

@property (nonatomic) UIColor *defaultColor;

@property (nonatomic, copy) void(^triggerHandler)(ABCSwipeableTableViewCellDirection);


+ (CGFloat)heightForModel:(id)model
              inTableView:(UITableView *)tableView;

- (void)setSwipeOffsetPercentage:(CGFloat)offset
                        animated:(BOOL)animated
               completionHandler:(void(^)())completionHandler;

@end
