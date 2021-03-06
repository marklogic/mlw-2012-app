/*
    CCFacetRequest.h
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

#import "CCRequest.h"
#import "CCConstraint.h"
#import "CCFacetResponse.h"

@interface CCFacetRequest : CCRequest

- (id)initWithConstraint:(CCConstraint *) constraint;
- (void)fetchResultsForFacets:(NSArray *) facets length:(NSUInteger) length callback:(void (^)(CCFacetResponse *, NSError *)) callback;

@property (nonatomic, retain) CCConstraint *constraint;

@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *order;
@property (nonatomic, copy) NSString *frequency;
@property BOOL includeAllValues;
@property (nonatomic, copy) NSString *collection;
@property (nonatomic, copy) NSString *underDirectory;
@property (nonatomic, copy) NSString *inDirectory;

@end
