@import UIKit;



/**
 Created by Jan Sichermann on 11/26/14. Copyright (c) 2014 Abacus. All rights reserved.
 */


typedef NS_OPTIONS(NSInteger, ABCSwipeableTableViewCellDirection) {
    ABCSwipeableTableViewCellDirectionNone = 0,
    ABCSwipeableTableViewCellDirectionLeft,
    ABCSwipeableTableViewCellDirectionRight
};



@interface ABCSwipeableTableViewCell : UITableViewCell
@property (nonatomic) ABCSwipeableTableViewCellDirection swipeableDirections;

+ (CGFloat)heightForModel:(id)model
              inTableView:(UITableView *)tableView;

@end
