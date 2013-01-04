//
//  NSObject+GWCollapsibleTable.m
//  CollapsibleTable
//
//  Created by Greg Wang on 13-1-3.
//  Copyright (c) 2013年 Greg Wang. All rights reserved.
//

#import "NSObject+GWCollapsibleTable.h"
#import "GWCollapsibleTable.h"

@implementation NSObject (GWCollapsibleTable)

#pragma mark - General Helpers

- (id<GWCollapsibleTableDataSource>)collapsibleTableDataSourceWithTableView:(UITableView *)tableView
{
	if (tableView.dataSource != nil && [tableView.dataSource conformsToProtocol:@protocol(GWCollapsibleTableDataSource)]) {
		return (id<GWCollapsibleTableDataSource>)tableView.dataSource;
	}
//	abort();
	return nil;
}

- (id<GWCollapsibleTableDelegate>)collapsibleTableDelegateWithTableView:(UITableView *)tableView
{
	if (tableView.delegate != nil && [tableView.delegate conformsToProtocol:@protocol(GWCollapsibleTableDelegate)]) {
		return (id<GWCollapsibleTableDelegate>)tableView.delegate;
	}
//	abort();
	return nil;
}

- (void)tableView:(UITableView *)tableView toggleSection:(NSInteger)section
{
	id<GWCollapsibleTableDataSource> dataSource = [self collapsibleTableDataSourceWithTableView:tableView];
	id<GWCollapsibleTableDelegate> delegate = [self collapsibleTableDelegateWithTableView:tableView];

	if ([dataSource tableView:tableView canCollapseSection:section]) {
		// Prepare index paths
		NSUInteger numberOfBodyRows = [dataSource tableView:tableView numberOfBodyRowsInSection:section];
		NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:numberOfBodyRows];
		for (NSInteger i = 1; i <= numberOfBodyRows; i++) {
			[indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
		}
		// Expand or collapse
		NSMutableIndexSet *expandedSections = [tableView getExpendedSections];
		if ([expandedSections containsIndex:section]) {
			if ([delegate respondsToSelector:@selector(tableView:willCollapseSection:)]) {
				[delegate tableView:tableView willCollapseSection:section];
			}
			// Collapse the section
			[expandedSections removeIndex:section];
			[tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
		}
		else {
			if ([delegate respondsToSelector:@selector(tableView:willExpandSection:)]) {
				[delegate tableView:tableView willExpandSection:section];
			}
			// Expand the section
			[expandedSections addIndex:section];
			[tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
		}
	}
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
		if (![tableView.expandedSections containsIndex:section]) {
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
			[self tableView:tableView toggleSection:indexPath.section];
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
