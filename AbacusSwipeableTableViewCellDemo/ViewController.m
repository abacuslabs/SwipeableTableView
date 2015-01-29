#import "ViewController.h"
#import "AbacusSwipeableTableViewCell.h"



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
    
    UILabel *l = [[UILabel alloc] init];
    l.text = @"left";
    cell.leftTriggerView = l;
    
    UILabel *r = [[UILabel alloc] init];
    r.text = @"right";
    cell.rightTriggerView = r;
    cell.leftTriggerViewInsets = UIEdgeInsetsMake(36.f, 30.f, 0.f, 0.f);
    cell.rightTriggerViewInsets = UIEdgeInsetsMake(0.f, 30.f, 0.f, 30.f);
    
    cell.triggerHandler = ^(AbacusSwipeableTableViewCellDirection dir) {
        self.swipedCells = [self.swipedCells setByAddingObject:@(indexPath.row)];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    };
    
    if (indexPath.row == 0) {
        [cell addChildSection:0
                  inTableView:self.tableView];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.swipedCells containsObject:@(indexPath.row)]) {
        return 0.f;
    }
    return 128.f;
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
