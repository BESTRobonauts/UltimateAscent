//
//  MatchAnalysisViewController.m
//  UltimateAscent
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "MatchAnalysisViewController.h"
#import "DataManager.h"

@interface MatchAnalysisViewController ()

@end

@implementation MatchAnalysisViewController
@synthesize dataManager = _dataManager;
@synthesize mainLogo;
@synthesize matchPicture;
@synthesize splashPicture;
@synthesize pictureCaption;
@synthesize masonPageButton, rossPageButton;
@synthesize lucienPageButton = _lucienPageButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"Set-Up Page");
    // Display the Robotnauts Banner
    [mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
    // Display the Label for the Picture
    pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    pictureCaption.text = @"Just Hangin' Out";
    
    // Set Font and Text for Mason Page Button
    [masonPageButton setTitle:@"Mason Page" forState:UIControlStateNormal];
    masonPageButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    
    // Set Font and Text for Ross Page Button
    [_lucienPageButton setTitle:@"Lucien Page" forState:UIControlStateNormal];
    _lucienPageButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
/*
    // Set Font and Text for Ross Page Button
    [rossPageButton setTitle:@"Ross Page" forState:UIControlStateNormal];
    rossPageButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
 */   
    self.title = @"Match Analysis";
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDataManager:_dataManager];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            mainLogo.frame = CGRectMake(-20, 0, 285, 960);
            [mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
            masonPageButton.frame = CGRectMake(325, 125, 400, 68);
            _lucienPageButton.frame = CGRectMake(325, 225, 400, 68);
            splashPicture.frame = CGRectMake(293, 563, 468, 330);
            pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            mainLogo.frame = CGRectMake(0, -60, 1024, 255);
            [mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            masonPageButton.frame = CGRectMake(550, 225, 400, 68);
            _lucienPageButton.frame = CGRectMake(550, 325, 400, 68);
            splashPicture.frame = CGRectMake(50, 243, 468, 330);
            pictureCaption.frame = CGRectMake(50, 581, 468, 39);
            break;
        default:
            break;
    }
    // Return YES for supported orientations
	return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
