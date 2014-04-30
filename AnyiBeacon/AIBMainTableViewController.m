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

#define  kCellIdentifier @"cellBeaconIdentifier"

@import CoreLocation;

@interface AIBMainTableViewController ()<CLLocationManagerDelegate>
@property(nonatomic, strong) NSDictionary*		beaconsDict;
@property(nonatomic, strong) CLLocationManager* locationManager;
@property(nonatomic, strong) NSArray*			listUUID;
@property(nonatomic)		 BOOL				sortByMajorMinor;
@end

@implementation AIBMainTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
		
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	
	self.listUUID=[[NSArray alloc] init];
	self.beaconsDict=[[NSMutableDictionary alloc] init];
	self.sortByMajorMinor=NO;
	
	AIBBeaconRegionAny *beaconRegionAny = [[AIBBeaconRegionAny alloc] initWithIdentifier:@"Any"];
	[self.locationManager startRangingBeaconsInRegion:beaconRegionAny];
	
	//[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
	
	self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Change order" style:UIBarButtonItemStyleBordered target:self action:@selector(changeOrdenation)];
}

- (void) changeOrdenation{
	_sortByMajorMinor=!_sortByMajorMinor;
	if (_sortByMajorMinor){
		self.navigationItem.rightBarButtonItem.title=@"Order by distance";
	} else {
		self.navigationItem.rightBarButtonItem.title=@"Order by major/minor";
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"locationManagerDidChangeAuthorizationStatus: %d", status);
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    //NSLog(@"locationManager:%@ didRangeBeacons:%@ inRegion:%@",manager, beacons, region);
	//_listBeacons=beacons;
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
	
	
	/*if (cell == nil){
		cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
	}//*/
	NSString* key=[_listUUID objectAtIndex:[indexPath indexAtPosition:0]];
	CLBeacon* beacon=[[_beaconsDict objectForKey:key] objectAtIndex:[indexPath indexAtPosition:1]];
	cell.textLabel.text=[[NSString alloc] initWithFormat:@"M:%@ m:%@", beacon.major, beacon.minor];
	
	cell.detailTextLabel.text=[[NSString alloc] initWithFormat:@"Distance: %.2fm\tProximity: %@", beacon.accuracy, [AIBUtils stringForProximityValue:beacon.proximity]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
