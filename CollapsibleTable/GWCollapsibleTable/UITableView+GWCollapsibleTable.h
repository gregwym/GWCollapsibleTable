//
//  UITableView+GWCollapsibleTable.h
//  CollapsibleTable
//
//  Created by Greg Wang on 13-1-4.
//  Copyright (c) 2013年 Greg Wang. All rights reserved.
//

@interface UITableView (GWCollapsibleTable)

@property (nonatomic, strong, readonly) NSIndexSet *expandedSections;
- (NSMutableIndexSet *)getExpendedSections;

@end
