To make an AbacusSwipeableTableViewCell swipeable, set its directions
```
cell.swipeableDirections = AbacusSwipeableTableViewCellDirectionRight | AbacusSwipeableTableViewCellDirectionLeft;
```

Set its left and right trigger color
```
cell.leftTriggerColor = [UIColor redColor];
cell.rightTriggerColor = [UIColor purpleColor];
```

You can set its left and right trigger views, which are the views revealed when the cell is swiped
```
UILabel *l = [[UILabel alloc] init];
l.text = @"left";
cell.leftTriggerView = l;

UILabel *r = [[UILabel alloc] init];
r.text = @"right";
cell.rightTriggerView = r;
```


To take an action once a swipe has occured, set a triggerHandler
```
cell.triggerHandler = ^(AbacusSwipeableTableViewCellDirection dir) {
    if (dir == AbacusSwipeableTableViewCellDirectionLeft) {
        // do some action
    }
    else {
        // do some other action
    }
};
```


To turn an AbacusSwipeableTableViewCell into a "header" type cell, set its childTableViewCells to a block which returns instances whose swipe offsets it should dictate.

```
cell.childTableViewCells = ^NSArray*() {
    NSArray *childrenCell = ...;
    return childrenCell;
};
```

