//
//  MLWAndConstraint.m
//  MarkLogic World
//
//  Created by Ryan Grimm on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MLWAndConstraint.h"

@implementation MLWAndConstraint

- (id)init {
	self = [super init];
	if(self) {
		self.dict = [NSMutableDictionary dictionaryWithObject:[NSMutableArray arrayWithCapacity:20] forKey:@"and"];
	}

	return self;
}

+ (MLWAndConstraint *)andConstraints:(MLWConstraint *) firstConstraint, ... {
	MLWConstraint *eachConstraint;
	va_list constraintList;
	NSMutableArray *constraints = [NSMutableArray arrayWithCapacity:20];

	if(firstConstraint != nil) {
		[constraints addObject:firstConstraint];

		va_start(constraintList, firstConstraint);
		while((eachConstraint = va_arg(constraintList, MLWConstraint *))) {
			[constraints addObject:eachConstraint];
		}
		va_end(constraintList);
	}

	MLWAndConstraint *constraint = [[[MLWAndConstraint alloc] init] autorelease];
	[constraint.dict setObject:constraints forKey:@"and"];
	return constraint;
}

@end