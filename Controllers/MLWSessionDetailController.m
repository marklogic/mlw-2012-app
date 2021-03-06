/*
    MLWSessionDetailController.m
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

#import "MLWSessionDetailController.h"
#import "UITableView+helpers.h"
#import "MLWSpeaker.h"
#import "MLWMySchedule.h"
#import "MLWAppDelegate.h"
#import "MLWSessionSurveyViewController.h"

@interface MLWSessionDetailController ()
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) MLWSession *session;
@property (nonatomic, retain) UIBarButtonItem *highlightButton;
- (void)toggleHighlighting:(UIBarButtonItem *)sender;
- (void)takeSurvey:(UIBarButtonItem *)sender;
@end

@implementation MLWSessionDetailController

@synthesize tableView = _tableView;
@synthesize session = _session;
@synthesize highlightButton;

- (id)initWithSession:(MLWSession *)session {
    self = [super init];
    if(self) {
		self.session = session;

		MLWAppDelegate *appDelegate = (MLWAppDelegate *)[UIApplication sharedApplication].delegate;
		MLWConference *conference = appDelegate.conference;
		if([conference.userSchedule hasSession:self.session]) {
			self.highlightButton = [[[UIBarButtonItem alloc] initWithTitle:@"Unhighlight" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleHighlighting:)] autorelease];
		}
		else {
			self.highlightButton = [[[UIBarButtonItem alloc] initWithTitle:@"Highlight" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleHighlighting:)] autorelease];
		}

		if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 170, 44.01)];
			tools.tintColor = [UIColor colorWithRed:(236.0f/255.0f) green:(125.0f/255.0f) blue:(30.0f/255.0f) alpha:1.0f];

			UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
			UIBarButtonItem *surveyButton = [[UIBarButtonItem alloc] initWithTitle:@"Survey" style:UIBarButtonItemStyleBordered target:self action:@selector(takeSurvey:)];
			NSArray* buttons = [NSArray arrayWithObjects:space, surveyButton, self.highlightButton, nil];
			[tools setItems:buttons animated:NO];
			[space release];
			[surveyButton release];

			self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:tools] autorelease];
			[tools release];
		}
		else {
			self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Survey" style:UIBarButtonItemStylePlain target:self action:@selector(takeSurvey:)] autorelease];
			self.navigationItem.rightBarButtonItem = self.highlightButton;
		}

		nameHeight = 50;
		titleHeight = 44;
		contactHeight = 25;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView {
	self.view = [[[UIView alloc] init] autorelease];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped] autorelease];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.tableView applyBackground];
	[self.view addSubview:self.tableView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}

    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *) tableView {
	int numSections = 2;
	if(self.session.speakers.count > 0) {
		numSections++;
	}
	return numSections;
}

- (NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
	if(section == 0) {
		if(self.session.track != nil) {
			return 5;
		}
		else {
			return 4;
		}
	}
	if(section == 1) {
		return 1;
	}
	if(section == 2) {
		return self.session.speakers.count;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(section == 0) {
		return @"Session Information";
	}
	if(section == 1) {
		return @"Abstract";
	}
	if(section == 2) {
		if(self.session.speakers.count == 1) {
			return @"Presenter";
		}
		else {
			return @"Presenters";
		}
	}
	return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
	if(sectionTitle == nil) {
		return nil;
	}

	UILabel *label = [[UILabel alloc] init];
	label.frame = CGRectMake(20, 6, 300, 30);
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.shadowColor = [UIColor blackColor];
	label.shadowOffset = CGSizeMake(0.0, 2.0);
	label.font = [UIFont boldSystemFontOfSize:16];
	label.text = sectionTitle;

	UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];
	[view addSubview:label];
	[label release];

	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 1) {
		return [self.session.abstract sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(self.view.frame.size.width - 40, 10000)].height + 10;
	}
	if(indexPath.section == 2) {
		MLWSpeaker *speaker = [self.session.speakers objectAtIndex:indexPath.row];
		float height = nameHeight;
		if(speaker.bio != nil) {
			height += [speaker.bio sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(self.view.frame.size.width - 40, 10000)].height;
		}
		if(speaker.title != nil) {
			height += titleHeight;
		}
		if(speaker.email != nil) {
			height += contactHeight;
		}
		return height;
	}
	return 44;
}

- (UITableViewCell *)tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	NSString *cellIdentifier = @"DefaultCell";
	if(indexPath.section == 0) {
		if(indexPath.row == 0) {
			cellIdentifier = @"DefaultCell";
		}
		else {
			cellIdentifier = @"Value2Cell";
		}
	}
	else if(indexPath.section == 1) {
		cellIdentifier = @"DefaultCell";
	}
	else if(indexPath.section == 2) {
		cellIdentifier = @"PresenterCell";
	}

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil) {
		if([cellIdentifier isEqualToString:@"DefaultCell"]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		}
		else if([cellIdentifier isEqualToString:@"Value2Cell"]) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier] autorelease];
		}
		else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		}
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	if(indexPath.section == 0) {
		if(indexPath.row != 0) {
			cell.textLabel.textColor = [UIColor colorWithRed:(236.0f/255.0f) green:(125.0f/255.0f) blue:(30.0f/255.0f) alpha:1.0f];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
		}

		switch (indexPath.row) {
			case 0:
				cell.textLabel.adjustsFontSizeToFitWidth = YES;
				cell.textLabel.minimumFontSize = 10;
				cell.textLabel.numberOfLines = 0;
				cell.textLabel.text = self.session.title;
				break;
			case 1:
				cell.textLabel.text = @"Day";
				cell.detailTextLabel.text = self.session.dayOfWeek;
				break;
			case 2:
				cell.textLabel.text = @"Time";
				cell.detailTextLabel.text = self.session.formattedTime;
				break;
			case 3:
				cell.textLabel.text = @"Room";
				cell.detailTextLabel.text = self.session.location;
				break;
			case 4:
				cell.textLabel.text = @"Track";
				cell.detailTextLabel.text = self.session.track;
				break;
		}
	}
	else if(indexPath.section == 1) {
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		cell.textLabel.text = self.session.abstract;
	}
	else if(indexPath.section == 2) {
		for(UIView *view in cell.contentView.subviews) {
			[view removeFromSuperview];
		}

		float width = self.view.frame.size.width - 40;
		float nextYOrigin = 0;

		MLWSpeaker *speaker = [self.session.speakers objectAtIndex:indexPath.row];
		UIView *speakerView = [[UIView alloc] init];
		speakerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

		// Name view
		UIView *nameView = [[UIView alloc] initWithFrame:CGRectMake(0, nextYOrigin, width, nameHeight)];

		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 280, 22)];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.font = [UIFont boldSystemFontOfSize:18];
		nameLabel.text = speaker.name;
		[nameView addSubview:nameLabel];
		[nameLabel release];

		UILabel *orgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 24, 280, 18)];
		orgLabel.backgroundColor = [UIColor clearColor];
		orgLabel.font = [UIFont italicSystemFontOfSize:14];
		orgLabel.text = speaker.organization;
		[nameView addSubview:orgLabel];
		[orgLabel release];

		nextYOrigin += nameView.frame.size.height;
		[speakerView addSubview:nameView];
		[nameView release];

		// Bio view
		if(speaker.bio != nil) {
			UILabel *bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, nextYOrigin, width, [speaker.bio sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(self.view.frame.size.width - 40, 10000)].height)];
			bioLabel.numberOfLines = 0;
			bioLabel.backgroundColor = [UIColor clearColor];
			bioLabel.font = [UIFont systemFontOfSize:14];
			bioLabel.text = speaker.bio;
			nextYOrigin += bioLabel.frame.size.height;
			[speakerView addSubview:bioLabel];
			[bioLabel release];
		}

		// Title view
		if(speaker.title != nil) {
			UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, nextYOrigin, width, titleHeight)];

			UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 45, 16)];
			title.backgroundColor = [UIColor clearColor];
			title.textColor = [UIColor colorWithRed:(236.0f/255.0f) green:(125.0f/255.0f) blue:(30.0f/255.0f) alpha:1.0f];
			title.font = [UIFont boldSystemFontOfSize:13];
			title.text = @"Title:";
			[titleView addSubview:title];
			[title release];

			UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 15, 280 - 55, 16)];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.font = [UIFont boldSystemFontOfSize:13];
			titleLabel.text = speaker.title;
			titleLabel.adjustsFontSizeToFitWidth = YES;
			titleLabel.minimumFontSize = 10;
			[titleView addSubview:titleLabel];
			[titleLabel release];

			nextYOrigin += titleView.frame.size.height;
			[speakerView addSubview:titleView];
			[titleView release];
		}

		// Contact view
		if(speaker.email != nil) {
			UIView *contactView = [[UIView alloc] initWithFrame:CGRectMake(0, nextYOrigin, width, contactHeight)];

			UILabel *email = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 45, 16)];
			email.backgroundColor = [UIColor clearColor];
			email.textColor = [UIColor colorWithRed:(236.0f/255.0f) green:(125.0f/255.0f) blue:(30.0f/255.0f) alpha:1.0f];
			email.font = [UIFont boldSystemFontOfSize:13];
			email.text = @"Email:";
			[contactView addSubview:email];
			[email release];

			UILabel *contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 280 - 55, 16)];
			contactLabel.backgroundColor = [UIColor clearColor];
			contactLabel.font = [UIFont boldSystemFontOfSize:13];
			contactLabel.text = speaker.email;
			contactLabel.adjustsFontSizeToFitWidth = YES;
			contactLabel.minimumFontSize = 10;
			[contactView addSubview:contactLabel];
			[contactLabel release];

			nextYOrigin += contactView.frame.size.height;
			[speakerView addSubview:contactView];
			[contactView release];
		}

		speakerView.frame = CGRectMake(0, 0, width, nextYOrigin);
		[cell.contentView addSubview:speakerView];
		[speakerView release];
	}

	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)toggleHighlighting:(UIBarButtonItem *)sender {
	MLWAppDelegate *appDelegate = (MLWAppDelegate *)[UIApplication sharedApplication].delegate;
	MLWConference *conference = appDelegate.conference;
	if([sender.title isEqualToString:@"Highlight"]) {
		[conference.userSchedule addSession:self.session];
		sender.title = @"Unhighlight";
	}
	else {
		[conference.userSchedule removeSession:self.session];
		sender.title = @"Highlight";
	}
}

- (void)takeSurvey:(UIBarButtonItem *)sender {
	MLWSessionSurveyViewController *surveyController = [[MLWSessionSurveyViewController alloc] initWithSession:self.session];
	[self.navigationController pushViewController:surveyController animated:YES];
	[surveyController release];
}

- (void)viewDidUnload {
	self.view = nil;
	self.tableView = nil;
    [super viewDidUnload];
}

- (void)dealloc {
	self.view = nil;
	self.tableView = nil;
	self.session = nil;
	self.highlightButton = nil;
    [super dealloc];
}

@end
