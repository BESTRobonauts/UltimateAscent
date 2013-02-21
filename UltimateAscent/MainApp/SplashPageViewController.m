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
@synthesize teamScoutingButton, matchSetUpButton, matchScoutingButton, matchAnalysisButton, splashPicture;

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
    // Set Font and Text for Tournament Set Up Button
    [matchSetUpButton setTitle:@"Before and after" forState:UIControlStateNormal];
    matchSetUpButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    // Set Font and Text for Match Scouting Up Button
    [matchScoutingButton setTitle:@"Match Scouting" forState:UIControlStateNormal];
    matchScoutingButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    // Set Font and Text for Match Analysis Button
    [matchAnalysisButton setTitle:@"Match analysis" forState:UIControlStateNormal];
    matchAnalysisButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
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
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            mainLogo.frame = CGRectMake(0, 0, 285, 960);
            [mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
            teamScoutingButton.frame = CGRectMake(325, 125, 400, 68);
            matchSetUpButton.frame = CGRectMake(325, 225, 400, 68);
            matchScoutingButton.frame = CGRectMake(325, 325, 400, 68);
            matchAnalysisButton.frame = CGRectMake(325, 425, 400, 68);
            splashPicture.frame = CGRectMake(293, 563, 468, 330);
            pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            mainLogo.frame = CGRectMake(0, -50, 1024, 285);
            [mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            teamScoutingButton.frame = CGRectMake(550, 215, 400, 68);
            matchSetUpButton.frame = CGRectMake(550, 315, 400, 68);
            matchScoutingButton.frame = CGRectMake(550, 415, 400, 68);
            matchAnalysisButton.frame = CGRectMake(550, 515, 400, 68);
            splashPicture.frame = CGRectMake(50, 233, 468, 330);
            pictureCaption.frame = CGRectMake(50, 571, 468, 39);
            break;
        default:
            break;
    }
    // Return YES for supported orientations
	return YES;
}

@end
