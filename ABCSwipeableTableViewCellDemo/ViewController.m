//
//  ViewController.m
//  ABCSwipeableTableViewCellDemo
//
//  Created by Jan Sichermann on 11/26/14.
//  Copyright (c) 2014 Abacus. All rights reserved.
//

#import "ViewController.h"
#import "ABCSwipeableTableViewCell.h"



@interface ViewController ()
@property (nonatomic) NSSet *swipedCells;
@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.swipedCells = [NSSet set];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = NSStringFromClass([ABCSwipeableTableViewCell class]);
    ABCSwipeableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell != nil) {
        cell = [[ABCSwipeableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:identifier];
    }
    
    
    cell.swipeableDirections = ABCSwipeableTableViewCellDirectionRight | ABCSwipeableTableViewCellDirectionLeft;
    cell.leftAttributedTitle =
    [[NSAttributedString alloc] initWithString:@"delete"
                                    attributes:nil];
    cell.triggerHandler = ^(ABCSwipeableTableViewCellDirection dir) {
        self.swipedCells = [self.swipedCells setByAddingObject:@(indexPath.row)];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    };

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.swipedCells containsObject:@(indexPath.row)]) {
        return 0.f;
    }
    return [ABCSwipeableTableViewCell heightForModel:nil
                                         inTableView:tableView];
}

- (NSInteger)numberOfSectionsInTableView:(__unused UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(__unused UITableView *)tableView
 numberOfRowsInSection:(__unused NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(__unused NSIndexPath *)indexPath {
    self.swipedCells = [NSSet set];
    [tableView reloadData];
}

@end
