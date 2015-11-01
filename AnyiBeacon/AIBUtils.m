//
//  AIBUtils.m
//  AnyiBeacon
//
//  Created by jaume on 30/04/14.
//  Copyright (c) 2014 Sandeep Mistry. All rights reserved.
//

#import "AIBUtils.h"

#define kPImmediate		@"CLProximityImmediate"
#define kPNear			@"CLProximityNear"
#define kPFar			@"CLProximityFar"
#define kPUnknown		@"CLProximityUnknown"

@implementation AIBUtils

+ (NSString *)stringForProximityValue:(CLProximity)proximity{
	NSString* ret=nil;
	switch (proximity) {
		case CLProximityFar:
			ret=kPFar;
			break;
		case CLProximityNear:
			ret=kPNear;
			break;
		case CLProximityImmediate:
			ret=kPImmediate;
			break;
		case CLProximityUnknown:
			ret=kPUnknown;
			break;
	};
	return ret;
}

@end
