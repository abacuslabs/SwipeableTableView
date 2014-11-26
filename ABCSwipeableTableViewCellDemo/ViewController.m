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

@end



@implementation ViewController

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(__unused NSIndexPath *)indexPath {
    NSString *identifier = NSStringFromClass([ABCSwipeableTableViewCell class]);
    UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (c == nil) {
        c = [[ABCSwipeableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:identifier];
    }
    return c;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(__unused NSIndexPath *)indexPath {
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

@end
