//
//  UITableView+GWCollapsibleTable.h
//  CollapsibleTable
//
//  Created by Greg Wang on 13-1-4.
//  Copyright (c) 2013年 Greg Wang. All rights reserved.
//


@protocol GWCollapsibleTableDataSource,  GWCollapsibleTableDelegate;


@interface UITableView (GWCollapsibleTable)

@property (nonatomic, strong, readonly) NSIndexSet *expandedSections;
@property (nonatomic, strong, readonly) id<GWCollapsibleTableDataSource> collapsibleTableDataSource;
@property (nonatomic, strong, readonly) id<GWCollapsibleTableDelegate> collapsibleTableDelegate;

- (void)toggleSection:(NSInteger)section;

- (UITableViewCell *)headerCellForSection:(NSInteger)section;
- (UITableViewCell *)bodyCellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)selectHeaderSection:(NSInteger)section
                   animated:(BOOL)animated
             scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void)deselectHeaderSection:(NSInteger)section
                     animated:(BOOL)animated;

- (void)selectBodyRowAtIndexPath:(NSIndexPath *)indexPath
                        animated:(BOOL)animated
                  scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void)deselectBodyRowAtIndexPath:(NSIndexPath *)indexPath
                          animated:(BOOL)animated;

@end
