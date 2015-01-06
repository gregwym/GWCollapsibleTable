//
//  GWViewController.m
//  CollapsibleTable
//
//  Created by Greg Wang on 13-1-3.
//  Copyright (c) 2013年 Greg Wang. All rights reserved.
//

#import "GWViewController.h"

@interface GWViewController ()

@end

@implementation GWViewController

@synthesize tableView = _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GWCollapsibleTable Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
	return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView headerCellForCollapsibleSection:(NSInteger)section
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"headerCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"headerCell"];
		cell.textLabel.text = @"Header";
		cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableCollapsed"]];
	}
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView bodyCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bodyCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bodyCell"];
		cell.textLabel.text = @"Body";
	}
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfBodyRowsInSection:(NSInteger)section
{
	return 3;
}

#pragma mark - GWCollapsibleTable Delegate

- (void)tableView:(UITableView *)tableView didSelectBodyRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}

- (void)tableView:(UITableView *)tableView willCollapseSection:(NSInteger)section
{
	[tableView headerCellForHeaderSection:section].textLabel.text = @"Collapsed Section";
	[tableView headerCellForHeaderSection:section].accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableCollapsed"]];
}

- (void)tableView:(UITableView *)tableView willExpandSection:(NSInteger)section
{
	[tableView headerCellForHeaderSection:section].textLabel.text = @"Expanded Section";
	[tableView headerCellForHeaderSection:section].accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableExpanded"]];
}

@end
