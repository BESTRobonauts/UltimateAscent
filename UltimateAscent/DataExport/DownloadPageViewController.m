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
@synthesize managedObjectContext;
@synthesize settings;
@synthesize exportTeamData;
@synthesize exportMatchData;
@synthesize mainLogo;
@synthesize splashPicture;
@synthesize pictureCaption;
@synthesize exportPath;

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
       DataManager *dataManager = [DataManager new];
       managedObjectContext = [dataManager managedObjectContext];
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
    [exportTeamData setTitle:@"Email Team Data" forState:UIControlStateNormal];
    exportTeamData.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    [exportMatchData setTitle:@"Email Match Data" forState:UIControlStateNormal];
    exportMatchData.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:24.0];
    exportPath = [self applicationDocumentsDirectory];
    [super viewDidLoad];
}


- (void)viewDidUnload
{
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
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"saved == 1"];
//    [fetchRequest setPredicate:pred];
    NSArray *teamData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!teamData) {
        NSLog(@"Karma disruption error");
    } 
    else {
        if ([teamData count]) {
            csvString = @"Team Number, Name, climbType, intakeFloor, intakeInverted, intakeStation, Drive Train Notes, Notes, History";
            int c;
            for (c = 0; c < [teamData count]; c++) {
                team = [teamData objectAtIndex:c];
                csvString = [csvString stringByAppendingFormat:@"\n%@, %@, %@, %@, %@, %@%@%@%@", team.number, team.name, team.climbType, team.intakeFloor, team.intakeInverted, team.intakeStation,
                             ([team.driveTrainNotes isEqualToString:@""] ? @"," : [NSString stringWithFormat:@",\"%@\"", team.driveTrainNotes]),
                             ([team.notes isEqualToString:@""] ? @"," : [NSString stringWithFormat:@",\"%@\"", team.notes]),
                             ([team.history isEqualToString:@""] ? @"," : [NSString stringWithFormat:@",\"%@\"", team.history])];
            }
            csvString = [csvString stringByAppendingString:@"\n"];
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
    NSLog(@"export data file = %@", fileDataPath);
    NSString *csvList;
    NSString *csvData;
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
            csvList = @"Match, Red 1, Red 2, Red 3, Blue 1, Blue 2, Blue 3, Type, Tournament\n";
            csvData = @"Tournament, Match Type, Number, Alliance, Team Number, Saved, Driver Rating, Defense Rating, Auton High, Auton Mid, Auton Low, Auton Missed, TeleOp High, TeleOp Mid, TeleOp Low, TeleOp Missed, Climb Success, Climb Level, Climb Timer, Pyramid Goals, Passes, Blocks, Floor Pickup, Wall PickUp, Notes\n";
            int c;
            for (c = 0; c < [matchData count]; c++) {
                match = [matchData objectAtIndex:c];
                NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"alliance" ascending:YES];
                scoreData = [[match.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];

                score = [scoreData objectAtIndex:3];
                r1 = (score.team.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [score.team.number intValue]];
                csvData = [csvData stringByAppendingFormat:@"\n%@, %@, %@,", match.tournament, match.matchType, match.number];
                csvData = [csvData stringByAppendingString:[self buildMatchCSVOutput:score]];

                score = [scoreData objectAtIndex:4];
                r2 = (score.team.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [score.team.number intValue]];
                csvData = [csvData stringByAppendingFormat:@"\n%@, %@, %@,", match.tournament, match.matchType, match.number];
                csvData = [csvData stringByAppendingString:[self buildMatchCSVOutput:score]];

                score = [scoreData objectAtIndex:5];
                r3 = (score.team.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [score.team.number intValue]];
                csvData = [csvData stringByAppendingFormat:@"\n%@, %@, %@,", match.tournament, match.matchType, match.number];
                csvData = [csvData stringByAppendingString:[self buildMatchCSVOutput:score]];

                score = [scoreData objectAtIndex:0];
                b1 = (score.team.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [score.team.number intValue]];
                csvData = [csvData stringByAppendingFormat:@"\n%@, %@, %@,", match.tournament, match.matchType, match.number];
                csvData = [csvData stringByAppendingString:[self buildMatchCSVOutput:score]];
                score = [scoreData objectAtIndex:1];
                b2 = (score.team.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [score.team.number intValue]];
                csvData = [csvData stringByAppendingFormat:@"\n%@, %@, %@,", match.tournament, match.matchType, match.number];
                csvData = [csvData stringByAppendingString:[self buildMatchCSVOutput:score]];
                score = [scoreData objectAtIndex:2];
                b3 = (score.team.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [score.team.number intValue]];
                csvData = [csvData stringByAppendingFormat:@"\n%@, %@, %@,", match.tournament, match.matchType, match.number];
                csvData = [csvData stringByAppendingString:[self buildMatchCSVOutput:score]];

                csvList = [csvList stringByAppendingFormat:@"\n%@,%@,%@,%@,%@,%@,%@,%@,\"%@\"", match.number, r1, r2, r3, b1, b2, b3, match.matchType, match.tournament];

            }
            [csvList writeToFile:fileListPath 
                      atomically:YES 
                        encoding:NSUTF8StringEncoding 
                           error:nil];
            NSString *emailSubject = @"Match List CSV File";
//            [self buildEmail:fileListPath attach:@"Match List.csv" subject:emailSubject];

            csvData = [csvData stringByAppendingString:@"\n"];
            // NSLog(@"csvData = %@", csvData);
            [csvData writeToFile:fileDataPath 
                      atomically:YES 
                        encoding:NSUTF8StringEncoding 
                           error:nil];
            emailSubject = @"Match Data CSV File";
 //           [self buildEmail:fileDataPath attach:@"Match Data.csv" subject:emailSubject];
        }
        else {
            NSLog(@"No match data");
        }
    }
}
                           
-(NSString *)buildMatchCSVOutput:(TeamScore *)teamScore {
    // NSLog(@"buildMatchCSV");
    NSString *csvDataString;

    if (teamScore) {
        csvDataString = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",
                teamScore.alliance,
                teamScore.team.number,
                teamScore.saved,
                teamScore.driverRating,
                teamScore.defenseRating,
                teamScore.autonHigh,
                teamScore.autonMid,
                teamScore.autonLow,
                teamScore.autonMissed,
                teamScore.teleOpHigh,
                teamScore.teleOpMid,
                teamScore.teleOpLow,
                teamScore.teleOpMissed,
                teamScore.climbSuccess,
                teamScore.climbLevel,
                teamScore.climbTimer,
                teamScore.pyramid,
                teamScore.passes,
                teamScore.blocks,
                teamScore.pickups,
                (teamScore.notes == nil) ? @"," : [NSString stringWithFormat:@",\"%@\"", teamScore.notes]];
        
        // NSLog(@"csvDataString = %@", csvDataString);
    }
    else {
        csvDataString = @"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,,";        
        // NSLog(@"csvDataString = %@", csvDataString);
    }
    return csvDataString;                   
}


-(void)buildEmail:(NSString *)filePath attach:(NSString *)emailFile subject:(NSString *)emailSubject { /*
    NSData *reboundData = [[NSData alloc] initWithContentsOfFile:filePath];
    if (reboundData) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        [picker setSubject:emailSubject];
        [picker addAttachmentData:reboundData mimeType:@"application/UltimateAscent" fileName:emailFile];
        NSArray *array = [[NSArray alloc] initWithObjects:@"kpettinger@comcast.net", @"BESTRobonauts@gmail.com",nil];
        [picker setToRecipients:array];
        [picker setMessageBody:@"Downloaded Data from UltimateAscent" isHTML:NO];
        [picker setMailComposeDelegate:self];
        [self presentModalViewController:picker animated:YES];               
    }
    else {
        NSLog(@"Error encoding data for email");
    }*/
}

-(void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
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
            splashPicture.frame = CGRectMake(293, 563, 468, 330);
            pictureCaption.frame = CGRectMake(293, 901, 468, 39);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            mainLogo.frame = CGRectMake(0, -60, 1024, 255);
            [mainLogo setImage:[UIImage imageNamed:@"robonauts app banner original.jpg"]];
            exportTeamData.frame = CGRectMake(550, 225, 400, 68);
            exportMatchData.frame = CGRectMake(550, 325, 400, 68);
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
