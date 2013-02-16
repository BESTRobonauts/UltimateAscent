//
//  SetUpPageViewController.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SetUpPageViewController.h"

@implementation SetUpPageViewController
@synthesize mainLogo;
@synthesize tournamentSetUpButton, matchSetUpButton, importDataButton, exportDataButton;
@synthesize pictureCaption;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSLog(@"Set-Up Page");
    // Display the Robotnauts Banner
    [mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
    // Display the Label for the Picture
    pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    pictureCaption.text = @"Just Hangin' Out";
 
    // Set Font and Text for Tournament Set-Up Button
    [tournamentSetUpButton setTitle:@"Tournament" forState:UIControlStateNormal];
    tournamentSetUpButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];

    // Set Font and Text for Match Set-Up Button
    [matchSetUpButton setTitle:@"Match List" forState:UIControlStateNormal];
    matchSetUpButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];

    // Set Font and Text for Import Data Button
    [importDataButton setTitle:@"Import Data" forState:UIControlStateNormal];
    importDataButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];

    // Set Font and Text for Export Data Button
    [exportDataButton setTitle:@"Export Data" forState:UIControlStateNormal];
    exportDataButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    self.title = @"Set-Up Page";
   [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
