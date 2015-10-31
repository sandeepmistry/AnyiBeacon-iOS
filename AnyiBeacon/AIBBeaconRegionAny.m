//
//  AIBBeaconRegionAny.m
//  AnyiBeacon
//
//  Created by Sandeep Mistry on 1/5/2014.
//  Copyright (c) 2014 Sandeep Mistry. All rights reserved.
//

#import "AIBBeaconRegionAny.h"

// https://github.com/nst/iOS-Runtime-Headers/blob/master/Frameworks/CoreLocation.framework/CLRegion.h
struct ClientRegion {
    BOOL identifier[512];
    BOOL onBehalfOfIdentifier[512];
    int type;
    bool notifyOnEntry;
    bool notifyOnExit;
    bool conservativeEntry;
    union {
        struct {
            BOOL proximityUUID[512];
            unsigned short major;
            unsigned short minor;
            int definitionMask;
            bool notifyEntryStateOnDisplay;
        } beaconAttributes;
        struct {
            struct {
                double latitude;
                double longitude;
            } center;
            double radius;
            double desiredAccuracy;
            int referenceFrame;
        } circularAttributes;
    } ;
};

@interface CLBeaconRegion (Hidden)

- (id)initWithIdentifier:(NSString *)identifier;
- (struct ClientRegion)clientRegion;

@end

@implementation AIBBeaconRegionAny

- (id)initWithIdentifier:(NSString *)identifier;
{
    return (self = [super initWithIdentifier:identifier]);
}

- (struct ClientRegion)clientRegion
{
    struct ClientRegion clientRegion = [super clientRegion];
    
    // definitionMask:
    //                  1 => uuid
    //                  3 => uuid + major
    //                  7 => uuid + major + minor
    
    clientRegion.beaconAttributes.definitionMask = ~0x07;
    
    return clientRegion;
}

@end
