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
@synthesize splashPicture, pictureCaption;

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

- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"view will appear %d", [UIApplication sharedApplication].statusBarOrientation);
//    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
}
    
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillLayoutSubviews {
    NSLog(@"viewwilllayout %d", [UIApplication sharedApplication].statusBarOrientation);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"autorotate %d", [UIApplication sharedApplication].statusBarOrientation);
   switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            mainLogo.frame = CGRectMake(-20, 0, 285, 960);
            [mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
            tournamentSetUpButton.frame = CGRectMake(325, 125, 400, 68);
            matchSetUpButton.frame = CGRectMake(325, 225, 400, 68);
            importDataButton.frame = CGRectMake(325, 325, 400, 68);
            exportDataButton.frame = CGRectMake(325, 425, 400, 68);
            splashPicture.frame = CGRectMake(293, 563, 468, 330);
            pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            mainLogo.frame = CGRectMake(0, -60, 1024, 255);
            [mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            tournamentSetUpButton.frame = CGRectMake(550, 225, 400, 68);
            matchSetUpButton.frame = CGRectMake(550, 325, 400, 68);
            importDataButton.frame = CGRectMake(550, 425, 400, 68);
            exportDataButton.frame = CGRectMake(550, 525, 400, 68);
            splashPicture.frame = CGRectMake(50, 243, 468, 330);
            pictureCaption.frame = CGRectMake(50, 581, 468, 39);
            break;
        default:
            break;
    }
   // Return YES for supported orientations
	return YES;
}

@end
