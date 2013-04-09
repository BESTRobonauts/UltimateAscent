//
//  ImportDeviceViewController.m
//  UltimateAscent
//
//  Created by FRC on 4/4/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "ImportDeviceViewController.h"
#import "DataManager.h"

@interface ImportDeviceViewController ()

@end

@implementation ImportDeviceViewController
@synthesize dataManager = _dataManager;

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
    [super viewDidLoad];
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    
/*    [self retrieveSettings];
    if (_settings) {
        self.title =  [NSString stringWithFormat:@"%@ Import", _settings.tournament.name];
    }
    else {
        self.title = @"Import";
    }*/
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDataManager:_dataManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
