/*
    MLWTweetController.m
	MarkLogic World
	Created by Ryan Grimm on 3/9/12.

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

#import "MLWTweetController.h"
#import "MLWAppDelegate.h"
#import "UITableView+helpers.h"
#import "MLWTweet.h"
#import "MLWTweetView.h"
#import <QuartzCore/QuartzCore.h>

@interface MLWTweetController ()
- (void)refreshResults:(UIBarButtonItem *)sender;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UIView *noResultsView;
@property (nonatomic, retain) NSArray *tweets;
@end

@implementation MLWTweetController

@synthesize tableView = _tableView;
@synthesize loadingView = _loadingView;
@synthesize noResultsView = _noResultsView;
@synthesize tweets = _tweets;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if(self) {
		self.navigationItem.title = @"Tweets";
		self.tabBarItem.title = @"Tweets";
		self.tabBarItem.image = [UIImage imageNamed:@"tweets"];
	}
	return self;
}

- (void)loadView {
	UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshResults:)];
	self.navigationItem.rightBarButtonItem = refresh;
	[refresh release];

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
	noResultsLabel.text = @"No Tweets";
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

- (void)viewWillAppear:(BOOL)animated {
	[self refreshResults:nil];
	[super viewWillAppear:animated];
}

- (void)refreshResults:(UIBarButtonItem *)sender {
	self.tweets = nil;
	[self.tableView reloadData];
	self.loadingView.frame = self.view.frame;
	[self.view addSubview:self.loadingView];
	self.loadingView.alpha = 1.0f;

	MLWAppDelegate *appDelegate = (MLWAppDelegate *)[UIApplication sharedApplication].delegate;
	MLWConference *conference = appDelegate.conference;
	[conference fetchTweets:^(NSArray *tweets, NSError *error) {
		if(tweets.count == 0) {
			self.noResultsView.frame = self.view.frame;
			[self.view addSubview:self.noResultsView];
			self.tweets = [NSArray array];
		}
		else {
			self.tweets = tweets;
		}

		[self.tableView reloadData];
		[UIView transitionWithView:self.loadingView duration:0.5f options:UIViewAnimationOptionCurveLinear animations:^{
			self.loadingView.alpha = 0.0f;
		}
		completion:^(BOOL finished) {
			[self.tableView reloadData];
			[self.loadingView removeFromSuperview];
		}];
	}];
	[self.noResultsView removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}

	return YES;
}

#pragma mark - View lifecycle

- (NSInteger)numberOfSectionsInTableView:(UITableView *) tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
	return self.tweets.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return 105;
	}
	return 75;
}

- (UITableViewCell *)tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		MLWTweetView *emptyView = [[MLWTweetView alloc] initWithFrame:cell.contentView.bounds];
		[cell.contentView addSubview:emptyView];
		[emptyView release];
	}

	MLWTweet *tweet = [self.tweets objectAtIndex:indexPath.row];
	MLWTweetView *tweetView = (MLWTweetView *)[cell.contentView.subviews lastObject];
	[tweetView updateTweet:tweet];

	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
	cell.layer.borderWidth = 0.5f;
	cell.backgroundColor = [UIColor whiteColor];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	MLWTweet *tweet = [self.tweets objectAtIndex:indexPath.row];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@/status/%@", tweet.username, tweet.id]]];
	return nil;
}


- (void)viewDidUnload {
	self.tableView = nil;
	self.loadingView = nil;
	self.noResultsView = nil;
	self.tweets = nil;

	[super viewDidUnload];
}

- (void)dealloc {
	self.tableView = nil;
	self.loadingView = nil;
	self.noResultsView = nil;
	self.tweets = nil;

	[super dealloc];
}

@end
