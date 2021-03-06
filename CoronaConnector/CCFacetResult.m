/*
    CCFacetResult.m
	Corona Connector
    Created by Ryan Grimm on 3/22/12.

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

#import "CCFacetResult.h"

@implementation CCFacetResult

@synthesize label = _label;
@synthesize count = _count;

- (id)initWithLabel:(NSString *) label count:(NSUInteger ) count {
	self = [super init];
	if(self) {
		_label = [label copy];
		_count = count;
	}
	return self;
}

- (void)dealloc {
	[_label release];

	[super dealloc];
}

@end
