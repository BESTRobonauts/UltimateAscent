//
//  DownloadPageViewController.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownloadPageViewController.h"
//#import "TeamData.h"
//#import "MatchData.h"
//#import "TeamScore.h"
//#import "SpecificGameData.h"
//#import "EndGameData.h"
#import "DataManager.h"

@implementation DownloadPageViewController
@synthesize managedObjectContext;
@synthesize exportTeamData;
@synthesize exportMatchData;
@synthesize mainLogo;
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
    self.title = @"Download Page";
    if (!managedObjectContext) {
       DataManager *dataManager = [DataManager new];
       managedObjectContext = [dataManager managedObjectContext];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)exportTapped:(id)sender {
    
    if (sender == exportTeamData) {
        [self emailTeamData];
    }
    else {
        [self emailMatchData];
    }
}

-(void)emailTeamData {/*
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
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"saved == 1"];    
    [fetchRequest setPredicate:pred];    
    NSArray *teamData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!teamData) {
        NSLog(@"Karma disruption error");
    } 
    else {
        if ([teamData count]) {
            csvString = @"Team Number, Name, Orientation, Brakes, Balance, Moding, Drive Train Notes, Notes";
            int c;
            for (c = 0; c < [teamData count]; c++) {
                team = [teamData objectAtIndex:c];
                csvString = [csvString stringByAppendingFormat:@"\n%@, %@, %@, %@, %@, %@%@%@", team.number, team.name, team.orientation, team.brakes, team.balance, team.moding, 
                    ([team.drivetrain isEqualToString:@""] ? @"," : [NSString stringWithFormat:@",\"%@\"", team.drivetrain]), 
                             ([team.notes isEqualToString:@""] ? @"," : [NSString stringWithFormat:@",\"%@\"", team.notes])];         
         

                NSLog(@"%@,%@,%@,%@,%@,%@,\"%@\",\"%@\"", team.number, team.name, team.orientation, team.brakes, team.balance, team.moding, team.drivetrain, team.notes);
            } 
            csvString = [csvString stringByAppendingString:@"\n"];
            NSLog(@"csvString = %@", csvString);
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
    }*/
}


-(void)emailMatchData {/*
    NSString *fileDataPath = [exportPath stringByAppendingPathComponent: @"MatchData.csv"];
    NSString *fileListPath = [exportPath stringByAppendingPathComponent: @"MatchList.csv"];
    NSLog(@"export data file = %@", fileDataPath);
    NSString *csvList;
    NSString *csvData;
    MatchData *match;
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"MatchData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    
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
            // Output two sets of data. one is just the match list, the other is the match results            
            csvList = @"Match, Red 1, Red 2, Red 3, Blue 1, Blue 2, Blue 3, Type, Tournament";
            csvData = @"Tournament, Match Type, Number, Alliance, Team Number, Saved, Driver Rating, Auton High, Auton Mid, Auton Low, Auton Missed, TeleOp High, TeleOp Mid, TeleOp Low, TeleOp Missed, Crosses Hump, Moded Ramp, Co-op Balance, Balance, Notes";
            int c;
            for (c = 0; c < [matchData count]; c++) {
                match = [matchData objectAtIndex:c];
                r1 = (match.red1.teamInfo.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [match.red1.teamInfo.number intValue]];
                r2 = (match.red2.teamInfo.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [match.red2.teamInfo.number intValue]];
                r3 = (match.red3.teamInfo.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [match.red3.teamInfo.number intValue]];
                b1 = (match.blue1.teamInfo.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [match.blue1.teamInfo.number intValue]];
                b2 = (match.blue2.teamInfo.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [match.blue2.teamInfo.number intValue]];
                b3 = (match.blue3.teamInfo.number == nil) ? @"0" : [NSString stringWithFormat:@"%d", [match.blue3.teamInfo.number intValue]];
                csvList = [csvList stringByAppendingFormat:@"\n%@,%@,%@,%@,%@,%@,%@,%@,\"%@\"", match.number, r1, r2, r3, b1, b2, b3, match.matchType, match.tournament];

                csvData = [csvData stringByAppendingFormat:@"\n%@, %@, %@, Red 1,", match.tournament, match.matchType, match.number]; 
                csvData = [csvData stringByAppendingString:[self buildMatchCSVOutput:match.red1]];
                NSLog(@"csvData = %@", csvData);
            } 
            csvList = [csvList stringByAppendingString:@"\n"];
            NSLog(@"csvList = %@", csvList);
            [csvList writeToFile:fileListPath 
                      atomically:YES 
                        encoding:NSUTF8StringEncoding 
                           error:nil];
            NSString *emailSubject = @"Match List CSV File";
            [self buildEmail:fileListPath attach:@"Match List.csv" subject:emailSubject];

            csvData = [csvData stringByAppendingString:@"\n"];
            NSLog(@"csvData = %@", csvData);
            [csvData writeToFile:fileDataPath 
                      atomically:YES 
                        encoding:NSUTF8StringEncoding 
                           error:nil];
            emailSubject = @"Match Data CSV File";
            [self buildEmail:fileDataPath attach:@"Match Data.csv" subject:emailSubject];
        }
        else {
            NSLog(@"No match data");
        }
    }*/
}
                           
-(NSString *)buildMatchCSVOutput:(TeamScore *)teamScore {/*
    NSLog(@"buildMatchCSV");
    NSString *csvDataString;

    if (teamScore) {
        csvDataString = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",
                   teamScore.teamInfo.number, 
                   teamScore.saved, 
                   teamScore.driverRating, 
                   teamScore.autonScore.highBaskets, 
                   teamScore.autonScore.midBaskets, 
                   teamScore.autonScore.lowBaskets, 
                   teamScore.autonScore.missedBaskets, 
                   teamScore.teleOpScore.highBaskets, 
                   teamScore.teleOpScore.midBaskets, 
                   teamScore.teleOpScore.lowBaskets, 
                   teamScore.teleOpScore.missedBaskets, 
                   teamScore.teleOpScore.crossesHump, 
                   teamScore.endGameScore.modedRamp, 
                   teamScore.endGameScore.coopRamp, 
                   teamScore.endGameScore.balanced, 
                   (teamScore.notes == nil) ? @"," : [NSString stringWithFormat:@",\"%@\"", teamScore.notes]];        
        
        NSLog(@"csvDataString = %@", csvDataString);
    }
    else {
        csvDataString = @"0,0,0,0,0,0,0,0,0,0,0,0,0,0,,";        
        NSLog(@"csvDataString = %@", csvDataString);
    }
    return csvDataString;   */                      
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

- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
