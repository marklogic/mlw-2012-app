/*
    CCFacetResponse.m
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

#import "CCFacetResponse.h"

@implementation CCFacetResponse

@synthesize facets = _facets;

- (CCFacetResponse *)initFromData:(NSDictionary *) data {
	self = [super init];
	if(self) {
		NSMutableArray *facets = [NSMutableArray arrayWithCapacity:data.count];
		for(NSString *key in data) {
			[facets addObject:[CCFacet facetNamed:key fromData:[data objectForKey:key]]];
		}
		_facets = [[NSArray alloc] initWithArray:facets];
	}


	return self;
}

+ (CCFacetResponse *)responseFromData:(NSDictionary *) data {
	return [[[CCFacetResponse alloc] initFromData:data] autorelease];
}

- (CCFacet *)facetNamed:(NSString *) name {
	for(CCFacet *facet in _facets) {
		if([facet.name isEqualToString:name]) {
			return facet;
		}
	}
	return nil;
}

- (void)dealloc {
	[_facets release];

	[super dealloc];
}

@end
