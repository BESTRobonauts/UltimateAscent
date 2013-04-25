//
//  LucienPageViewController.m
//  UltimateAscent
//
//  Created by FRC on 4/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "LucienPageViewController.h"
#import "DataManager.h"
#import "SettingsData.h"
#import "TournamentData.h"
#import "PopUpPickerViewController.h"
#import "parseCSV.h"

@interface LucienPageViewController ()

@end

@implementation LucienPageViewController {
    NSMutableArray *normals;
    NSMutableArray *factors;
    BOOL dataChange;
    NSFileManager *fileManager;
    NSString *storePath;
}
@synthesize dataManager = _dataManager;
@synthesize autonNormal = _autonNormal;
@synthesize autonFactor = _autonFactor;
@synthesize teleOpNormal = _teleOpNormal;
@synthesize teleOpFactor = _teleOpFactor;
@synthesize climbNormal = _climbNormal;
@synthesize climbFactor = _climbFactor;
@synthesize driverNormal = _driverNormal;
@synthesize driverFactor = _driverFactor;
@synthesize speedNormal = _speedNormal;
@synthesize speedFactor = _speedFactor;
@synthesize defenseNormal = _defenseNormal;
@synthesize defenseFactor = _defenseFactor;
@synthesize height1Factor = _height1Factor;
@synthesize height2Factor = _height2Factor;

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
        self.title =  [NSString stringWithFormat:@"%@ Lucien Page", _settings.tournament.name];
    }
    else {
        self.title = @"Lucien Page";
    }
    dataChange = NO;

    normals = [[NSMutableArray alloc] initWithObjects:
               [NSNumber numberWithFloat:0.0],
               [NSNumber numberWithFloat:0.0],
               [NSNumber numberWithFloat:0.0],
               [NSNumber numberWithFloat:0.0],
               [NSNumber numberWithFloat:0.0],
               [NSNumber numberWithFloat:0.0], nil];
    factors = [[NSMutableArray alloc] initWithObjects:
               [NSNumber numberWithFloat:0.0],
               [NSNumber numberWithFloat:0.0],
               [NSNumber numberWithFloat:0.0],
               [NSNumber numberWithFloat:0.0],
               [NSNumber numberWithFloat:0.0],
               [NSNumber numberWithFloat:0.0],
               [NSNumber numberWithFloat:0.0],
               [NSNumber numberWithFloat:0.0], nil];

    storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"lucienFactors.csv"];
    fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:storePath]) {
        CSVParser *parser = [CSVParser new];
        [parser openFile: storePath];
        NSMutableArray *csvContent = [parser parseFile];
        float junk;
        for (int i=0; i<[[csvContent objectAtIndex:0] count]; i++) {
            junk = [[[csvContent objectAtIndex:0] objectAtIndex:i] floatValue];
            [normals replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:junk]];
            junk = [[[csvContent objectAtIndex:1] objectAtIndex:i] floatValue];
            [factors replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:junk]];
        }
        junk = [[[csvContent objectAtIndex:1] objectAtIndex:6] floatValue];
        [factors replaceObjectAtIndex:6 withObject:[NSNumber numberWithFloat:junk]];
        junk = [[[csvContent objectAtIndex:1] objectAtIndex:7] floatValue];
        [factors replaceObjectAtIndex:7 withObject:[NSNumber numberWithFloat:junk]];
    }
    
    [self setDisplayData];
}

-(void)setDisplayData {
    _autonNormal.text = [NSString stringWithFormat:@"%.1f", [[normals objectAtIndex:0] floatValue]];
    _teleOpNormal.text = [NSString stringWithFormat:@"%.1f", [[normals objectAtIndex:1] floatValue]];
    _climbNormal.text = [NSString stringWithFormat:@"%.1f", [[normals objectAtIndex:2] floatValue]];
    _driverNormal.text = [NSString stringWithFormat:@"%.1f", [[normals objectAtIndex:3] floatValue]];
    _speedNormal.text = [NSString stringWithFormat:@"%.1f", [[normals objectAtIndex:4] floatValue]];
    _defenseNormal.text = [NSString stringWithFormat:@"%.1f", [[normals objectAtIndex:5] floatValue]];
    _autonFactor.text = [NSString stringWithFormat:@"%.1f", [[factors objectAtIndex:0] floatValue]];
    _teleOpFactor.text = [NSString stringWithFormat:@"%.1f", [[factors objectAtIndex:1] floatValue]];
    _climbFactor.text = [NSString stringWithFormat:@"%.1f", [[factors objectAtIndex:2] floatValue]];
    _driverFactor.text = [NSString stringWithFormat:@"%.1f", [[factors objectAtIndex:3] floatValue]];
    _speedFactor.text = [NSString stringWithFormat:@"%.1f", [[factors objectAtIndex:4] floatValue]];
    _defenseFactor.text = [NSString stringWithFormat:@"%.1f", [[factors objectAtIndex:5] floatValue]];
    _height1Factor.text = [NSString stringWithFormat:@"%.1f", [[factors objectAtIndex:6] floatValue]];
    _height2Factor.text = [NSString stringWithFormat:@"%.1f", [[factors objectAtIndex:7] floatValue]];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    dataChange = YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //    NSLog(@"team should end editing");
    if (textField == _autonNormal) {
        [normals replaceObjectAtIndex:0
                            withObject:[NSNumber numberWithInt:[textField.text floatValue]]];
	}
	else if (textField == _teleOpNormal) {
        [normals replaceObjectAtIndex:1
                           withObject:[NSNumber numberWithInt:[textField.text floatValue]]];
	}
	else if (textField == _climbNormal) {
        [normals replaceObjectAtIndex:2
                           withObject:[NSNumber numberWithInt:[textField.text floatValue]]];
	}
	else if (textField == _driverNormal) {
        [normals replaceObjectAtIndex:3
                           withObject:[NSNumber numberWithInt:[textField.text floatValue]]];
	}
	else if (textField == _speedNormal) {
        [normals replaceObjectAtIndex:4
                           withObject:[NSNumber numberWithInt:[textField.text floatValue]]];
	}
	else if (textField == _defenseNormal) {
        [normals replaceObjectAtIndex:5
                           withObject:[NSNumber numberWithInt:[textField.text floatValue]]];
	}
	else if (textField == _autonFactor) {
        [factors replaceObjectAtIndex:0
                           withObject:[NSNumber numberWithInt:[textField.text floatValue]]];
	}
	else if (textField == _teleOpFactor) {
        [factors replaceObjectAtIndex:1
                           withObject:[NSNumber numberWithInt:[textField.text floatValue]]];
	}
	else if (textField == _climbFactor) {
        [factors replaceObjectAtIndex:2
                           withObject:[NSNumber numberWithInt:[textField.text floatValue]]];
	}
	else if (textField == _driverFactor) {
        [factors replaceObjectAtIndex:3
                           withObject:[NSNumber numberWithInt:[textField.text floatValue]]];
	}
	else if (textField == _speedFactor) {
        [factors replaceObjectAtIndex:4
                           withObject:[NSNumber numberWithInt:[textField.text floatValue]]];
	}
	else if (textField == _defenseFactor) {
        [factors replaceObjectAtIndex:5
                           withObject:[NSNumber numberWithInt:[textField.text floatValue]]];
	}
	else if (textField == _height1Factor) {
        [factors replaceObjectAtIndex:6
                           withObject:[NSNumber numberWithInt:[textField.text floatValue]]];
	}
	else if (textField == _height2Factor) {
        [factors replaceObjectAtIndex:7
                           withObject:[NSNumber numberWithInt:[textField.text floatValue]]];
	}
    
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    float holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    return [scan scanFloat: &holder] && [scan isAtEnd];
}

- (void) viewWillDisappear:(BOOL)animated
{
    //    NSLog(@"viewWillDisappear");
    NSString *lucienDataString;
    storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"lucienFactors.csv"];
    for (int i=0; i<[normals count]; i++) {
        
    }
    lucienDataString = [NSString stringWithFormat:@"%.1f, %.1f, %.1f, %.1f, %.1f, %.1f\n",
                        [[normals objectAtIndex:0] floatValue],
                        [[normals objectAtIndex:1] floatValue],
                        [[normals objectAtIndex:2] floatValue],
                        [[normals objectAtIndex:3] floatValue],
                        [[normals objectAtIndex:4] floatValue],
                        [[normals objectAtIndex:5] floatValue]];
    lucienDataString =  [lucienDataString stringByAppendingString:[NSString stringWithFormat:@"%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f\n",
                        [[factors objectAtIndex:0] floatValue],
                        [[factors objectAtIndex:1] floatValue],
                        [[factors objectAtIndex:2] floatValue],
                        [[factors objectAtIndex:3] floatValue],
                        [[factors objectAtIndex:4] floatValue],
                        [[factors objectAtIndex:5] floatValue],
                        [[factors objectAtIndex:6] floatValue],
                        [[factors objectAtIndex:7] floatValue]]];
    [lucienDataString writeToFile:storePath
                       atomically:YES
                         encoding:NSUTF8StringEncoding
                            error:nil];
}

- (void)retrieveSettings {
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

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setAutonFactor:nil];
    [self setTeleOpFactor:nil];
    [self setAutonNormal:nil];
    [self setTeleOpNormal:nil];
    [self setClimbNormal:nil];
    [self setClimbFactor:nil];
    [self setDriverNormal:nil];
    [self setDriverFactor:nil];
    [self setSpeedNormal:nil];
    [self setSpeedFactor:nil];
    [self setDefenseNormal:nil];
    [self setDefenseFactor:nil];
    [self setHeight1Factor:nil];
    [self setHeight2Factor:nil];
    [super viewDidUnload];
}
@end
