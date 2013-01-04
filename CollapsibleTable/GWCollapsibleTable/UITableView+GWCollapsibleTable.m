//
//  UITableView+GWCollapsibleTable.m
//  CollapsibleTable
//
//  Created by Greg Wang on 13-1-4.
//  Copyright (c) 2013年 Greg Wang. All rights reserved.
//

#import "UITableView+GWCollapsibleTable.h"
#import "objc/runtime.h"

static NSString * const GWExpendedSectionsSet = @"GWExpendedSectionsSet";

@implementation UITableView (GWCollapsibleTable)

#pragma mark - Getter & Setter

- (NSMutableIndexSet *)getExpendedSections
{
	NSMutableIndexSet *expandedSectionsSet = objc_getAssociatedObject(self, (__bridge const void *)(GWExpendedSectionsSet));
	if (expandedSectionsSet == nil) {
		expandedSectionsSet = [[NSMutableIndexSet alloc] init];
		[self setExpendedSections:expandedSectionsSet];
	}
	return expandedSectionsSet;
}

- (NSIndexSet *)expandedSections
{
	return [self getExpendedSections];
}

- (void)setExpendedSections:(NSIndexSet *)expandedSections
{
	objc_setAssociatedObject(self, (__bridge const void *)(GWExpendedSectionsSet), nil, OBJC_ASSOCIATION_RETAIN);
	objc_setAssociatedObject(self, (__bridge const void *)(GWExpendedSectionsSet), expandedSections, OBJC_ASSOCIATION_RETAIN);
}

@end
