//
//  StackMobExportViewController.m
//  UltimateAscent
//
//  Created by FRC on 3/28/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "StackMobExportViewController.h"
#import "DataManager.h"
#import "SettingsData.h"
#import "TournamentData.h"
#import "TeamData.h"
#import "SMTournamentObject.h"
#import "SMTeamDataObject.h"

@interface StackMobExportViewController ()

@end

@implementation StackMobExportViewController
@synthesize dataManager = _dataManager;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize smManagedObjectContext = _smManagedObjectContext;
@synthesize pushTeamButton = _pushTeamButton;
@synthesize pushTournamentButton = _pushTournamentButton;
@synthesize settings = _settings;

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
    NSLog(@"Download Page");
    if (!_managedObjectContext) {
        if (_dataManager) {
            _managedObjectContext = _dataManager.managedObjectContext;
        }
        else {
            _dataManager = [DataManager new];
            _managedObjectContext = [_dataManager managedObjectContext];
        }
    }
    _smManagedObjectContext = _dataManager.smManagedObjectContext;
    
    [self retrieveSettings];
    if (_settings) {
        self.title =  [NSString stringWithFormat:@"%@ Stack Mob", _settings.tournament.name];
    }
    else {
        self.title = @"Stack Mob";
    }
    
    [_pushTeamButton setTitle:@"Push Team Data" forState:UIControlStateNormal];
    _pushTeamButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:20.0];

    [_pushTournamentButton setTitle:@"Push Tournament Data" forState:UIControlStateNormal];
    _pushTournamentButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:20.0];

}

- (IBAction)pushTeamData:(id)sender {
    SMTeamDataObject *teamObject = [[SMTeamDataObject alloc] initWithDataManager:_dataManager];
    NSError *error;
    
    // Fetch local team records
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicte = [NSPredicate predicateWithFormat:@"tournament.name CONTAINS %@", _settings.tournament.name];
    [fetchRequest setPredicate:predicte];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *teamRecord = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    [teamObject sendTeamDataToSM:teamRecord];
}

- (IBAction)pushTournamentData:(id)sender {
    SMTournamentObject *tournamentObject = [[SMTournamentObject alloc] initWithDataManager:_dataManager];
    NSError *error;

    // Fetch local tournament records
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *tournamentRecord = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    [tournamentObject sendTournamentDataToSM:tournamentRecord];
}

-(void)retrieveSettings {
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SettingsData" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *settingsRecord = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!settingsRecord) {
        NSLog(@"Karma disruption error");
        _settings = Nil;
    }
    else {
        if([settingsRecord count] == 0) {  // No Settings Exists
            NSLog(@"Karma disruption error");
            _settings = Nil;
        }
        else {
            _settings = [settingsRecord objectAtIndex:0];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPushTeamButton:nil];
    [self setPushTournamentButton:nil];
    [super viewDidUnload];
}

@end
