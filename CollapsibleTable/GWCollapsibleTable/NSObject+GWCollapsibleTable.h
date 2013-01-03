//
//  NSObject+GWCollapsibleTable.h
//  CollapsibleTable
//
//  Created by Greg Wang on 13-1-3.
//  Copyright (c) 2013年 Greg Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (GWCollapsibleTable) <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong, readonly) NSIndexSet *collapsedSections;

@end
