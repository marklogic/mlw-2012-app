/*
    MLWSponsorListController.m
	MarkLogic World
	Created by Ryan Grimm on 3/13/12.

	Copyright 2012 MarkLogic

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

#import "MLWSponsorListController.h"
#import "MLWAppDelegate.h"
#import "MLWSponsorView.h"
#import "MLWSponsorDetailViewController.h"
#import "UITableView+helpers.h"
#import <QuartzCore/QuartzCore.h>

@interface MLWSponsorListController ()
- (MLWSponsorView *)sponsorViewForIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UIView *noResultsView;
@property (nonatomic, retain) NSArray *sponsors;

- (void)refreshResults;
@end

@implementation MLWSponsorListController

@synthesize tableView = _tableView;
@synthesize loadingView = _loadingView;
@synthesize noResultsView = _noResultsView;
@synthesize sponsors = _sponsors;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshResults) name:UIApplicationDidBecomeActiveNotification object:nil];

		self.navigationItem.title = @"Sponsors";
		self.tabBarItem.title = @"Sponsors";
		self.tabBarItem.image = [UIImage imageNamed:@"badge"];
    }
    return self;
}

- (void)loadView {
	self.view = [[[UIView alloc] init] autorelease];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	self.loadingView = [[[UIView alloc] init] autorelease];
	self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.loadingView.backgroundColor = [UIColor blackColor];
	self.loadingView.alpha = 1.0f;
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.center = self.loadingView.center;
	spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	[spinner startAnimating];
	[self.loadingView addSubview:spinner];
    [spinner release];

	self.noResultsView = [[[UIView alloc] initWithFrame:self.view.frame] autorelease];
	self.noResultsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.noResultsView.backgroundColor = [UIColor clearColor];
	UILabel *noResultsLabel = [[UILabel alloc] initWithFrame:self.view.frame];
	noResultsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	noResultsLabel.backgroundColor = [UIColor clearColor];
	noResultsLabel.text = @"No Sponsors";
	noResultsLabel.textAlignment = UITextAlignmentCenter;
	noResultsLabel.font = [UIFont boldSystemFontOfSize:30];
	noResultsLabel.textColor = [UIColor whiteColor];
	[self.noResultsView addSubview:noResultsLabel];
	[noResultsLabel release];

	self.tableView = [[[UITableView alloc] init] autorelease];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.tableView applyBackground];
	[self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL) animated {
	[self refreshResults];

	[super viewWillAppear:animated];
}

- (void)refreshResults {
	if(self.sponsors.count > 0) {
		return;
	}

	MLWAppDelegate *appDelegate = (MLWAppDelegate *)[UIApplication sharedApplication].delegate;
	MLWConference *conference = appDelegate.conference;
	BOOL cached = [conference fetchSponsors:^(NSArray *sponsors, NSError *error) {
		if(sponsors.count == 0) {
			self.noResultsView.frame = self.view.frame;
			[self.view addSubview:self.noResultsView];
			self.sponsors = [NSArray array];
		}
		else {
			NSMutableArray *sponsorViews = [NSMutableArray arrayWithCapacity:sponsors.count];
			for(MLWSponsor *sponsor in sponsors) {
				[sponsorViews addObject:[[[MLWSponsorView alloc] initWithSponsor:sponsor] autorelease]];
			}

			NSMutableArray *groups = [NSMutableArray arrayWithCapacity:sponsorViews.count];
			NSString *lastLevel = [((MLWSponsorView *)[sponsorViews objectAtIndex:0]).sponsor.level copy];
			NSMutableArray *sponsorsInGroup = [NSMutableArray arrayWithCapacity:6];

			for(MLWSponsorView *sponsorView in sponsorViews) {
				if([sponsorView.sponsor.level isEqualToString:lastLevel] == NO) {
					[groups addObject:[NSArray arrayWithArray:sponsorsInGroup]];
					[sponsorsInGroup removeAllObjects];
					[lastLevel release];
					lastLevel = [sponsorView.sponsor.level copy];
				}

				[sponsorsInGroup addObject:sponsorView];
			}

			[groups addObject:[NSArray arrayWithArray:sponsorsInGroup]];
			[lastLevel release];
			self.sponsors = groups;
		}

		[self.tableView reloadData];
		[UIView transitionWithView:self.loadingView duration:0.5f options:UIViewAnimationOptionCurveLinear animations:^{
			self.loadingView.alpha = 0.0f;
		}
		completion:^(BOOL finished) {
			[self.loadingView removeFromSuperview];
		}];
	}];

	[self.noResultsView removeFromSuperview];
	if(!cached) {
		self.loadingView.frame = self.view.frame;
		[self.view addSubview:self.loadingView];
		self.loadingView.alpha = 1.0f;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}

	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *) tableView {
	return self.sponsors.count;
}

- (NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
	NSArray *levelSponsors = [self.sponsors objectAtIndex:section];
	return levelSponsors.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSArray *sponsorViews = [self.sponsors objectAtIndex:section];
	return ((MLWSponsorView *)[sponsorViews objectAtIndex:0]).sponsor.level;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 20;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return [tableView createHeaderForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return 44;
	}

	MLWSponsorView *sponsorView = [self sponsorViewForIndexPath:indexPath];
	return [sponsorView calculatedHeightWithWidth:self.view.frame.size.width];
}

- (UITableViewCell *)tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		cell.textLabel.text = [self sponsorViewForIndexPath:indexPath].sponsor.name;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return cell;
	}

	for(UIView *view in cell.contentView.subviews) {
		[view removeFromSuperview];
	}
	MLWSponsorView *sponsorView = [self sponsorViewForIndexPath:indexPath];
	sponsorView.frame = cell.contentView.frame;
	[cell.contentView addSubview:sponsorView];

	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
	cell.layer.borderWidth = 0.5f;
	cell.backgroundColor = [UIColor whiteColor];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		MLWSponsorDetailViewController *sponsorDetailController = [[MLWSponsorDetailViewController alloc] initWithSponsorView:[self sponsorViewForIndexPath:indexPath]];
		[self.navigationController pushViewController:sponsorDetailController animated:YES];
		[sponsorDetailController release];
	}
	else {
		[[UIApplication sharedApplication] openURL:[self sponsorViewForIndexPath:indexPath].sponsor.websiteURL];
	}

	return nil;
}

- (MLWSponsorView *)sponsorViewForIndexPath:(NSIndexPath *)indexPath {
	NSArray *groupSponsors = [self.sponsors objectAtIndex:indexPath.section];
	MLWSponsorView *view = [groupSponsors objectAtIndex:indexPath.row];
	return view;
}


- (void)viewDidUnload {
	self.tableView = nil;
	self.sponsors = nil;
	self.loadingView = nil;
	self.noResultsView = nil;

	[super viewDidUnload];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	self.tableView = nil;
	self.sponsors = nil;
	self.loadingView = nil;
	self.noResultsView = nil;

	[super dealloc];
}

@end
