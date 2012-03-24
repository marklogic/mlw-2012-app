//
//  CCAndConstraint.h
//  MarkLogic World
//
//  Created by Ryan Grimm on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBooleanConstraint.h"
#import "CCConstraint.h"

@interface CCAndConstraint : CCBooleanConstraint

+ (CCAndConstraint *)andConstraints:(CCConstraint *) firstConstraint, ...;

@end