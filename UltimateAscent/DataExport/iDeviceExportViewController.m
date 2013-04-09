//
//  iDeviceExportViewController.m
//  UltimateAscent
//
//  Created by FRC on 4/4/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "iDeviceExportViewController.h"
#import "DataManager.h"

@interface iDeviceExportViewController ()

@end

@implementation iDeviceExportViewController
@synthesize dataManager = _dataManager;
@synthesize exportMatchListButton = _exportMatchListButton;

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

- (void)viewDidUnload {
    [self setExportMatchListButton:nil];
    [super viewDidUnload];
}
@end
