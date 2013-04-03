//
//  ImportDataViewController.m
//  UltimateAscent
//
//  Created by FRC on 4/2/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "ImportDataViewController.h"
#import "DataManager.h"
#import "SettingsData.h"
#import "TournamentData.h"

@interface ImportDataViewController ()

@end

@implementation ImportDataViewController
@synthesize dataManager = _dataManager;
@synthesize importSMButton = _importSMButton;

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
    
    [_importSMButton setTitle:@"Import from Stack Mob" forState:UIControlStateNormal];
    _importSMButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:20.0];
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
