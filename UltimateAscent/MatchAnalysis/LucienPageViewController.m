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
#import "TeamData.h"
#import "TeamScore.h"
#import "MatchData.h"
#import "PopUpPickerViewController.h"
#import "parseCSV.h"
#import "LucienNumberObject.h"
#import "LucienTableViewController.h"

@interface LucienPageViewController ()

@end

@implementation LucienPageViewController {
    NSMutableArray *averages;
    NSMutableArray *normals;
    NSMutableArray *factors;
    BOOL dataChange;
    NSFileManager *fileManager;
    NSString *storePath;
    id popUp;
    NSMutableArray *lucienList;
}
@synthesize dataManager = _dataManager;
@synthesize averagePicker = _averagePicker;
@synthesize averageList = _averageList;
@synthesize averagePickerPopover = _averagePickerPopover;
@synthesize heightPicker = _heightPicker;
@synthesize heightList = _heightList;
@synthesize heightPickerPopover = _heightPickerPopover;
@synthesize autonAverage = _autonAverage;
@synthesize autonNormal = _autonNormal;
@synthesize autonFactor = _autonFactor;
@synthesize teleOpAverage = _teleOpAverage;
@synthesize teleOpNormal = _teleOpNormal;
@synthesize teleOpFactor = _teleOpFactor;
@synthesize climbAverage = _climbAverage;
@synthesize climbNormal = _climbNormal;
@synthesize climbFactor = _climbFactor;
@synthesize driverAverage = _driverAverage;
@synthesize driverNormal = _driverNormal;
@synthesize driverFactor = _driverFactor;
@synthesize speedAverage = _speedAverage;
@synthesize speedNormal = _speedNormal;
@synthesize speedFactor = _speedFactor;
@synthesize defenseAverage = _defenseAverage;
@synthesize defenseNormal = _defenseNormal;
@synthesize defenseFactor = _defenseFactor;
@synthesize height1Normal = _height1Normal;
@synthesize height1Average = _height1Average;
@synthesize height1Factor = _height1Factor;
@synthesize height2Normal = _height2Normal;
@synthesize height2Average = _height2Average;
@synthesize height2Factor = _height2Factor;
@synthesize calculateButton = _calculateButton;

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

    _averageList = [[NSMutableArray alloc] initWithObjects:
                    @"All", @"Top One", @"Top 2", @"Top 3", @"Top 4", @"Top 5", @"Top 6", @"Top 7", @"Top 8", @"Top 9", @"Top 10", @"Top 11", nil];
    _heightList = [[NSMutableArray alloc] initWithObjects:
                    @"<", @">", nil];

    averages = [[NSMutableArray alloc] initWithObjects:
                [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0], nil];

    normals = [[NSMutableArray alloc] initWithObjects:
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0], nil];
    factors = [[NSMutableArray alloc] initWithObjects:
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0],
               [NSNumber numberWithFloat:1.0], nil];

    storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"lucienFactors.csv"];
    fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:storePath]) {
        CSVParser *parser = [CSVParser new];
        [parser openFile: storePath];
        NSMutableArray *csvContent = [parser parseFile];
        float junk;
        int stupid;
        for (int i=0; i<[[csvContent objectAtIndex:0] count]; i++) {
            stupid = [[[csvContent objectAtIndex:0] objectAtIndex:i] intValue];
            [averages replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:stupid]];
            junk = [[[csvContent objectAtIndex:1] objectAtIndex:i] floatValue];
            [normals replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:junk]];
            junk = [[[csvContent objectAtIndex:2] objectAtIndex:i] floatValue];
            [factors replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:junk]];
        }
    }
    // Set Font and Text for Calculate Button
    [_calculateButton setTitle:@"Calculate Lucien Number" forState:UIControlStateNormal];
    _calculateButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    
    [self setDisplayData];
}

-(void)setDisplayData {
    int index = [[averages objectAtIndex:0] intValue];
    [_autonAverage setTitle:[_averageList objectAtIndex:index] forState:UIControlStateNormal];
    index = [[averages objectAtIndex:1] intValue];
    [_teleOpAverage setTitle:[_averageList objectAtIndex:index] forState:UIControlStateNormal];
    index = [[averages objectAtIndex:2] intValue];
    [_climbAverage setTitle:[_averageList objectAtIndex:index] forState:UIControlStateNormal];
    index = [[averages objectAtIndex:3] intValue];
    [_driverAverage setTitle:[_averageList objectAtIndex:index] forState:UIControlStateNormal];
    index = [[averages objectAtIndex:4] intValue];
    [_speedAverage setTitle:[_averageList objectAtIndex:index] forState:UIControlStateNormal];
    index = [[averages objectAtIndex:5] intValue];
    [_defenseAverage setTitle:[_averageList objectAtIndex:index] forState:UIControlStateNormal];
    index = [[averages objectAtIndex:6] intValue];
    [_height1Average setTitle:[_heightList objectAtIndex:index] forState:UIControlStateNormal];
    index = [[averages objectAtIndex:7] intValue];
    [_height2Average setTitle:[_heightList objectAtIndex:index] forState:UIControlStateNormal];

    _autonNormal.text = [NSString stringWithFormat:@"%.1f", [[normals objectAtIndex:0] floatValue]];
    _teleOpNormal.text = [NSString stringWithFormat:@"%.1f", [[normals objectAtIndex:1] floatValue]];
    _climbNormal.text = [NSString stringWithFormat:@"%.1f", [[normals objectAtIndex:2] floatValue]];
    _driverNormal.text = [NSString stringWithFormat:@"%.1f", [[normals objectAtIndex:3] floatValue]];
    _speedNormal.text = [NSString stringWithFormat:@"%.1f", [[normals objectAtIndex:4] floatValue]];
    _defenseNormal.text = [NSString stringWithFormat:@"%.1f", [[normals objectAtIndex:5] floatValue]];
    _height1Normal.text = [NSString stringWithFormat:@"%.1f", [[normals objectAtIndex:6] floatValue]];
    _height2Normal.text = [NSString stringWithFormat:@"%.1f", [[normals objectAtIndex:7] floatValue]];

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
                            withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
	else if (textField == _teleOpNormal) {
        [normals replaceObjectAtIndex:1
                           withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
	else if (textField == _climbNormal) {
        [normals replaceObjectAtIndex:2
                           withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
	else if (textField == _driverNormal) {
        [normals replaceObjectAtIndex:3
                           withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
	else if (textField == _speedNormal) {
        [normals replaceObjectAtIndex:4
                           withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
	else if (textField == _defenseNormal) {
        [normals replaceObjectAtIndex:5
                           withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
	else if (textField == _height1Normal) {
        [normals replaceObjectAtIndex:6
                           withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
	else if (textField == _height2Normal) {
        [normals replaceObjectAtIndex:7
                           withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
	else if (textField == _autonFactor) {
        [factors replaceObjectAtIndex:0
                           withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
	else if (textField == _teleOpFactor) {
        [factors replaceObjectAtIndex:1
                           withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
	else if (textField == _climbFactor) {
        [factors replaceObjectAtIndex:2
                           withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
	else if (textField == _driverFactor) {
        [factors replaceObjectAtIndex:3
                           withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
	else if (textField == _speedFactor) {
        [factors replaceObjectAtIndex:4
                           withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
	else if (textField == _defenseFactor) {
        [factors replaceObjectAtIndex:5
                           withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
	else if (textField == _height1Factor) {
        [factors replaceObjectAtIndex:6
                           withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
	else if (textField == _height2Factor) {
        [factors replaceObjectAtIndex:7
                           withObject:[NSNumber numberWithFloat:[textField.text floatValue]]];
	}
    
	return YES;
}

- (IBAction)selectAverage:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (_averagePicker == nil) {
        self.averagePicker = [[PopUpPickerViewController alloc]
                                 initWithStyle:UITableViewStylePlain];
        _averagePicker.delegate = self;
        _averagePicker.pickerChoices = _averageList;
        self.averagePickerPopover = [[UIPopoverController alloc]
                                        initWithContentViewController:_averagePicker];
    }
    _averagePicker.pickerChoices = _averageList;
    popUp = sender;
    [self.averagePickerPopover presentPopoverFromRect:button.bounds inView:button
                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)selectHeight:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (_heightPicker == nil) {
        self.heightPicker = [[PopUpPickerViewController alloc]
                              initWithStyle:UITableViewStylePlain];
        _heightPicker.delegate = self;
        _heightPicker.pickerChoices = _heightList;
        self.heightPickerPopover = [[UIPopoverController alloc]
                                     initWithContentViewController:_heightPicker];
    }
    _heightPicker.pickerChoices = _heightList;
    popUp = sender;
    [self.heightPickerPopover presentPopoverFromRect:button.bounds inView:button
                             permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    lucienList = [NSMutableArray array];

    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Add the search for tournament name
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournament = %@", _settings.tournament];
    [fetchRequest setPredicate:pred];
    NSArray *teamData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  
    for (int i=0; i<[teamData count]; i++) {
        TeamData *team = [teamData objectAtIndex:i];
        LucienNumberObject *lucienNumbers = [[LucienNumberObject alloc] init];
        // NSLog(@"Team = %@, min height = %@, max height = %.@", team.number, team.minHeight, team.maxHeight);
        lucienNumbers.teamNumber = [team.number intValue];
        NSArray *allMatches = [team.match allObjects];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournament = %@", _settings.tournament];
        NSArray *matches = [allMatches filteredArrayUsingPredicate:pred];
        NSMutableArray *autonList = [NSMutableArray array];
        NSMutableArray *teleOpList = [NSMutableArray array];
        NSMutableArray *drivingList = [NSMutableArray array];
        NSMutableArray *defenseList = [NSMutableArray array];
        NSMutableArray *speedList = [NSMutableArray array];
        NSMutableArray *hangPointsList = [NSMutableArray array];
        for (int j=0; j<[matches count]; j++) {
            TeamScore *score = [matches objectAtIndex:j];
            int autonPoints = 0;
            int teleOpPoints = 0;
            float hangpoints = 0.0;
           // Only use Seeding or Elimination matches that have been saved or synced
            if ( ([score.match.matchType isEqualToString:@"Seeding"]
                  || [score.match.matchType isEqualToString:@"Elimination"])
                && ([score.saved intValue] || [score.synced intValue])) {
                autonPoints = [score.autonHigh intValue]*6 + [score.autonMid intValue]*5 + [score.autonLow intValue]*4;
                [autonList addObject:[NSNumber numberWithInt:autonPoints]];
                teleOpPoints = [score.teleOpHigh intValue]*3 + [score.teleOpMid intValue]*2 + [score.teleOpLow intValue]*1;
                [teleOpList addObject:[NSNumber numberWithInt:teleOpPoints]];
                [drivingList addObject:score.driverRating];
                [defenseList addObject:score.defenseRating];
                [speedList addObject:score.robotSpeed];
                hangpoints = [score.climbLevel intValue]*10 + [score.pyramid intValue]*5;
                [hangPointsList addObject:[NSNumber numberWithInt:hangpoints]];
            }
        }
        //NSLog(@"Auton List = %@", autonList);
        lucienNumbers.autonNumber = [self calculateNumbers:autonList forAverage:[averages objectAtIndex:0] forNormal:[normals objectAtIndex:0] forFactor:[factors objectAtIndex:0]];
        //NSLog(@"Auton magic number = %.2f", lucienNumbers.autonNumber);

        //NSLog(@"TeleOp List = %@", teleOpList);
        lucienNumbers.teleOpNumber = [self calculateNumbers:teleOpList forAverage:[averages objectAtIndex:1] forNormal:[normals objectAtIndex:1] forFactor:[factors objectAtIndex:1]];
        //NSLog(@"Teleop magic number = %.2f", lucienNumbers.teleOpNumber);

        //NSLog(@"Hanging List = %@", hangPointsList);
        lucienNumbers.hangingNumber = [self calculateNumbers:hangPointsList forAverage:[averages objectAtIndex:2] forNormal:[normals objectAtIndex:2] forFactor:[factors objectAtIndex:2]];
        //NSLog(@"Hanging magic number = %.2f", lucienNumbers.hangingNumber);

        //NSLog(@"Driving List = %@", drivingList);
        lucienNumbers.drivingNumber = [self calculateNumbers:drivingList forAverage:[averages objectAtIndex:3] forNormal:[normals objectAtIndex:3] forFactor:[factors objectAtIndex:3]];
        //NSLog(@"Driving magic number = %.2f", lucienNumbers.drivingNumber);

        //NSLog(@"Speed List = %@", speedList);
        lucienNumbers.speedNumber = [self calculateNumbers:speedList forAverage:[averages objectAtIndex:4] forNormal:[normals objectAtIndex:4] forFactor:[factors objectAtIndex:4]];
        //NSLog(@"Speed magic number = %.2f", lucienNumbers.speedNumber);

        //NSLog(@"Defense List = %@", defenseList);
        lucienNumbers.defenseNumber = [self calculateNumbers:defenseList forAverage:[averages objectAtIndex:5] forNormal:[normals objectAtIndex:5] forFactor:[factors objectAtIndex:5]];
        //NSLog(@"Defense magic number = %.2f", lucienNumbers.defenseNumber);
 
        //NSLog(@"Height check = %d", ([team.minHeight floatValue] < [[normals objectAtIndex:6] floatValue]));
        lucienNumbers.height1Number = ([team.minHeight floatValue] < [[normals objectAtIndex:6] floatValue]) * [[factors objectAtIndex:6] floatValue];
        lucienNumbers.height2Number = ([team.maxHeight floatValue] < [[normals objectAtIndex:7] floatValue]) * [[factors objectAtIndex:7] floatValue];
        
        lucienNumbers.lucienNumber = lucienNumbers.autonNumber +
                                     lucienNumbers.teleOpNumber +
                                     lucienNumbers.hangingNumber +
                                     lucienNumbers.drivingNumber +
                                     lucienNumbers.speedNumber +
                                     lucienNumbers.defenseNumber +
                                     lucienNumbers.height1Number +
                                     lucienNumbers.height2Number;
        
        [lucienList addObject:lucienNumbers];
    }
    // Create the Lucien table view controller and set the data.
    LucienTableViewController *lucienTableViewController = [segue destinationViewController];
    lucienTableViewController.lucienNumbers = lucienList;
}

-(float)calculateNumbers:(NSMutableArray *)list forAverage:(NSNumber *)average forNormal:(NSNumber *)normal forFactor:(NSNumber *)factor {
    float magicNumber = 0.0;
    int count = 0;
    
    if ([average intValue] == 0) {
        count = [list count];
    }
    else {
        count = [average intValue];
        NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO];
        [list sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    }

    float score = 0.0;
    for (int i=0; i<count; i++) {
        score += [[list objectAtIndex:i] intValue];
    }
    
    float ave = score / count;
    float norm = [normal floatValue];
    if (fabs(norm) < 1.0e-6) {
        norm = 1.0;
    }
    magicNumber = ave/norm * [factor floatValue];
    return magicNumber;
}

- (void)pickerSelected:(NSString *)newPick {
    dataChange = YES;
    int which;
    if (popUp == _autonAverage) which = 0;
    else if (popUp == _teleOpAverage) which = 1;
    else if (popUp == _climbAverage) which = 2;
    else if (popUp == _driverAverage) which = 3;
    else if (popUp == _speedAverage) which = 4;
    else if (popUp == _defenseAverage) which = 5;
    else if (popUp == _height1Average) which = 6;
    else if (popUp == _height2Average) which = 7;
    
    if (popUp == _height1Average || popUp == _height2Average) {
        [self.heightPickerPopover dismissPopoverAnimated:YES];
        for (int i = 0 ; i < [_heightList count] ; i++) {
            if ([newPick isEqualToString:[_heightList objectAtIndex:i]]) {
                [popUp setTitle:newPick forState:UIControlStateNormal];
                [averages replaceObjectAtIndex:which withObject:[NSNumber numberWithInt:i]];
                break;
            }
        }        
    }
    else {
        [self.averagePickerPopover dismissPopoverAnimated:YES];
        for (int i = 0 ; i < [_averageList count] ; i++) {
            if ([newPick isEqualToString:[_averageList objectAtIndex:i]]) {
                [popUp setTitle:newPick forState:UIControlStateNormal];
                [averages replaceObjectAtIndex:which withObject:[NSNumber numberWithInt:i]];
                break;
            }
        }
    }
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
    lucienDataString = [NSString stringWithFormat:@"%d, %d, %d, %d, %d, %d, %d, %d\n",
                        [[averages objectAtIndex:0] intValue],
                        [[averages objectAtIndex:1] intValue],
                        [[averages objectAtIndex:2] intValue],
                        [[averages objectAtIndex:3] intValue],
                        [[averages objectAtIndex:4] intValue],
                        [[averages objectAtIndex:5] intValue],
                        [[averages objectAtIndex:6] intValue],
                        [[averages objectAtIndex:7] intValue]];
    lucienDataString = [lucienDataString stringByAppendingString:[NSString stringWithFormat:@"%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f\n",
                        [[normals objectAtIndex:0] floatValue],
                        [[normals objectAtIndex:1] floatValue],
                        [[normals objectAtIndex:2] floatValue],
                        [[normals objectAtIndex:3] floatValue],
                        [[normals objectAtIndex:4] floatValue],
                        [[normals objectAtIndex:5] floatValue],
                        [[normals objectAtIndex:6] floatValue],
                        [[normals objectAtIndex:7] floatValue]]];
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
    [self setAutonAverage:nil];
    [self setTeleOpAverage:nil];
    [self setClimbAverage:nil];
    [self setDriverAverage:nil];
    [self setDriverAverage:nil];
    [self setSpeedAverage:nil];
    [self setDefenseAverage:nil];
    [self setHeight1Average:nil];
    [self setHeight2Average:nil];
    [self setHeight1Normal:nil];
    [self setHeight2Normal:nil];
    [self setCalculateButton:nil];
    [super viewDidUnload];
}
@end
