//
//  DownloadPageViewController.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownloadPageViewController.h"
#import "TeamData.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "DataManager.h"
#import "SettingsData.h"
#import "TournamentData.h"

@implementation DownloadPageViewController
@synthesize dataManager = _dataManager;
@synthesize managedObjectContext;
@synthesize settings;
@synthesize exportTeamData;
@synthesize exportMatchData;
@synthesize mainLogo;
@synthesize splashPicture;
@synthesize pictureCaption;
@synthesize exportPath;
@synthesize stackMobButton = _stackMobButton;
@synthesize ftpButton = _ftpButton;

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSLog(@"Download Page");
    if (!managedObjectContext) {
        if (_dataManager) {
            managedObjectContext = _dataManager.managedObjectContext;
        }
        else {
            _dataManager = [DataManager new];
            managedObjectContext = [_dataManager managedObjectContext];
        }
    }

    [self retrieveSettings];
    if (settings) {
        self.title =  [NSString stringWithFormat:@"%@ Download Page", settings.tournament.name];
    }
    else {
        self.title = @"Download Page";
    }

    // Display the Robotnauts Banner
    [mainLogo setImage:[UIImage imageNamed:@"robonauts app banner.jpg"]];
    // Set Font and Text for Export Buttons
    [exportTeamData setTitle:@"Export Team Data" forState:UIControlStateNormal];
    exportTeamData.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    [exportMatchData setTitle:@"Export Match Data" forState:UIControlStateNormal];
    exportMatchData.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    exportPath = [self applicationDocumentsDirectory];
    [_stackMobButton setTitle:@"Export to Stack Mob" forState:UIControlStateNormal];
    _stackMobButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    [_iPadExportButton setTitle:@"Export to iDevice" forState:UIControlStateNormal];
    _iPadExportButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    [_ftpButton setTitle:@"FTP" forState:UIControlStateNormal];
    _ftpButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    // Display the Label for the Picture
    pictureCaption.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    pictureCaption.text = @"Just Hangin' Out";
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [self setIPadExportButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)exportTapped:(id)sender {
    
    if (sender == exportTeamData) {
        [self emailTeamData];
    }
    else {
        [self emailMatchData];
    }
}

-(void)emailTeamData {
    NSString *filePath = [exportPath stringByAppendingPathComponent: @"TeamData.csv"];
    NSLog(@"export data file = %@", filePath);
    TeamData *team;
    NSError *error;
    NSString *csvString;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"TeamData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];

    [fetchRequest setSortDescriptors:sortDescriptors];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"saved == 1 AND ANY tournament = %@", settings.tournament];
    [fetchRequest setPredicate:pred];
    NSArray *teamData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!teamData) {
        NSLog(@"Karma disruption error");
    } 
    else {
        if ([teamData count]) {
            csvString = @"Team Number, Name, Tournament, Drive Train Type, Intake, Wheel Diameter, CIMS, Minimum Height, Maximum Height, Pyramid Dump, Climb Level, Climb Speed, Wheel Type, Notes\n";
            int c;
            for (c = 0; c < [teamData count]; c++) {
                team = [teamData objectAtIndex:c];
                csvString = [csvString stringByAppendingFormat:@"%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@ %@\n", team.number, team.name, settings.tournament.name, team.driveTrainType, team.intake, team.wheelDiameter, team.cims, team.minHeight, team.maxHeight, team.pyramidDump, team.climbLevel, team.climbSpeed, team.wheelType, ([team.notes isEqualToString:@""] ? @"," : [NSString stringWithFormat:@",\"%@\"", team.notes])];
            }
//            csvString = [csvString stringByAppendingString:@"\n"];
            // NSLog(@"csvString = %@", csvString);
            [csvString writeToFile:filePath 
                        atomically:YES 
                        encoding:NSUTF8StringEncoding 
                        error:nil];

            NSString *emailSubject = @"Team Data CSV File";
            [self buildEmail:filePath attach:@"TeamData.csv" subject:emailSubject];
        }
        else {
            NSLog(@"No saved data");
        }
    }
}


-(void)emailMatchData {
    NSString *fileDataPath = [exportPath stringByAppendingPathComponent: @"MatchData.csv"];
    NSString *fileListPath = [exportPath stringByAppendingPathComponent: @"MatchList.csv"];
    NSString *danielleDataPath = [exportPath stringByAppendingPathComponent: @"DanielleMatchData.csv"];
    NSLog(@"export data file = %@", fileDataPath);
    NSString *csvList;
    NSString *csvData;
    NSString *csvDanielleData;
    MatchData *match;
    NSArray *scoreData;
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"MatchData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    // Edit the sort key as appropriate.
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchTypeSection" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
    
    // Add the search for tournament name
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournament CONTAINS %@", settings.tournament.name];
    [fetchRequest setPredicate:pred];
    [fetchRequest setSortDescriptors:sortDescriptors];
     NSArray *matchData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!matchData) {
        NSLog(@"Karma disruption error");
    } 
    else {
        if ([matchData count]) {
            NSString *r1;
            NSString *r2;
            NSString *r3;
            NSString *b1;
            NSString *b2;
            NSString *b3;
            TeamScore *score;
            // Output two sets of data. one is just the match list, the other is the match results
            csvList = @"Match, Red 1, Red 2, Red 3, Blue 1, Blue 2, Blue 3, Type, Tournament, Red Score, Blue Score\n";
            csvData = @"Tournament, Match Type, Number, Alliance, Team Number, Saved, Driver Rating, Defense Rating, Auton High, Auton Mid, Auton Low, Auton Missed, Auton Made, Auton Attempt, TeleOp High, TeleOp Mid, TeleOp Low, TeleOp Missed, TeleOp Made, TeleOp Attempt, Climb Attempt, Climb Level, Climb Timer, Pyramid Goals, Passes, Blocks, Floor Pickup, Wall PickUp, Field Drawing, Notes\n";
            csvDanielleData = @"Team, Match #, Auton Missed, Auton Low, Auton Mid, Auton High, Auton Total, TeleOp Missed, TeleOp Low, TeleOp Mid, TeleOp High, Pyramid Goals, TeleOp Total, Passes, Blocks, Wall PickUp, Floor Pickup, Climb Attempt, Climb Success, Climb Timer, Climb Level, Driver Rating, Defense Rating, Drive Under Pyramid, Max Height, Notes\n";
            int c;
            for (c = 0; c < [matchData count]; c++) {
                match = [matchData objectAtIndex:c];
                NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"alliance" ascending:YES];
                scoreData = [[match.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];

                score = [scoreData objectAtIndex:3];
                r1 = (score.team.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [score.team.number intValue]];
                if ([score.saved intValue]) {
                    csvData = [csvData stringByAppendingFormat:@"%@, %@, %@,", match.tournament, match.matchType, match.number];
                    csvData = [csvData stringByAppendingString:[self buildMatchCSVOutput:score]];
                    csvDanielleData = [csvDanielleData stringByAppendingString:[self buildDanielleMatchCSVOutput:match forTeam:score]];
                    NSLog(@"danielle = %@", csvDanielleData);
                }
                score = [scoreData objectAtIndex:4];
                r2 = (score.team.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [score.team.number intValue]];
                if ([score.saved intValue]) {
                    csvData = [csvData stringByAppendingFormat:@"%@, %@, %@,", match.tournament, match.matchType, match.number];
                    csvData = [csvData stringByAppendingString:[self buildMatchCSVOutput:score]];
                    csvDanielleData = [csvDanielleData stringByAppendingString:[self buildDanielleMatchCSVOutput:match forTeam:score]];
                }
                score = [scoreData objectAtIndex:5];
                r3 = (score.team.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [score.team.number intValue]];
                if ([score.saved intValue]) {
                    csvData = [csvData stringByAppendingFormat:@"%@, %@, %@,", match.tournament, match.matchType, match.number];
                    csvData = [csvData stringByAppendingString:[self buildMatchCSVOutput:score]];
                    csvDanielleData = [csvDanielleData stringByAppendingString:[self buildDanielleMatchCSVOutput:match forTeam:score]];
               }
                score = [scoreData objectAtIndex:0];
                b1 = (score.team.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [score.team.number intValue]];
                if ([score.saved intValue]) {
                    csvData = [csvData stringByAppendingFormat:@"%@, %@, %@,", match.tournament, match.matchType, match.number];
                    csvData = [csvData stringByAppendingString:[self buildMatchCSVOutput:score]];
                    csvDanielleData = [csvDanielleData stringByAppendingString:[self buildDanielleMatchCSVOutput:match forTeam:score]];
                }
                score = [scoreData objectAtIndex:1];
                b2 = (score.team.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [score.team.number intValue]];
                if ([score.saved intValue]) {
                    csvData = [csvData stringByAppendingFormat:@"%@, %@, %@,", match.tournament, match.matchType, match.number];
                    csvData = [csvData stringByAppendingString:[self buildMatchCSVOutput:score]];
                    csvDanielleData = [csvDanielleData stringByAppendingString:[self buildDanielleMatchCSVOutput:match forTeam:score]];
               }
                score = [scoreData objectAtIndex:2];
                b3 = (score.team.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [score.team.number intValue]];
                if ([score.saved intValue]) {
                    csvData = [csvData stringByAppendingFormat:@"%@, %@, %@,", match.tournament, match.matchType, match.number];
                    csvData = [csvData stringByAppendingString:[self buildMatchCSVOutput:score]];
                    csvDanielleData = [csvDanielleData stringByAppendingString:[self buildDanielleMatchCSVOutput:match forTeam:score]];
                }
                csvList = [csvList stringByAppendingFormat:@"%@, %@, %@, %@, %@, %@, %@, %@,\"%@\", %@, %@\n", match.number, r1, r2, r3, b1, b2, b3, match.matchType, match.tournament, match.redScore, match.blueScore];

            }
           [csvList writeToFile:fileListPath
                      atomically:YES 
                        encoding:NSUTF8StringEncoding 
                           error:nil];

            csvData = [csvData stringByAppendingString:@"\n"];
            // NSLog(@"csvData = %@", csvData);
            [csvData writeToFile:fileDataPath 
                      atomically:YES 
                        encoding:NSUTF8StringEncoding 
                           error:nil];
            [csvDanielleData writeToFile:danielleDataPath
                      atomically:YES
                        encoding:NSUTF8StringEncoding
                           error:nil];
//            NSString *emailSubject = @"Match Data CSV Files";
//            NSArray *fileList = [[NSArray alloc] initWithObjects:fileListPath, fileDataPath, danielleDataPath,nil];
//            NSArray *attachList = [[NSArray alloc] initWithObjects:@"MatchList.csv", @"MatchData.csv", @"DanielleMatch Data.csv", nil];
 
//            [self buildEmail:fileList attach:attachList subject:emailSubject];
        }
        else {
            NSLog(@"No match data");
        }
    }
}

-(NSString *)buildDanielleMatchCSVOutput:(MatchData *)match forTeam:(TeamScore *)teamScore {
    NSString *csvDataString;
    
    if (teamScore) {
        csvDataString = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",
                         teamScore.team.number,
                         match.number,
                         teamScore.autonMissed,
                         teamScore.autonLow,
                         teamScore.autonMid,
                         teamScore.autonHigh,
                         teamScore.totalAutonShots,
                         teamScore.teleOpMissed,
                         teamScore.teleOpLow,
                         teamScore.teleOpMid,
                         teamScore.teleOpHigh,
                         teamScore.pyramid,
                         teamScore.totalTeleOpShots,
                         teamScore.passes,
                         teamScore.blocks,
                         teamScore.wallPickUp,
                         teamScore.floorPickUp,
                         teamScore.climbAttempt,
                         ([teamScore.climbLevel intValue] == 0) ? @"N" : @"Y",      // Climb Success
                         teamScore.climbTimer,
                         teamScore.climbLevel,
                         teamScore.driverRating,
                         teamScore.defenseRating,
                         ([teamScore.team.minHeight floatValue] < 28.5) ? @"Y" : @"N",      // drive under pyramid
                         teamScore.team.maxHeight,
                         (teamScore.notes == nil) ? @"," : [NSString stringWithFormat:@",\"%@\"", teamScore.notes]];
    }
    else {
        csvDataString = @"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,,";
        // NSLog(@"csvDataString = %@", csvDataString);
    }
    return csvDataString;
}

-(NSString *)buildMatchCSVOutput:(TeamScore *)teamScore {
    // NSLog(@"buildMatchCSV");
    NSString *csvDataString;

    if (teamScore) {
        csvDataString = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@%@%@\n",
                teamScore.alliance,
                teamScore.team.number,
                teamScore.saved,
                teamScore.driverRating,
                teamScore.defenseRating,
                teamScore.autonHigh,
                teamScore.autonMid,
                teamScore.autonLow,
                teamScore.autonMissed,
                teamScore.autonShotsMade,
                teamScore.totalAutonShots,
                teamScore.teleOpHigh,
                teamScore.teleOpMid,
                teamScore.teleOpLow,
                teamScore.teleOpMissed,
                teamScore.teleOpShots,
                teamScore.totalTeleOpShots,
                teamScore.climbAttempt,
                teamScore.climbLevel,
                teamScore.climbTimer,
                teamScore.pyramid,
                teamScore.passes,
                teamScore.blocks,
                teamScore.floorPickUp,
                teamScore.wallPickUp,
                teamScore.wallPickUp1,
                teamScore.wallPickUp2,
                teamScore.wallPickUp3,
                teamScore.wallPickUp4,
                (teamScore.fieldDrawing == nil) ? @"," : [NSString stringWithFormat:@",\"%@\"", teamScore.fieldDrawing],
                (teamScore.notes == nil) ? @"," : [NSString stringWithFormat:@",\"%@\"", teamScore.notes]];
        
        // NSLog(@"csvDataString = %@", csvDataString);
    }
    else {
        csvDataString = @"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,,\n";        
        // NSLog(@"csvDataString = %@", csvDataString);
    }
    return csvDataString;                   
}


-(void)buildEmail:(NSString *)filePath attach:(NSString *)emailFile subject:(NSString *)emailSubject {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    NSArray *array = [[NSArray alloc] initWithObjects:@"kpettinger@comcast.net", @"BESTRobonauts@gmail.com",nil];
    [picker setSubject:emailSubject];
    [picker setToRecipients:array];
    [picker setMessageBody:@"Downloaded Data from UltimateAscent" isHTML:NO];
    [picker setMailComposeDelegate:self];

    NSData *ultimateData = [[NSData alloc] initWithContentsOfFile:filePath];
    if (ultimateData) {
            [picker addAttachmentData:ultimateData mimeType:@"application/UltimateAscent" fileName:emailFile];
    }
    else {
        NSLog(@"Error encoding data for email");
    }
    [self presentModalViewController:picker animated:YES];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDataManager:_dataManager];
}

-(void)retrieveSettings {
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
            exportTeamData.frame = CGRectMake(325, 125, 400, 68);
            exportMatchData.frame = CGRectMake(325, 225, 400, 68);
            _stackMobButton.frame = CGRectMake(325, 325, 400, 68);
            _iPadExportButton.frame = CGRectMake(325, 425, 400, 68);
            _ftpButton.frame = CGRectMake(325, 525, 400, 68);
            splashPicture.frame = CGRectMake(293, 563, 468, 330);
            pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            mainLogo.frame = CGRectMake(0, -60, 1024, 255);
            [mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            exportTeamData.frame = CGRectMake(550, 225, 400, 68);
            exportMatchData.frame = CGRectMake(550, 325, 400, 68);
            _stackMobButton.frame = CGRectMake(550, 425, 400, 68);
            _iPadExportButton.frame = CGRectMake(550, 525, 400, 68);
            _ftpButton.frame = CGRectMake(550, 625, 400, 68);
            splashPicture.frame = CGRectMake(50, 243, 468, 330);
            pictureCaption.frame = CGRectMake(50, 581, 468, 39);
            break;
        default:
            break;
    }
    // Return YES for supported orientations
	return YES;
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
