//
//  NSObject+GWCollapsibleTable.m
//  CollapsibleTable
//
//  Created by Greg Wang on 13-1-3.
//  Copyright (c) 2013年 Greg Wang. All rights reserved.
//

#import "NSObject+GWCollapsibleTable.h"
#import "GWCollapsibleTable.h"
#import "objc/runtime.h"

static NSString * const GWCollapsedSectionsSet = @"GWCollapsedSectionsSet";

@implementation NSObject (GWCollapsibleTable)

#pragma mark - Getter & Setter

- (NSMutableIndexSet *)getCollapsedSections
{
	NSMutableIndexSet *collapsedSectionsSet = objc_getAssociatedObject(self, (__bridge const void *)(GWCollapsedSectionsSet));
	if (collapsedSectionsSet == nil) {
		collapsedSectionsSet = [[NSMutableIndexSet alloc] init];
		[self setCollapsedSections:collapsedSectionsSet];
	}
	return collapsedSectionsSet;
}

- (NSIndexSet *)collapsedSections
{
	return [self getCollapsedSections];
}

- (void)setCollapsedSections:(NSIndexSet *)collapsedSections
{
	objc_setAssociatedObject(self, (__bridge const void *)(GWCollapsedSectionsSet), nil, OBJC_ASSOCIATION_RETAIN);
	objc_setAssociatedObject(self, (__bridge const void *)(GWCollapsedSectionsSet), collapsedSections, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - General Helpers

- (id<GWCollapsibleTableDataSource>)collapsibleTableDataSourceWithTableView:(UITableView *)tableView
{
	if (tableView.dataSource != nil && [tableView.dataSource conformsToProtocol:@protocol(GWCollapsibleTableDataSource)]) {
		return (id<GWCollapsibleTableDataSource>)tableView.dataSource;
	}
	abort();
	return nil;
}

- (id<GWCollapsibleTableDelegate>)collapsibleTableDelegateWithTableView:(UITableView *)tableView
{
	if (tableView.delegate != nil && [tableView.delegate conformsToProtocol:@protocol(GWCollapsibleTableDelegate)]) {
		return (id<GWCollapsibleTableDelegate>)tableView.delegate;
	}
	abort();
	return nil;
}

- (void)toggleSection:(NSInteger)section
{
	// TODO
}

#pragma mark - Table View Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	id<GWCollapsibleTableDataSource> dataSource = [self collapsibleTableDataSourceWithTableView:tableView];
	if ([dataSource tableView:tableView canCollapseSection:indexPath.section]) {
		if (indexPath.row == 0) {
			return [dataSource tableView:tableView headerCellForCollapsibleSection:indexPath.section];
		}
		return [dataSource tableView:tableView bodyCellForRowAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section]];
	}
	return [dataSource tableView:tableView bodyCellForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id<GWCollapsibleTableDataSource> dataSource = [self collapsibleTableDataSourceWithTableView:tableView];
	if ([dataSource tableView:tableView canCollapseSection:section]) {
		if ([self.collapsedSections containsIndex:section]) {
			return 1;
		}
		return [dataSource tableView:tableView numberOfBodyRowsInSection:section] + 1;
	}
	return [dataSource tableView:tableView numberOfBodyRowsInSection:section];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	id<GWCollapsibleTableDataSource> dataSource = [self collapsibleTableDataSourceWithTableView:tableView];
	id<GWCollapsibleTableDelegate> delegate = [self collapsibleTableDelegateWithTableView:tableView];
	if ([dataSource tableView:tableView canCollapseSection:indexPath.section]) {
		if (indexPath.row == 0) {
			[self toggleSection:indexPath.section];
		}
		else {
			[delegate tableView:tableView didSelectBodyRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
		}
	}
	else {
		[delegate tableView:tableView didSelectBodyRowAtIndexPath:indexPath];
	}
}

@end
