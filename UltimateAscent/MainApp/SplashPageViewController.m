//
//  SplashPageViewController.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SplashPageViewController.h"

@implementation SplashPageViewController
@synthesize mainLogo;
@synthesize pictureCaption;
@synthesize teamScoutingButton, matchSetUpButton, matchScoutingButton;

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
    NSLog(@"Splash Page");
    // Display the Robotnauts Banner
    [mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
    // Display the Label for the Picture
    pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    pictureCaption.text = @"Just Hangin' Out";
    // Set Font and Text for Team Scouting Button
    [teamScoutingButton setTitle:@"Team/Pit Scouting" forState:UIControlStateNormal];
    teamScoutingButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    // Set Font and Text for Match Set Up Button
    [matchSetUpButton setTitle:@"Data In/Data Out" forState:UIControlStateNormal];
    matchSetUpButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    // Set Font and Text for Match Set Up Button
    [matchScoutingButton setTitle:@"Match Scouting" forState:UIControlStateNormal];
    matchScoutingButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    self.title = @"Ultimate Ascent";
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)scoutingPageStatus:(NSUInteger)sectionIndex forRow:(NSUInteger)rowIndex forTeam:(NSUInteger)teamIndex {
    NSLog(@"scouting delegate");    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
