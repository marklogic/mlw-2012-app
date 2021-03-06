/*
    MLWSession.m
	MarkLogic World
	Created by Ryan Grimm on 3/14/12.

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

#import "MLWSession.h"
#import "MLWAppDelegate.h"

@interface MLWSession ()
- (NSDate *)stringToDate:(NSString *) dateString;
@end

@implementation MLWSession

@synthesize id = _id;
@synthesize startTime = _startTime;
@synthesize endTime = _endTime;
@synthesize plenary = _plenary;
@synthesize selectable = _selectable;
@synthesize title = _title;
@synthesize speakers = _speakers;
@synthesize abstract = _abstract;
@synthesize track = _track;
@synthesize location = _location;

- (id)initWithData:(NSDictionary *) jsonData {
	self = [super init];
	if(self) {
		_id = [[jsonData objectForKey:@"id"] retain];
		_startTime = [[self stringToDate:[jsonData objectForKey:@"startTime::date"]] retain];
		_endTime = [[self stringToDate:[jsonData objectForKey:@"endTime::date"]] retain];
		_plenary = [[jsonData objectForKey:@"plenary"] boolValue];
		_selectable = [[jsonData objectForKey:@"selectable"] boolValue];
		_title = [[jsonData objectForKey:@"title"] retain];
		_abstract = [[jsonData objectForKey:@"abstract"] retain];
		_track = [[jsonData objectForKey:@"track"] retain];
		_location = [[jsonData objectForKey:@"location"] retain];

		if([_track isKindOfClass:[NSNull class]] || _track.length == 0) {
			[_track release];
			_track = nil;
		}
		if([_location isKindOfClass:[NSNull class]] || _location.length == 0) {
			[_location release];
			_location = nil;
		}

		MLWAppDelegate *appDelegate = (MLWAppDelegate *)[UIApplication sharedApplication].delegate;
		MLWConference *conference = appDelegate.conference;
		_speakers = [[NSMutableArray alloc] initWithCapacity:3];
		for(NSString *speakerId in [jsonData objectForKey:@"speakerIds"]) {
			MLWSpeaker *speaker = [conference speakerWithId:speakerId];
			if(speaker != nil) {
				[_speakers addObject:speaker];
			}
		}
	}
	return self;
}

- (NSString *)dayOfWeek {
	NSDateFormatter *dowFormat = [[[NSDateFormatter alloc] init] autorelease];
	dowFormat.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"EDT"];
	[dowFormat setDateFormat:@"EEEE"];

	return [dowFormat stringFromDate:_startTime];
}

- (NSString *)formattedDate {
	NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
	format.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"EDT"];
	[format setDateStyle:NSDateFormatterNoStyle];
	[format setTimeStyle:NSDateFormatterShortStyle];

	return [NSString stringWithFormat:@"%@, %@ - %@", self.dayOfWeek, [format stringFromDate:_startTime], [format stringFromDate:_endTime]];
}

- (NSString *)formattedTime {
	NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
	format.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"EDT"];
	[format setDateStyle:NSDateFormatterNoStyle];
	[format setTimeStyle:NSDateFormatterShortStyle];

	return [[NSString stringWithFormat:@"%@ - %@", [format stringFromDate:_startTime], [format stringFromDate:_endTime]] lowercaseString];
}


- (NSDate *)stringToDate:(NSString *) dateString {
	NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
	dateFormat.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	// 2012-05-01T07:30:00-0400
	[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
	NSRange timezone = NSMakeRange([dateString length] - 3, 3);
	NSString *cleanDate = [dateString stringByReplacingOccurrencesOfString:@":" withString:@"" options:NSCaseInsensitiveSearch range:timezone];
	return [dateFormat dateFromString:cleanDate];
}

- (void) dealloc {
	[_id release];
	[_startTime release];
	[_endTime release];
	[_title release];
	[_abstract release];
	[_track release];
	[_speakers release];
	[_location release];

	[super dealloc];
}

@end
