/*
    CCFacetRequest.m
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

#import "CCFacetRequest.h"
#import "SBJSON.h"

@implementation CCFacetRequest

@synthesize constraint = _constraint;

- (id)initWithConstraint:(CCConstraint *) constraint {
	self = [super init];
	if(self) {
		self.constraint = constraint;
	}
	return self;
}

- (void)fetchResultsForFacets:(NSArray *) facets length:(NSUInteger) length callback:(void (^)(CCFacetResponse *, NSError *)) callback {
	[self.parameters setObject:[NSString stringWithFormat:@"%i", length] forKey:@"limit"];

	if(self.constraint != nil) {
		[self.parameters setObject:[self.constraint serialize] forKey:@"structuredQuery"];
	}

	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/facet/%@", self.baseURL.absoluteString, [facets componentsJoinedByString:@","]]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	request.HTTPMethod = @"POST";
	request.HTTPBody = [self dictionaryToPOSTData:self.parameters];
	request.URL = url;

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSURLResponse *response = nil;
		NSError *error = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

		if(error != nil || data == nil) {
			NSLog(@"CCFacetRequest: could not fetch facet results - %@", error);
			dispatch_async(dispatch_get_main_queue(), ^ {
				callback(nil, error);
			});
			return;
		}

		SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
		NSDictionary *results = [parser objectWithData:data];
		if(results == nil) {
			NSLog(@"CCFacetRequest: JSON parsing error - %@", parser.error);
			// XXX create NSError
			dispatch_async(dispatch_get_main_queue(), ^ {
				callback(nil, nil);
			});
			return;
		}

		dispatch_async(dispatch_get_main_queue(), ^ {
			callback([CCFacetResponse responseFromData:results], nil);
		});
	});

	[request release];
}


- (NSString *)language {
	return [self.parameters objectForKey:@"language"];
}

- (void)setLanguage:(NSString *) language {
	[self.parameters setObject:language forKey:@"language"];
}

- (NSString *)order {
	return [self.parameters objectForKey:@"order"];
}

- (void)setOrder:(NSString *) order {
	[self.parameters setObject:order forKey:@"order"];
}

- (NSString *)frequency {
	return [self.parameters objectForKey:@"frequency"];
}

- (void)setFrequency:(NSString *) frequency {
	[self.parameters setObject:frequency forKey:@"frequency"];
}

- (BOOL)includeAllValues {
	return ((NSNumber *)[self.parameters objectForKey:@"includeAllValues"]).boolValue;
}

- (void)setIncludeAllValues:(BOOL) includeAllValues {
	[self.parameters setObject:[NSNumber numberWithBool:includeAllValues] forKey:@"includeAllValues"];
}

- (NSString *)collection {
	return [self.parameters objectForKey:@"collection"];
}

- (void)setCollection:(NSString *) collection {
	[self.parameters setObject:collection forKey:@"collection"];
}

- (NSString *)underDirectory {
	return [self.parameters objectForKey:@"underDirectory"];
}

- (void)setUnderDirectory:(NSString *) underDirectory {
	[self.parameters setObject:underDirectory forKey:@"underDirectory"];
}

- (NSString *)inDirectory {
	return [self.parameters objectForKey:@"inDirectory"];
}

- (void)setInDirectory:(NSString *) inDirectory {
	[self.parameters setObject:inDirectory forKey:@"inDirectory"];
}

- (void)dealloc {
	self.constraint = nil;

	[super dealloc];
}

@end
