//
//  MatchDetailViewController.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MatchDetailViewController.h"
#import "MatchData.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "DataManager.h"

@implementation MatchDetailViewController
@synthesize match;
@synthesize textChangeDetected;
@synthesize numberLabel;
@synthesize roundType;
@synthesize red1TextField, red2TextField, red3TextField;
@synthesize blue1TextField, blue2TextField, blue3TextField;
@synthesize managedObjectContext, fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated
{/*
    self.title = [NSString stringWithFormat:@"%@ %@ %@", match.tournament, @"Match", match.number];
    numberLabel.text = [NSString stringWithFormat:@"Match %d", [match.number intValue]];
    roundType.text = match.matchType;
    red1TextField.text = [NSString stringWithFormat:@"%d", [match.red1.teamInfo.number intValue]];
    red2TextField.text = [NSString stringWithFormat:@"%d", [match.red2.teamInfo.number intValue]];
    red3TextField.text = [NSString stringWithFormat:@"%d", [match.red3.teamInfo.number intValue]];
    blue1TextField.text = [NSString stringWithFormat:@"%d", [match.blue1.teamInfo.number intValue]];
    blue2TextField.text = [NSString stringWithFormat:@"%d", [match.blue2.teamInfo.number intValue]];
    blue3TextField.text = [NSString stringWithFormat:@"%d", [match.blue3.teamInfo.number intValue]];
    textChangeDetected = NO;*/
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    numberLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    roundType.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    red1TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    red2TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    red3TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    blue1TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    blue2TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    blue3TextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    [red1TextField addTarget:self action:@selector(textFieldDidChange:) 
            forControlEvents:UIControlEventEditingChanged];
    [red2TextField addTarget:self action:@selector(textFieldDidChange:) 
            forControlEvents:UIControlEventEditingChanged];
    [red3TextField addTarget:self action:@selector(textFieldDidChange:) 
            forControlEvents:UIControlEventEditingChanged];
    [blue1TextField addTarget:self action:@selector(textFieldDidChange:) 
             forControlEvents:UIControlEventEditingChanged];
    [blue2TextField addTarget:self action:@selector(textFieldDidChange:) 
             forControlEvents:UIControlEventEditingChanged];
    [blue3TextField addTarget:self action:@selector(textFieldDidChange:) 
             forControlEvents:UIControlEventEditingChanged];

    if (!managedObjectContext) {
        DataManager *dataManager = [DataManager new];
        managedObjectContext = [dataManager managedObjectContext];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear");
}    

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Text Fields

-(void)textFieldDidChange:(UITextField *)textField {
    // whatever you wanted to do
    NSLog(@"DidChange");
    textChangeDetected = YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    ///////////////////////////////////////////////
    ///  Add stuff to change team number for unsaved round
    if (!textChangeDetected) return YES;
    NSLog(@"EndEditing");
    int teamNumber = [textField.text intValue];
    /*
	if (textField == red1TextField) {
        if (!match.red1) [match setRed1:[self EditTeam:teamNumber]];
            if (teamNumber == 118) {
                NSLog(@"Adding New Match = %@", match.red1);
            }
	}
	else if (textField == red2TextField) {
        if (!match.red2) [match setRed2:[self EditTeam:teamNumber]];
	}
	else if (textField == red3TextField) {
        if (!match.red3) [match setRed3:[self EditTeam:teamNumber]];
	}
	else if (textField == blue1TextField) {
        if (!match.blue1) [match setBlue1:[self EditTeam:teamNumber]];
	}
	else if (textField == blue2TextField) {
        if (!match.blue2) [match setBlue2:[self EditTeam:teamNumber]];
	}
	else if (textField == blue3TextField) {
        if (!match.blue3) [match setBlue3:[self EditTeam:teamNumber]];
	}
    textChangeDetected = NO; */
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"ShouldReturn");
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSLog(@"shouldChange");
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    
    NSInteger holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    
    return [scan scanInteger: &holder] && [scan isAtEnd];
}

-(TeamScore *)EditTeam:(int)teamNumber {
    NSLog(@"EditTeam");
    NSLog(@"Team Number = %d", teamNumber);
    // Get team data object for team number
    TeamData *team = [self GetTeam:teamNumber];
    NSLog(@"Team data = %@", team);
    // check score to see if it is allocated
    TeamScore *currentScore = [NSEntityDescription insertNewObjectForEntityForName:@"TeamScore" 
                                                            inManagedObjectContext:managedObjectContext];
/*
    currentScore.driverRating = [NSNumber numberWithInt:0];
    currentScore.saved = [NSNumber numberWithInt:0];
    currentScore.startingPosition = [NSNumber numberWithInt:0];
    currentScore.notes = @"";
    [currentScore setTeleOpScore:[self CreateGameData]];
    [currentScore setAutonScore:[self CreateGameData]];
    [currentScore setEndGameScore:[self CreateEndGameData]];
    [currentScore setTeamInfo:team]; // Set Relationship!!! */
    return currentScore;
}
/*
-(SpecificGameData *)CreateGameData {
    SpecificGameData *gameScore = [NSEntityDescription insertNewObjectForEntityForName:@"SpecificGameData" 
                                                                inManagedObjectContext:managedObjectContext];
    gameScore.lowBaskets = [NSNumber numberWithInt:0];
    gameScore.midBaskets = [NSNumber numberWithInt:0];
    gameScore.highBaskets = [NSNumber numberWithInt:0];
    gameScore.missedBaskets = [NSNumber numberWithInt:0];
    gameScore.crossesHump = [NSNumber numberWithInt:0];
    
    return gameScore;
}

-(EndGameData *)CreateEndGameData {
    EndGameData *endScore = [NSEntityDescription insertNewObjectForEntityForName:@"EndGameData" 
                                                          inManagedObjectContext:managedObjectContext];
    endScore.balanced = [NSNumber numberWithInt:0];
    endScore.coopRamp = [NSNumber numberWithInt:0];
    endScore.modedRamp = [NSNumber numberWithInt:0];
    
    return endScore;
}
*/
-(TeamData *)GetTeam:(int)teamNumber {
    TeamData *team;
    NSError *error;
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"TeamData" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"number == %@", [NSNumber numberWithInt:teamNumber]];    
    [fetchRequest setPredicate:pred];    
    NSArray *teamData = [context executeFetchRequest:fetchRequest error:&error];
    //   NSLog(@"Matchin team? = %@", teamData);
    if(!teamData) {
        NSLog(@"Karma disruption error");
    } 
    else {
        if([teamData count] > 0) {  // Team Exists
            team = [teamData objectAtIndex:0];
            NSLog(@"Team %@ exists", team.number);
        }
        else { // Create New Team
            ///////////////////////////////////////////
            // Ask for confirmation
            team = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData" 
                                                 inManagedObjectContext:context];
            team.number = [NSNumber numberWithInt:teamNumber];
            team.name = @"";
            team.notes = @"";
            NSLog(@"Create New Team %@", team.number);
        }
    }
    return team;
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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

@end
