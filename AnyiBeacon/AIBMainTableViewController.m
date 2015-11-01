//
//  AIBMainTableViewController.m
//  AnyiBeacon
//
//  Created by jaume on 30/04/14.
//  Copyright (c) 2014 Sandeep Mistry. All rights reserved.
//

#import "AIBMainTableViewController.h"
#import "AIBBeaconRegionAny.h"
#import "AIBUtils.h"
#import "AIBDetailViewController.h"

#define  kCellIdentifier @"cellBeaconIdentifier"

@import CoreLocation;

@interface AIBMainTableViewController ()<CLLocationManagerDelegate>

@property(nonatomic, strong) NSDictionary*		beaconsDict;
@property(nonatomic, strong) CLLocationManager* locationManager;
@property(nonatomic, strong) NSArray*			listUUID;
@property(nonatomic)		 BOOL				sortByMajorMinor;
@property(nonatomic, retain) CLBeacon*			selectedBeacon;

@end

@implementation AIBMainTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
	
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	
	self.listUUID=[[NSArray alloc] init];
	self.beaconsDict=[[NSMutableDictionary alloc] init];
	self.sortByMajorMinor=NO;
	
	AIBBeaconRegionAny *beaconRegionAny = [[AIBBeaconRegionAny alloc] initWithIdentifier:@"Any"];
	[self.locationManager requestWhenInUseAuthorization];
	[self.locationManager startRangingBeaconsInRegion:beaconRegionAny];
		
	self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Order by major/minor" style:UIBarButtonItemStylePlain target:self action:@selector(changeOrdenation)];
}

- (void) changeOrdenation{
	_sortByMajorMinor=!_sortByMajorMinor;
	if (_sortByMajorMinor){
		self.navigationItem.rightBarButtonItem.title=@"Order by distance";
	} else {
		self.navigationItem.rightBarButtonItem.title=@"Order by major/minor";
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"locationManagerDidChangeAuthorizationStatus: %d", status);
    
    [UIAlertController alertControllerWithTitle:@"Authoritzation Status changed"
                                        message:[[NSString alloc] initWithFormat:@"Location Manager did change authorization status to: %d", status]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"locationManager:%@ didRangeBeacons:%@ inRegion:%@",manager, beacons, region);

    NSMutableArray* listUuid=[[NSMutableArray alloc] init];
	NSMutableDictionary* beaconsDict=[[NSMutableDictionary alloc] init];
	for (CLBeacon* beacon in beacons) {
		NSString* uuid=[beacon.proximityUUID UUIDString];
		NSMutableArray* list=[beaconsDict objectForKey:uuid];
		if (list==nil){
			list=[[NSMutableArray alloc] init];
			[listUuid addObject:uuid];
			[beaconsDict setObject:list forKey:uuid];
		}
		[list addObject:beacon];
	}
	[listUuid sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSString* string1=obj1;
		NSString* string2=obj2;
		return [string1 compare:string2];
	}];
	if (_sortByMajorMinor){
		for (NSString* uuid in listUuid){
			NSMutableArray* list=[beaconsDict objectForKey:uuid];
			[list sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				CLBeacon* b1=obj1;
				CLBeacon* b2=obj2;
				NSComparisonResult r=[b1.major compare:b2.major];
				if (r==NSOrderedSame){
					r=[b1.minor compare:b2.minor];
				}
				return r;
			}];
		}
	}
	_listUUID=listUuid;
	_beaconsDict=beaconsDict;
	
	[self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
     NSLog(@"locationManager:%@ rangingBeaconsDidFailForRegion:%@ withError:%@", manager, region, error);
    
    [UIAlertController alertControllerWithTitle:@"Ranging Beacons fail"
                                        message:[[NSString alloc] initWithFormat:@"Ranging beacons fail with error: %@", error]
                                 preferredStyle:UIAlertControllerStyleAlert];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_listUUID count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	NSString* key=[_listUUID objectAtIndex:section];
    return [[_beaconsDict objectForKey:key] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return [_listUUID objectAtIndex:section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
	
	NSString* key=[_listUUID objectAtIndex:[indexPath indexAtPosition:0]];
	CLBeacon* beacon=[[_beaconsDict objectForKey:key] objectAtIndex:[indexPath indexAtPosition:1]];
	cell.textLabel.text=[[NSString alloc] initWithFormat:@"M:%@ m:%@", beacon.major, beacon.minor];
	
	cell.detailTextLabel.text=[[NSString alloc] initWithFormat:@"Distance: %.2fm\tProximity: %@", beacon.accuracy, [AIBUtils stringForProximityValue:beacon.proximity]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString* key=[_listUUID objectAtIndex:[indexPath indexAtPosition:0]];
	_selectedBeacon=[[_beaconsDict objectForKey:key] objectAtIndex:[indexPath indexAtPosition:1]];

    AIBDetailViewController* detail=[self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
	detail.beacon=_selectedBeacon;
	[self.navigationController pushViewController:detail animated:YES];
}

@end
