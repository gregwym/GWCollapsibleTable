//
//  GWViewController.h
//  CollapsibleTable
//
//  Created by Greg Wang on 13-1-3.
//  Copyright (c) 2013年 Greg Wang. All rights reserved.
//

#import "GWCollapsibleTable.h"

@interface GWViewController : UIViewController <GWCollapsibleTableDelegate, GWCollapsibleTableDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
