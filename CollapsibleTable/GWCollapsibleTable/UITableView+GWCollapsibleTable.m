//
//  UITableView+GWCollapsibleTable.m
//  CollapsibleTable
//
//  Created by Greg Wang on 13-1-4.
//  Copyright (c) 2013年 Greg Wang. All rights reserved.
//

#import "UITableView+GWCollapsibleTable.h"
#import "GWCollapsibleTable.h"
#import "objc/runtime.h"


static NSString * const GWExpandedSectionsSet = @"GWExpendedSectionsSet";


@interface UITableView ()

@property (nonatomic, strong) NSMutableIndexSet *mutableExpandedSections;

@end


@implementation UITableView (GWCollapsibleTable)

#pragma mark - Collapsing & Expanding Section

- (void)toggleSection:(NSInteger)section
{
    [self toggleSection:section callDelegateMethods:YES];
}

- (void)toggleSection:(NSInteger)section callDelegateMethods:(BOOL)callDelegate
{
    if ([self.collapsibleTableDataSource tableView:self canCollapseSection:section]) {
        // Prepare index paths
        NSArray *bodyIndexPathes = [self bodyRowIndexPathesForHeaderSection:section];
        // Expand or collapse
        if ([self.mutableExpandedSections containsIndex:section]) {
            if (callDelegate && [self.collapsibleTableDelegate respondsToSelector:@selector(tableView:willCollapseSection:)]) {
                [self.collapsibleTableDelegate tableView:self willCollapseSection:section];
            }
            // Collapse the section
            [self.mutableExpandedSections removeIndex:section];
            [self deleteRowsAtIndexPaths:bodyIndexPathes withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            if (callDelegate && [self.collapsibleTableDelegate respondsToSelector:@selector(tableView:willExpandSection:)]) {
                [self.collapsibleTableDelegate tableView:self willExpandSection:section];
            }
            // Expand the section
            [self.mutableExpandedSections addIndex:section];
            [self insertRowsAtIndexPaths:bodyIndexPathes withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - Getters & Setters

- (NSMutableIndexSet *)mutableExpandedSections
{
	NSMutableIndexSet *mutableExpandedSections =
        objc_getAssociatedObject(self, (__bridge const void *)(GWExpandedSectionsSet));
	if (mutableExpandedSections == nil) {
		mutableExpandedSections = [[NSMutableIndexSet alloc] init];
		[self setMutableExpandedSections:mutableExpandedSections];
	}
	return mutableExpandedSections;
}

- (NSIndexSet *)expandedSections
{
	return [self.mutableExpandedSections copy];
}

- (id<GWCollapsibleTableDataSource>)collapsibleTableDataSource
{
    if (self.dataSource != nil && [self.dataSource conformsToProtocol:@protocol(GWCollapsibleTableDataSource)]) {
        return (id<GWCollapsibleTableDataSource>)self.dataSource;
    }
    return nil;
}

- (id<GWCollapsibleTableDelegate>)collapsibleTableDelegate
{
    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(GWCollapsibleTableDelegate)]) {
        return (id<GWCollapsibleTableDelegate>)self.delegate;
    }
    return nil;
}

- (void)setMutableExpandedSections:(NSMutableIndexSet *)mutableExpandedSections
{
	objc_setAssociatedObject(self,
                             (__bridge const void *)(GWExpandedSectionsSet),
                             nil,
                             OBJC_ASSOCIATION_RETAIN);
	objc_setAssociatedObject(self,
                             (__bridge const void *)(GWExpandedSectionsSet),
                             mutableExpandedSections,
                             OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - UITableView Methods Substitution

- (UITableViewCell *)headerCellForHeaderSection:(NSInteger)section
{
    NSIndexPath *headerSectionIndexPath = [self tableIndexPathForHeaderSection:section];
	UITableViewCell *result = [self cellForRowAtIndexPath:headerSectionIndexPath];
    return result;
}

- (UITableViewCell *)bodyCellForBodyRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *bodyRowIndexPath = [self tableIndexPathForBodyRowIndexPath:indexPath];
	UITableViewCell *result = [self cellForRowAtIndexPath:bodyRowIndexPath];
    return result;
}

#pragma mark Custom Selection

- (void)selectHeaderSection:(NSInteger)section
                   animated:(BOOL)animated
             scrollPosition:(UITableViewScrollPosition)scrollPosition {
    NSIndexPath *selectionIndexPath = [self tableIndexPathForHeaderSection:section];
    [self selectRowAtIndexPath:selectionIndexPath
                      animated:animated
                scrollPosition:scrollPosition];
}

- (void)selectBodyRowAtIndexPath:(NSIndexPath *)indexPath
                        animated:(BOOL)animated
                  scrollPosition:(UITableViewScrollPosition)scrollPosition {
    [self selectBodyRowAtIndexPath:indexPath
                          animated:animated
                    scrollPosition:scrollPosition
  autoExpandingSectionCallDelegate:NO];
}

- (void)selectBodyRowAtIndexPath:(NSIndexPath *)indexPath
                        animated:(BOOL)animated
                  scrollPosition:(UITableViewScrollPosition)scrollPosition
autoExpandingSectionCallDelegate:(BOOL)callDelegate {
    if ([self.mutableExpandedSections containsIndex:indexPath.section] == NO) {
        [self toggleSection:indexPath.section callDelegateMethods:!callDelegate];
    }
    
    NSIndexPath *selectionIndexPath = [self tableIndexPathForBodyRowIndexPath:indexPath];
    [self selectRowAtIndexPath:selectionIndexPath
                      animated:animated
                scrollPosition:scrollPosition];
}

#pragma mark Custom Deselection

- (void)deselectHeaderSection:(NSInteger)section
                     animated:(BOOL)animated {
    NSIndexPath *deselectionIndexPath = [self tableIndexPathForHeaderSection:section];
    [self deselectRowAtIndexPath:deselectionIndexPath
                        animated:animated];
}


- (void)deselectBodyRowAtIndexPath:(NSIndexPath *)indexPath
                          animated:(BOOL)animated {
    if ([self.mutableExpandedSections containsIndex:indexPath.section] == NO) {
        return;
    }
    
    NSIndexPath *deselectionIndexPath = [self tableIndexPathForBodyRowIndexPath:indexPath];
    [self deselectRowAtIndexPath:deselectionIndexPath
                        animated:animated];
}

#pragma mark - Custom Sections Deletion

- (void)deleteHeaderSections:(NSIndexSet *)sections
            withRowAnimation:(UITableViewRowAnimation)animation {

    __block NSInteger shiftingOffset = 0;
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        NSInteger currentSectionIndex = section - shiftingOffset;
        [self deleteHeaderSectionIndex:currentSectionIndex];
        shiftingOffset += 1;
    }];
    [self deleteSections:sections withRowAnimation:animation];
}

#pragma mark - Custom Sections Insertion

- (void)insertHeaderSections:(NSIndexSet *)sections
            withRowAnimation:(UITableViewRowAnimation)animation {
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        [self insertHeaderSectionIndex:section];
    }];
    [self insertSections:sections withRowAnimation:animation];
}

#pragma mark - Collapsible Table View Indexation

- (NSArray *)bodyRowIndexPathesForHeaderSection:(NSInteger)section {
    NSUInteger bodyRowsCount = [self.collapsibleTableDataSource tableView:self
                                                numberOfBodyRowsInSection:section];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:bodyRowsCount];
    for (NSInteger row = 1; row <= bodyRowsCount; row++) {
        [result addObject:[NSIndexPath indexPathForRow:row inSection:section]];
    }
    return [result copy];
}

- (NSIndexPath *)tableIndexPathForBodyRowIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *result = [NSIndexPath indexPathForRow:indexPath.row + 1
                                             inSection:indexPath.section];
    return result;
}

- (NSIndexPath *)tableIndexPathForHeaderSection:(NSInteger)section {
    NSIndexPath *result = [NSIndexPath indexPathForRow:0
                                             inSection:section];
    return result;
}

#pragma mark Delete Expanded Section Index

- (void)deleteHeaderSectionIndex:(NSInteger)index {
    [self.mutableExpandedSections shiftIndexesStartingAtIndex:index +1 by:-1];
}

- (void)insertHeaderSectionIndex:(NSInteger)index {
    [self.mutableExpandedSections shiftIndexesStartingAtIndex:index by:+1];
}

@end
