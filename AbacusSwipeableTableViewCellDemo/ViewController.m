/**
 The MIT License (MIT)
 
 Copyright (c) 2015 Abacus Labs, Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */



#import "ViewController.h"
#import "AbacusSwipeableTableViewCell.h"



@interface ViewController ()

@property (atomic) NSArray *swipedCells;

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.swipedCells = @[];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = NSStringFromClass([AbacusSwipeableTableViewCell class]);
    AbacusSwipeableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[AbacusSwipeableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:identifier];
    }
    
    cell.defaultColor = [UIColor darkGrayColor];
    cell.leftTriggerColor = [UIColor redColor];
    cell.rightTriggerColor = [UIColor purpleColor];
    cell.swipeableDirections = AbacusSwipeableTableViewCellDirectionRight | AbacusSwipeableTableViewCellDirectionLeft;
    if (indexPath.row == 0) {
        cell.contentView.backgroundColor = [UIColor blueColor];
    }
    else {
        cell.contentView.backgroundColor = [UIColor colorWithHue:(arc4random() % 100) / 100.f saturation:0.4f brightness:0.9f alpha:1.f];
    }
    
    UILabel *l = [[UILabel alloc] init];
    l.text = @"left";
    cell.leftTriggerView = l;
    
    UILabel *r = [[UILabel alloc] init];
    r.text = @"right";
    cell.rightTriggerView = r;
    cell.leftTriggerViewInsets = UIEdgeInsetsMake(0.f, 30.f, -10.f, 0.f);
    cell.rightTriggerViewInsets = UIEdgeInsetsMake(0.f, 30.f, 0.f, 30.f);
    
    if (indexPath.row == 0) { // For simplicity's sake, every section's first row is treated as a "header"
        cell.triggerHandler = ^(AbacusSwipeableTableViewCellDirection dir) {
            NSInteger numRows = [self.tableView numberOfRowsInSection:indexPath.section];
            NSMutableArray *indices = [NSMutableArray arrayWithCapacity:numRows];
            for (NSInteger i = 0; i < numRows; i++) {
                [indices addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
            }
            
            // For simplicity's sake, all we do here is actually collapse the cells,
            // however this would be the place to take action on all the items represented
            // by this section
            self.swipedCells = [self.swipedCells arrayByAddingObjectsFromArray:indices];
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        };
        
        __weak ViewController *weakSelf = self;
        cell.childTableViewCells = ^NSArray*() {
            ViewController *strongSelf = weakSelf;
            NSArray *visibleCells = [strongSelf.tableView visibleCells];
            NSMutableArray *cells = [NSMutableArray arrayWithCapacity:visibleCells.count];
            for (UITableViewCell *c in visibleCells) {
                if ([strongSelf.tableView indexPathForCell:c].section == indexPath.section) {
                    [cells addObject:c];
                }
            }
            return cells.copy;
        };
    }
    else { // For simplicity's sake, every section other than the first, is treated as a "child"
        cell.triggerHandler = ^(AbacusSwipeableTableViewCellDirection dir) {
            self.swipedCells = [self.swipedCells arrayByAddingObject:indexPath];
            // Calling beginUpdates and endUpdates in succession
            // triggers the tableView to call heightForRowAtIndexPath: on its delegate
            // and in turn animate the collapsing of cells whose height is now 0
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        };
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    for (NSIndexPath *ip in self.swipedCells) {
        if ([ip compare:indexPath] == NSOrderedSame) {
            return 0.f;
        }
    }
    
    if (indexPath.row == 0) {
        return 64.f;
    }
    
    return 128.f;
}

- (NSInteger)numberOfSectionsInTableView:(__unused UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(__unused UITableView *)tableView
 numberOfRowsInSection:(__unused NSInteger)section {
    return 10;
}

- (void)tableView:(__unused UITableView *)tableView
didSelectRowAtIndexPath:(__unused NSIndexPath *)indexPath {
    [self reset];
}

- (void)reset {
    self.swipedCells = @[];
    [self.tableView reloadData];
}

@end
