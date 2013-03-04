//
//  TournamentViewController.m
//  UltimateAscent
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "TournamentViewController.h"
#import "DataManager.h"
#import "SettingsData.h"
#import "TournamentData.h"

@interface TournamentViewController ()
@end

@implementation TournamentViewController
@synthesize mainLogo;
@synthesize splashPicture, pictureCaption;
@synthesize managedObjectContext;
@synthesize settings;
// Tournament Picking
@synthesize tournamentData;
@synthesize tournamentLabel;
@synthesize tournamentButton;
@synthesize tournamentPicker;
@synthesize tournamentList;
@synthesize tournamentPickerPopover;
@synthesize allianceButton;
@synthesize modeButton;
@synthesize adminButton;
@synthesize overrideButton;
@synthesize bluetoothButton;

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
    [super viewDidLoad];
//    NSLog(@"Set-Up Page");
    // Display the Robotnauts Banner
    [mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
    // Display the Label for the Picture
    pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    pictureCaption.text = @"Just Hangin' Out";
/*
  
    // Set Font and Text for Match Set-Up Button
    [matchSetUpButton setTitle:@"Match List" forState:UIControlStateNormal];
    matchSetUpButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    
    // Set Font and Text for Import Data Button
    [importDataButton setTitle:@"Import Data" forState:UIControlStateNormal];
    importDataButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];
    
    // Set Font and Text for Export Data Button
    [exportDataButton setTitle:@"Export Data" forState:UIControlStateNormal];
    exportDataButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:36.0];*/
    self.title = @"iPad Set-Up Page";

    if (!managedObjectContext) {
        DataManager *dataManager = [DataManager new];
        managedObjectContext = [dataManager managedObjectContext];
    }

    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SettingsData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *settingsRecord = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!settingsRecord) {
        NSLog(@"Karma disruption error");
        settings = Nil;
    }
    else {
        if([settingsRecord count] == 0) {  // No Settings Exists
            NSLog(@"Karma disruption error");
            settings = Nil;
        }
        else {
            settings = [settingsRecord objectAtIndex:0];
            [tournamentButton setTitle:settings.tournament.name forState:UIControlStateNormal];
       }
    }

    // Set Font and Text for Tournament Set-Up Button
    [tournamentButton setTitle:settings.tournament.name forState:UIControlStateNormal];
    tournamentButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:18.0];

    entity = [NSEntityDescription entityForName:@"TournamentData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *tournamentSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:tournamentSort]];
    tournamentData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!tournamentData) {
        NSLog(@"Karma disruption error");
        tournamentList = nil;
    }
    else {
        TournamentData *t;
        self.tournamentList = [NSMutableArray array];
        for (int i=0; i < [tournamentData count]; i++) {
            t = [tournamentData objectAtIndex:i];
            NSLog(@"Tournament %@ exists", t.name);
            [tournamentList addObject:t.name];
        }
    }
    NSLog(@"Tournament List = %@", tournamentList);
}

-(IBAction)TournamentSelectionChanged:(id)sender {
    //    NSLog(@"TournamentSelectionChanged");
    if (tournamentPicker == nil) {
        self.tournamentPicker = [[TournamentPickerController alloc]
                               initWithStyle:UITableViewStylePlain];
        tournamentPicker.delegate = self;
        tournamentPicker.tournamentChoices = tournamentList;
        self.tournamentPickerPopover = [[UIPopoverController alloc]
                                      initWithContentViewController:tournamentPicker];
    }
    [self.tournamentPickerPopover presentPopoverFromRect:tournamentButton.bounds inView:tournamentButton
                              permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)tournamentSelected:(NSString *)newTournament {
    [self.tournamentPickerPopover dismissPopoverAnimated:YES];
    for (int i = 0 ; i < [tournamentList count] ; i++) {
        if ([newTournament isEqualToString:[tournamentList objectAtIndex:i]]) {
            [tournamentButton setTitle:newTournament forState:UIControlStateNormal];
            settings.tournament = [tournamentData objectAtIndex:i];
            NSError *error;
            if (![managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
            break;
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            mainLogo.frame = CGRectMake(-20, 0, 285, 960);
            [mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
            tournamentLabel.frame = CGRectMake(340, 85, 144, 21);
            tournamentButton.frame = CGRectMake(530, 73, 208, 44);
//            matchSetUpButton.frame = CGRectMake(325, 225, 400, 68);
//            importDataButton.frame = CGRectMake(325, 325, 400, 68);
//            exportDataButton.frame = CGRectMake(325, 425, 400, 68);
            splashPicture.frame = CGRectMake(293, 563, 468, 330);
            pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            mainLogo.frame = CGRectMake(0, -60, 1024, 255);
            [mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            tournamentLabel.frame = CGRectMake(540, 255, 144, 21);
            tournamentButton.frame = CGRectMake(730, 243, 208, 44);
//            matchSetUpButton.frame = CGRectMake(550, 325, 400, 68);
//            importDataButton.frame = CGRectMake(550, 425, 400, 68);
//            exportDataButton.frame = CGRectMake(550, 525, 400, 68);
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
