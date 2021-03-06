//
//  StackMobImportViewController.m
//  UltimateAscent
//
//  Created by FRC on 4/2/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "StackMobImportViewController.h"
#import "DataManager.h"
#import "SettingsData.h"
#import "TournamentData.h"
#import "SMTeamDataObject.h"

@interface StackMobImportViewController ()

@end

@implementation StackMobImportViewController
@synthesize dataManager = _dataManager;
@synthesize settings = _settings;
@synthesize importTeamButton = _importTeamButton;

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
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    
    [self retrieveSettings];
    if (_settings) {
        self.title =  [NSString stringWithFormat:@"%@ Stack Mob Import", _settings.tournament.name];
    }
    else {
        self.title = @"Stack Mob";
    }
    
    [_importTeamButton setTitle:@"Import Team Data" forState:UIControlStateNormal];
    _importTeamButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:20.0];
}

- (IBAction)pullTeamData:(id)sender {
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
    
    [teamObject retrieveTeamDataFromSM:teamRecord];
}

-(void)retrieveSettings {
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SettingsData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *settingsRecord = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
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

@end
