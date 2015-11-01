//
//  AIBDetailViewController.m
//  AnyiBeacon
//
//  Created by jaume on 30/04/14.
//  Copyright (c) 2014 Sandeep Mistry. All rights reserved.
//

#import "AIBDetailViewController.h"

@interface AIBDetailViewController ()

@property (weak, nonatomic) IBOutlet UIButton *uuidButton;
@property (weak, nonatomic) IBOutlet UIButton *majorButton;
@property (weak, nonatomic) IBOutlet UIButton *minorButton;

@end

@implementation AIBDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSString* text;
	text=[_beacon.proximityUUID UUIDString];
	[_uuidButton setTitle:text forState:UIControlStateNormal];
	[_uuidButton setTitle:text forState:UIControlStateHighlighted];
	[_uuidButton setTitle:text forState:UIControlStateDisabled];
	[_uuidButton setTitle:text forState:UIControlStateSelected];
	
	text=[[NSString alloc] initWithFormat:@"%@", _beacon.major];
	[_majorButton setTitle:text forState:UIControlStateNormal];
	[_majorButton setTitle:text forState:UIControlStateHighlighted];
	[_majorButton setTitle:text forState:UIControlStateDisabled];
	[_majorButton setTitle:text forState:UIControlStateSelected];

	text=[[NSString alloc] initWithFormat:@"%@", _beacon.minor];
	[_minorButton setTitle:text forState:UIControlStateNormal];
	[_minorButton setTitle:text forState:UIControlStateHighlighted];
	[_minorButton setTitle:text forState:UIControlStateDisabled];
	[_minorButton setTitle:text forState:UIControlStateSelected];
}

- (void) copyToClipboard: (NSString*) text{
	UIPasteboard* pasteboard=[UIPasteboard generalPasteboard];
	[pasteboard setString:text];
}

- (IBAction)copyUUID:(id)sender {
	[self copyToClipboard:[_beacon.proximityUUID UUIDString]];
}

- (IBAction)copyMajor:(id)sender {
	[self copyToClipboard:[[NSString alloc] initWithFormat:@"%@", _beacon.major]];
}

- (IBAction)copyMinor:(id)sender {
	[self copyToClipboard:[[NSString alloc] initWithFormat:@"%@", _beacon.minor]];
}

@end
