//
//  AIBAppDelegate.h
//  AnyiBeacon
//
//  Created by Sandeep Mistry on 1/5/2014.
//  Copyright (c) 2014 Sandeep Mistry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

@interface AIBAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
