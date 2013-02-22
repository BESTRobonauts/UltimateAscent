//
//  MainScoutingPageViewController.m
//  UltimateAscent
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainScoutingPageViewController.h"
#import "MatchDetailViewController.h"
#import "TeamDetailViewController.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "TeamData.h"
#import "TournamentData.h"
#import "SettingsData.h"
#import "DataManager.h"
#import "parseCSV.h"

@implementation MainScoutingPageViewController
@synthesize managedObjectContext, fetchedResultsController;
// Data Markers
@synthesize rowIndex;
@synthesize sectionIndex;
@synthesize teamIndex;
@synthesize settings;
@synthesize currentMatch;
@synthesize currentTeam;
@synthesize teamData;
@synthesize dataChange;
@synthesize delegate;
@synthesize storePath;
@synthesize fileManager;

// Match Control Buttons
@synthesize prevMatch;
@synthesize nextMatch;

// User Access Control
@synthesize overrideMode;
@synthesize alertPrompt;
@synthesize alertPromptPopover;

// Alliance Picker
@synthesize alliance;
@synthesize allianceList;
@synthesize alliancePicker;
@synthesize alliancePickerPopover;

// Team Picker
@synthesize teamNumber;
@synthesize teamList;
@synthesize teamPicker;
@synthesize teamPickerPopover;

// Match Data
@synthesize matchNumber;
@synthesize matchType;
@synthesize matchTypeList;
@synthesize matchTypePicker;
@synthesize matchTypePickerPopover;

// Match Score
@synthesize teamName;
@synthesize driverRating;
@synthesize crossesHump;
@synthesize coopBalance;
@synthesize balanced;
@synthesize modedRamp;
@synthesize notes;
@synthesize teleOpMissButton;
@synthesize teleOpHighButton;
@synthesize teleOpMediumButton;
@synthesize teleOpLowButton;
@synthesize autonMissButton;
@synthesize autonHighButton;
@synthesize autonMediumButton;
@synthesize autonLowButton;
@synthesize pyramidGoalsButton;
@synthesize blocksButton;
@synthesize passesButton;
@synthesize pickupsButton;
@synthesize matchResetButton;

// Other Stuff
@synthesize redScore;
@synthesize blueScore;
@synthesize teamEdit;

// Field Drawing
@synthesize imageContainer;
@synthesize fieldImage;
@synthesize fieldDrawingPath;
@synthesize baseDrawingPath;
@synthesize fieldDrawingFile;
@synthesize fieldDrawingChange;
@synthesize scoreList;
@synthesize scorePicker;
@synthesize scorePickerPopover;
@synthesize defenseList;
@synthesize defensePicker;
@synthesize defensePickerPopover;
@synthesize popCounter;
@synthesize drawMode;
@synthesize drawModeButton;

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
    [super viewDidLoad];
    NSLog(@"Main Scouting viewDidLoad");
    NSError *error = nil;
    if (!managedObjectContext) {
        DataManager *dataManager = [DataManager new];
        managedObjectContext = [dataManager managedObjectContext];
    }
    [self retrieveSettings];
    if (settings) {
        self.title = settings.tournament.name;
    }
    else {
        self.title = @"Match Scouting";
    }
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         abort() causes the application to generate a crash log and terminate. 
         You should not use this function in a shipping application, 
         although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }		

    // Temporary method to save the data markers
    storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"dataMarker.csv"];
    fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:storePath]) {
        // Loading Default Data Markers
        rowIndex = 0;
        sectionIndex = 2;
        teamIndex = 0;
    }
    else {
        CSVParser *parser = [CSVParser new];
        [parser openFile: storePath];
        NSMutableArray *csvContent = [parser parseFile];
        rowIndex = [[[csvContent objectAtIndex:0] objectAtIndex:0] intValue];
        sectionIndex = [[[csvContent objectAtIndex:0] objectAtIndex:1] intValue];
        teamIndex = [[[csvContent objectAtIndex:0] objectAtIndex:2] intValue];
    }
    
    overrideMode = NoOverride;
    teamName.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    [self SetBigButtonDefaults:prevMatch];
    [self SetBigButtonDefaults:nextMatch];
    [self SetTextBoxDefaults:matchNumber];
    [self SetBigButtonDefaults:matchType];
    [self SetBigButtonDefaults:teamNumber];
    [self SetBigButtonDefaults:teleOpMissButton];
    [self SetBigButtonDefaults:teleOpHighButton];
    [self SetBigButtonDefaults:teleOpMediumButton];
    [self SetBigButtonDefaults:teleOpLowButton];
    [self SetBigButtonDefaults:autonMissButton];
    [self SetBigButtonDefaults:autonHighButton];
    [self SetBigButtonDefaults:autonMediumButton];
    [self SetBigButtonDefaults:autonLowButton];
    [self SetBigButtonDefaults:pyramidGoalsButton];
    [self SetBigButtonDefaults:passesButton];
    [self SetBigButtonDefaults:blocksButton];
    [self SetBigButtonDefaults:pickupsButton];
    [self SetTextBoxDefaults:redScore];
    [self SetTextBoxDefaults:blueScore];
    matchResetButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];

    driverRating.maximumValue = 5.0;
    driverRating.continuous = NO;

    NSMutableArray *itemArray = [NSMutableArray arrayWithObjects: @"None", @"One", @"Two", @"Three", nil];
    balanced = [[UISegmentedControl alloc] initWithItems:itemArray];
    balanced.frame = CGRectMake(738, 600, 207, 44);
    [balanced addTarget:self action:@selector(setBalanceSegment:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:balanced];
    
    [self SetTextBoxDefaults:notes];

    [self SetBigButtonDefaults:alliance];
    allianceList = [[NSMutableArray alloc] initWithObjects:@"Red 1", @"Red 2", @"Red 3", @"Blue 1", @"Blue 2", @"Blue 3", nil];
    matchTypeList = [[NSMutableArray alloc] initWithObjects:@"Practice", @"Seeding", @"Elimination", @"Other", @"Testing", nil];
    scoreList = [[NSMutableArray alloc] initWithObjects:@"Medium", @"High", @"Missed", @"Low", @"Pyramid", nil];
    defenseList = [[NSMutableArray alloc] initWithObjects:@"Passed", @"Blocked", nil];

    [self SetBigButtonDefaults:teamEdit];
    [teamEdit setTitle:@"Edit Team Info" forState:UIControlStateNormal];

    brush = 3.0;
    opacity = 1.0;
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    //    NSLog(@"viewWillAppear");
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
    
    NSIndexPath *matchIndex = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    currentMatch = [fetchedResultsController objectAtIndexPath:matchIndex];
    // NSLog(@"Match = %@, Type = %@, Tournament = %@", currentMatch.number, currentMatch.matchType, currentMatch.tournament);
    // NSLog(@"Settings = %@", settings.tournament.name);
    baseDrawingPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/FieldDrawings/%@", settings.tournament.directory]];
    // NSLog(@"Field Drawing Path = %@", baseDrawingPath);
    dataChange = NO;
    fieldDrawingChange = NO;
    [self setTeamList];
    [self ShowTeam:teamIndex];
}    

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillDisappear:(BOOL)animated
{
//    NSLog(@"viewWillDisappear");
    NSString *dataMarkerString;
    storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"dataMarker.csv"];
    dataMarkerString = [NSString stringWithFormat:@"%d, %d, %d\n", rowIndex, sectionIndex, teamIndex];
    [dataMarkerString writeToFile:storePath 
                       atomically:YES 
                         encoding:NSUTF8StringEncoding 
                            error:nil];
   [self CheckDataStatus];
    //    [delegate scoutingPageStatus:sectionIndex forRow:rowIndex forTeam:teamIndex];
}    

-(void)CheckDataStatus {
    //    NSLog(@"Check to Save");
    //    NSLog (@"Data changed: %@", dataChange ? @"YES" : @"NO");
    if (fieldDrawingChange) {
        // Save the picture
        // Check if robot directory exists, if not, create it
        if (![[NSFileManager defaultManager] fileExistsAtPath:fieldDrawingPath isDirectory:NO]) {
            if (![[NSFileManager defaultManager]createDirectoryAtPath:fieldDrawingPath
                                          withIntermediateDirectories: YES
                                                           attributes: nil
                                                                error: NULL]) {
                NSLog(@"Dreadful error creating directory to save field drawings");
                return;
            }
        }
        NSString *path;
        if (!currentTeam.fieldDrawing) {
            currentTeam.fieldDrawing = fieldDrawingFile;
            // Set the data change flag to force the save of the fieldDrawing file name
            dataChange = YES;
        }
        path = [fieldDrawingPath stringByAppendingPathComponent:currentTeam.fieldDrawing];
        [UIImagePNGRepresentation(fieldImage.image) writeToFile:path atomically:YES];
        // NSLog(@"Drawing path = %@", fieldDrawingFile);
        fieldDrawingChange = NO;
    }
    if (dataChange) {
        currentTeam.saved = [NSNumber numberWithInt:1];
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        dataChange = NO;
    }
}

-(IBAction)PrevButton {
    [self CheckDataStatus];
    if (rowIndex > 0) rowIndex--;
    else {
        sectionIndex = [self GetPreviousSection:sectionIndex];
        rowIndex =  [[[[fetchedResultsController sections] objectAtIndex:sectionIndex] objects] count]-1;
    }
    
    NSIndexPath *matchIndex = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    currentMatch = [fetchedResultsController objectAtIndexPath:matchIndex];
    
    [self setTeamList];
    [self ShowTeam:teamIndex];
}

-(IBAction)NextButton {
    [self CheckDataStatus];
    int nrows;
    nrows =  [[[[fetchedResultsController sections] objectAtIndex:sectionIndex] objects] count];
    if (rowIndex < (nrows-1)) rowIndex++;
    else { 
        rowIndex = 0; 
        sectionIndex = [self GetNextSection:sectionIndex];
    }
    NSIndexPath *matchIndex = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    currentMatch = [fetchedResultsController objectAtIndexPath:matchIndex];
    
    [self setTeamList];
    [self ShowTeam:teamIndex];
}

-(NSUInteger)GetNextSection:(NSUInteger) currentSection {
    //    NSLog(@"GetNextSection");
    switch (currentSection) {
        case 0: currentSection=1; // Elimination to Other
            break;
        case 1: currentSection=4; // Other to Testing
            break;
        case 2: currentSection=3; // Practice to Seeding
            break;
        case 3: currentSection=0; // Seeding to Elimination
            break;
        case 4: currentSection=2; // Testing to Practice
            break;
    }
    return currentSection;
}

// Move through the rounds
-(NSUInteger)GetPreviousSection:(NSUInteger) currentSection {
    //    NSLog(@"GetPreviousSection");
    switch (currentSection) {
        case 0: currentSection=3;  // Elimination to Seeding
            break;
        case 1: currentSection=0;  // Other to Elimination
            break;
        case 2: currentSection=4;  // Practice to Testing
            break;
        case 3: currentSection=2;  // Seeding to Practice
            break;
        case 4: currentSection=1;  // Testing to Other
            break;
    }
    return currentSection;
}

-(IBAction)AllianceSelectionChanged:(id)sender {
    //    NSLog(@"AllianceSelectionChanged");
    [self CheckDataStatus];
    if (alliancePicker == nil) {
        self.alliancePicker = [[AlliancePickerController alloc] 
                               initWithStyle:UITableViewStylePlain];
        alliancePicker.delegate = self;
        alliancePicker.allianceChoices = allianceList;
        self.alliancePickerPopover = [[UIPopoverController alloc] 
                                      initWithContentViewController:alliancePicker];               
    }
    [self.alliancePickerPopover presentPopoverFromRect:alliance.bounds inView:alliance 
                              permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)allianceSelected:(NSString *)newAlliance {
    [self CheckDataStatus];
    [self.alliancePickerPopover dismissPopoverAnimated:YES];    
    for (int i = 0 ; i < [allianceList count] ; i++) {
        if ([newAlliance isEqualToString:[allianceList objectAtIndex:i]]) {
            teamIndex = i;
            [alliance setTitle:newAlliance forState:UIControlStateNormal];
            [self ShowTeam:teamIndex];
            break;
        }
    }
}

-(IBAction)MatchTypeSelectionChanged:(id)sender {
    //    NSLog(@"matchTypeSelectionChanged");
    [self CheckDataStatus];
    if (matchTypePicker == nil) {
        self.matchTypePicker = [[MatchTypePickerController alloc] 
                                initWithStyle:UITableViewStylePlain];
        matchTypePicker.delegate = self;
        matchTypePicker.matchTypeChoices = matchTypeList;
        self.matchTypePickerPopover = [[UIPopoverController alloc] 
                                       initWithContentViewController:matchTypePicker];               
    }
    [self.matchTypePickerPopover presentPopoverFromRect:matchType.bounds inView:matchType 
                               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)matchTypeSelected:(NSString *)newMatchType {
    [self.matchTypePickerPopover dismissPopoverAnimated:YES];
    [self CheckDataStatus];
    
    for (int i = 0 ; i < [matchTypeList count] ; i++) {
        if ([newMatchType isEqualToString:[matchTypeList objectAtIndex:i]]) {
            switch (i) {
                case 0:
                    sectionIndex = 2;
                    break;
                case 1:
                    sectionIndex = 3;
                    break;
                case 2:
                    sectionIndex = 0;
                    break;
                case 3:
                    sectionIndex = 1;
                    break;
                case 4:
                    sectionIndex = 4;
                    break;
            }
            break;
        }
    }
    rowIndex = 0;
    NSIndexPath *matchIndex = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    currentMatch = [fetchedResultsController objectAtIndexPath:matchIndex];
    [self setTeamList];
    [self ShowTeam:teamIndex];
}

-(IBAction)TeamSelectionChanged:(id)sender {
    //    NSLog(@"TeamSelectionChanged");
    
    [self CheckDataStatus];
    if (teamPicker == nil) {
        self.teamPicker = [[TeamPickerController alloc] 
                           initWithStyle:UITableViewStylePlain];
        teamPicker.delegate = self;
        teamPicker.teamList = teamList;
        self.teamPickerPopover = [[UIPopoverController alloc] 
                                  initWithContentViewController:teamPicker];               
    }
    teamPicker.teamList = teamList;
    [self.teamPickerPopover presentPopoverFromRect:teamNumber.bounds inView:teamNumber 
                          permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

- (void)teamSelected:(NSString *)newTeam {
    [self CheckDataStatus];
    [self.teamPickerPopover dismissPopoverAnimated:YES];
    
    for (int i = 0 ; i < [teamList count] ; i++) {
        if ([newTeam isEqualToString:[teamList objectAtIndex:i]]) {
            teamIndex = i;
            [teamNumber setTitle:newTeam forState:UIControlStateNormal];
            [self ShowTeam:teamIndex];
            break;
        }
    }
}

-(IBAction)MatchNumberChanged {
    // NSLog(@"MatchNumberChanged");
    [self CheckDataStatus];
    
    int matchField = [matchNumber.text intValue];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = 
    [[fetchedResultsController sections] objectAtIndex:sectionIndex];
    int nmatches = [sectionInfo numberOfObjects];
    if (matchField > nmatches) { /* Ooops, not that many matches */
        // For now, just change the match field to the last match in the section
        matchField = nmatches;
    }
    rowIndex = matchField-1;
    NSIndexPath *matchIndex = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    currentMatch = [fetchedResultsController objectAtIndexPath:matchIndex];
        
    [self setTeamList];
    [self ShowTeam:teamIndex];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField != matchNumber && textField != redScore && textField != blueScore)  return YES;
    
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    
    NSInteger holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    
    return [scan scanInteger: &holder] && [scan isAtEnd];
}

#pragma mark -
#pragma mark Text

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    dataChange = YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    NSLog(@"should end editing");
    if (textField == notes) {
		currentTeam.notes = notes.text;
	}
    else if (textField == redScore) {
        currentMatch.redScore = [NSNumber numberWithInt:[redScore.text intValue]];     
    }
    else if (textField == blueScore) {
        currentMatch.blueScore = [NSNumber numberWithInt:[blueScore.text intValue]];     
    }
	return YES;
}

- (IBAction) updateDriverRating:(id) sender  
{
    driverRating.value = roundf(driverRating.value);
    dataChange = YES;
    currentTeam.DriverRating = [NSNumber numberWithInt:driverRating.value];
}

-(IBAction)toggleForCrossesHump: (id) sender {
    [UIView beginAnimations:nil context:NULL];  
    [UIView setAnimationDuration: 0.3];  
    dataChange = YES;
    if ([crossesHump isOn]) {
//        currentTeam.teleOpScore.crossesHump = [NSNumber numberWithInt:1];
    }
    else {
//        currentTeam.teleOpScore.crossesHump = [NSNumber numberWithInt:0];
    }  
    
    [UIView commitAnimations];  
    
}

-(IBAction)toggleForCoopBalance: (id) sender {
    [UIView beginAnimations:nil context:NULL];  
    [UIView setAnimationDuration: 0.3];  
    dataChange = YES;
    if ([coopBalance isOn]) {
//        currentTeam.endGameScore.coopRamp = [NSNumber numberWithInt:1];
    }
    else {
//        currentTeam.endGameScore.coopRamp = [NSNumber numberWithInt:0];
    }  
    
    [UIView commitAnimations];  
}

-(IBAction)toggleForRampModing:(id) sender {
    [UIView beginAnimations:nil context:NULL];  
    [UIView setAnimationDuration: 0.3];  
    dataChange = YES;
    if ([modedRamp isOn]) {
//        currentTeam.endGameScore.modedRamp = [NSNumber numberWithInt:1];
    }
    else {
//        currentTeam.endGameScore.modedRamp = [NSNumber numberWithInt:0];
    }  
    
    [UIView commitAnimations];      
}

- (void) setBalanceSegment:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    dataChange = YES;
//    currentTeam.endGameScore.balanced = [NSNumber numberWithInt:segmentedControl.selectedSegmentIndex];
    if (segmentedControl.selectedSegmentIndex) {
//        currentTeam.endGameScore.coopRamp = [NSNumber numberWithInt:1];
        [coopBalance setOn:YES animated:YES];
    }
}

// Keeping the score
- (IBAction)scoreButtons:(id)sender {    
    UIButton * PressedButton = (UIButton*)sender;
    
    if (PressedButton == teleOpMissButton) {
        [self teleOpMiss];
    } else if (PressedButton == teleOpHighButton) {
        [self teleOpHigh];
    } else if (PressedButton == teleOpMediumButton) {
        [self teleOpMedium];
    } else if (PressedButton == teleOpLowButton) {
        [self teleOpLow];
    } else if (PressedButton == autonMissButton) {
        [self autonMiss];
    } else if (PressedButton == autonHighButton) {
        [self autonHigh];
    } else if (PressedButton == autonMediumButton) {
        [self autonMedium];
    } else if (PressedButton == autonLowButton) {
        [self autonLow];
    }
}

-(void)teleOpMiss {
    int score = [teleOpMissButton.titleLabel.text intValue];
    score++;
    currentTeam.teleOpMissed = [NSNumber numberWithInt:score];
    [teleOpMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpMissed intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)teleOpHigh {
    int score = [teleOpHighButton.titleLabel.text intValue];
    score++;
    currentTeam.teleOpHigh = [NSNumber numberWithInt:score];
    [teleOpHighButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpHigh intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)teleOpMedium {
    int score = [teleOpMediumButton.titleLabel.text intValue];
    score++;
    currentTeam.teleOpMid = [NSNumber numberWithInt:score];
    [teleOpMediumButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpMid intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)teleOpLow {
    int score = [teleOpLowButton.titleLabel.text intValue];
    score++;
    currentTeam.teleOpLow = [NSNumber numberWithInt:score];
    [teleOpLowButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpLow intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)autonMiss {
    int score = [autonMissButton.titleLabel.text intValue];
    score++;
    currentTeam.autonMissed = [NSNumber numberWithInt:score];
    [autonMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonMissed intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)autonHigh {
    int score = [autonHighButton.titleLabel.text intValue];
    score++;
    currentTeam.autonHigh = [NSNumber numberWithInt:score];
    [autonHighButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonHigh intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)autonMedium {
    int score = [autonMediumButton.titleLabel.text intValue];
    score++;
    currentTeam.autonMid = [NSNumber numberWithInt:score];
    [autonMediumButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonMid intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)autonLow {
    // NSLog(@"Auton Low");
    int score = [autonLowButton.titleLabel.text intValue];
    score++;
    currentTeam.autonLow = [NSNumber numberWithInt:score];
    [autonLowButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonLow intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)pyramidGoals {
    // NSLog(@"Pyramid Goals");
    int score = [pyramidGoalsButton.titleLabel.text intValue];
    score++;
    currentTeam.pyramid = [NSNumber numberWithInt:score];
    [pyramidGoalsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.pyramid intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)passesMade {
    // NSLog(@"Passes Made");
    int score = [passesButton.titleLabel.text intValue];
    score++;
    currentTeam.passes = [NSNumber numberWithInt:score];
    [passesButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.passes intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)blockedShots {
    // NSLog(@"Blocked Shots");
    int score = [blocksButton.titleLabel.text intValue];
    score++;
    currentTeam.blocks = [NSNumber numberWithInt:score];
    [blocksButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.blocks intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIButton *button = (UIButton *)sender;

    [self CheckDataStatus];
    
    if (button == teamEdit) {
        TeamDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.team = currentTeam.team;
    }
    else {
        MatchDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.match = currentMatch;               
    }
}

-(void)setTeamList {
    TeamScore *score;
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"alliance" ascending:YES];
    teamData = [[currentMatch.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];

    if (teamList == nil) {
        self.teamList = [NSMutableArray array];
        // Reds
        for (int i = 3; i < 6; i++) {
            score = [teamData objectAtIndex:i];
            [teamList addObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
        // Blues
        for (int i = 0; i < 3; i++) {
            score = [teamData objectAtIndex:i];
            [teamList addObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }

    }
    else {
        // Reds
        for (int i = 3; i < 6; i++) {
            score = [teamData objectAtIndex:i];
            [teamList replaceObjectAtIndex:(i-3)
                           withObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
        // Blues
       for (int i = 0; i < 3; i++) {
            score = [teamData objectAtIndex:i];
            [teamList replaceObjectAtIndex:(i+3)
                            withObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
       }
    }
}

-(void)ShowTeam:(NSUInteger)currentTeamIndex {
    currentTeam = [self GetTeam:currentTeamIndex];

    [matchType setTitle:currentMatch.matchType forState:UIControlStateNormal];
    matchNumber.text = [NSString stringWithFormat:@"%d", [currentMatch.number intValue]];
    if ([currentMatch.redScore intValue] == -1) {
        redScore.text = @"";
    }
    else {
        redScore.text = [NSString stringWithFormat:@"%d", [currentMatch.redScore intValue]];
    }
    if ([currentMatch.blueScore intValue] == -1) {
        blueScore.text = @"";
    }
    else {
        blueScore.text = [NSString stringWithFormat:@"%d", [currentMatch.blueScore intValue]];
    }
    
   [teamNumber setTitle:[NSString stringWithFormat:@"%d", [currentTeam.team.number intValue]] forState:UIControlStateNormal];
    teamName.text = currentTeam.team.name;
    driverRating.value =  [currentTeam.driverRating floatValue];
//    if ([currentTeam.teleOpScore.crossesHump intValue] == 0) [crossesHump setOn:NO animated:YES];
//    else [crossesHump setOn:YES animated:YES];
    
//    if ([currentTeam.endGameScore.coopRamp intValue] == 0) [coopBalance setOn:NO animated:YES];
//    else [coopBalance setOn:YES animated:YES];
//    balanced.selectedSegmentIndex = [currentTeam.endGameScore.balanced intValue];
/*
    if ([currentTeam.endGameScore.modedRamp intValue] == 0) [modedRamp setOn:NO animated:YES];
    else [modedRamp setOn:YES animated:YES];
*/
    notes.text = currentTeam.notes;
    [alliance setTitle:[allianceList objectAtIndex:currentTeamIndex] forState:UIControlStateNormal];

//    startingPosition.text =  [NSString stringWithFormat:@"%d", [currentTeam.startingPosition intValue]];
    
    [teleOpMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpMissed intValue]] forState:UIControlStateNormal];
    [teleOpHighButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpHigh intValue]] forState:UIControlStateNormal];
    [teleOpMediumButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpMid intValue]] forState:UIControlStateNormal];
    [teleOpLowButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpLow intValue]] forState:UIControlStateNormal];
    [autonMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonMissed intValue]] forState:UIControlStateNormal];
    [autonHighButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonHigh intValue]] forState:UIControlStateNormal];
    [autonMediumButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonMid intValue]] forState:UIControlStateNormal];
    [autonLowButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonLow intValue]] forState:UIControlStateNormal];
    [pyramidGoalsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.pyramid intValue]] forState:UIControlStateNormal];
    [blocksButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.blocks intValue]] forState:UIControlStateNormal];
    [passesButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.passes intValue]] forState:UIControlStateNormal];
    [pickupsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.pickups intValue]] forState:UIControlStateNormal];

    // NSLog(@"Load the Picture");
    fieldDrawingPath = [baseDrawingPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", [currentTeam.team.number intValue]]];
    
    // Check the database to see if this team and match have a drawing already
    if (currentTeam.fieldDrawing) {
        // Load file, set file name to the name read, and load it as image
        // NSLog(@"Field Drawing= %@", currentTeam.fieldDrawing);
        fieldDrawingFile = currentTeam.fieldDrawing;
        NSString *path = [fieldDrawingPath stringByAppendingPathComponent:currentTeam.fieldDrawing];
        // NSLog(@"Full path = %@", path);
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [fieldImage setImage:[UIImage imageWithContentsOfFile:path]];
        }
        else {
            [fieldImage setImage:[UIImage imageNamed:@"2013_field.png"]];
            NSLog(@"Error reading field drawing file %@", fieldDrawingFile);
        }
        drawMode = DrawLock;
    }
    else {
        // NSLog(@"Field Drawing= %@", currentTeam.fieldDrawing);
        [fieldImage setImage:[UIImage imageNamed:@"2013_field.png"]];
        NSString *match;
        if ([currentMatch.number intValue] < 10) {
            match = [NSString stringWithFormat:@"M%c%@", [currentMatch.matchType characterAtIndex:0], [NSString stringWithFormat:@"00%d", [currentMatch.number intValue]]];
        } else if ( [currentMatch.number intValue] < 100) {
            match = [NSString stringWithFormat:@"M%c%@", [currentMatch.matchType characterAtIndex:0], [NSString stringWithFormat:@"0%d", [currentMatch.number intValue]]];
        } else {
            match = [NSString stringWithFormat:@"M%c%@", [currentMatch.matchType characterAtIndex:0], [NSString stringWithFormat:@"%d", [currentMatch.number intValue]]];
        }
        NSString *team;
        if ([currentTeam.team.number intValue] < 100) {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"00%d", [currentTeam.team.number intValue]]];
        } else if ( [currentTeam.team.number intValue] < 1000) {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"0%d", [currentTeam.team.number intValue]]];
        } else {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"%d", [currentTeam.team.number intValue]]];
        }
        // Since no field drawing exists, we guess that the user wants to start in auton mode
        drawMode = DrawOff;
        fieldDrawingFile = [NSString stringWithFormat:@"%@_%@.png", match, team];
        [fieldImage setImage:[UIImage imageNamed:@"2013_field.png"]];
    }
    [self drawModeSettings:drawMode];
}

-(TeamScore *)GetTeam:(NSUInteger)currentTeamIndex {
    switch (currentTeamIndex) {
        case 0: return [teamData objectAtIndex:3];  // Red 1
        case 1: return [teamData objectAtIndex:4];  // Red 2
        case 2: return [teamData objectAtIndex:5];  // Red 3
        case 3: return [teamData objectAtIndex:0];  // Blue 1
        case 4: return [teamData objectAtIndex:1];  // Blue 2
        case 5: return [teamData objectAtIndex:2];  // Blue 3
    }    
    return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // NSLog(@"touchesBegan");
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:imageContainer];
    if ([touch view] != fieldImage) return;
    fieldDrawingChange = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    NSLog(@"touchesMoved");
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    if ([touch view] != fieldImage) return;
    
    CGPoint currentPoint = [touch locationInView: fieldImage];
    UIGraphicsBeginImageContext(fieldImage.frame.size);
    [self.fieldImage.image drawInRect:CGRectMake(0, 0, fieldImage.frame.size.width, fieldImage.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.fieldImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.fieldImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // NSLog(@"touchesEnded");
    UITouch *touch = [touches anyObject];
    if ([touch view] != fieldImage) return;
    if(!mouseSwiped) {
        popCounter = 0;
        if (drawMode == DrawDefense) {
            if (defensePicker == nil) {
                self.defensePicker = [[DefensePickerController alloc]
                                    initWithStyle:UITableViewStylePlain];
                defensePicker.delegate = self;
                defensePicker.defenseChoices = defenseList;
                self.defensePickerPopover = [[UIPopoverController alloc]
                                           initWithContentViewController:defensePicker];
            }
            CGPoint popPoint = [self defensePopOverLocation:lastPoint];
            [self.defensePickerPopover presentPopoverFromRect:CGRectMake(popPoint.x, popPoint.y, 1.0, 1.0) inView:fieldImage permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        }
        else {
            if (scorePicker == nil) {
                self.scorePicker = [[RecordScorePickerController alloc]
                                    initWithStyle:UITableViewStylePlain];
                scorePicker.delegate = self;
                scorePicker.scoreChoices = scoreList;
                self.scorePickerPopover = [[UIPopoverController alloc]
                                           initWithContentViewController:scorePicker];
            }
            CGPoint popPoint = [self scorePopOverLocation:lastPoint];
            [self.scorePickerPopover presentPopoverFromRect:CGRectMake(popPoint.x, popPoint.y, 1.0, 1.0) inView:fieldImage permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        }
    }
    
    //    UIGraphicsBeginImageContext(self.fieldImage.frame.size);
    //    [self.fieldImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    //    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    //   self.fieldImage.image = UIGraphicsGetImageFromCurrentImageContext();
    //    self.tempDrawImage.image = nil;
    //    UIGraphicsEndImageContext();
}

-(CGPoint)scorePopOverLocation:(CGPoint)location; {
    CGPoint popPoint;
    popPoint = location;
    if (location.x <= 98) {
        // NSLog(@"On the left edge");
        popPoint.x = -22;
    }
    else if (location.x < 740) {
        // NSLog(@"In the middle");
        popPoint.x = location.x-55;
    } else {
        // NSLog(@"On the right edge");
        popPoint.x = 705;
    }
    
    popPoint.y = location.y+10;
    
    return popPoint;
}

-(CGPoint)defensePopOverLocation:(CGPoint)location; {
    CGPoint popPoint;
    popPoint = location;
    if (location.x <= 98) {
        NSLog(@"On the left edge");
        popPoint.x = -22;
    }
    else if (location.x < 750) {
        NSLog(@"In the middle");
        popPoint.x = location.x-55;
    } else {
        NSLog(@"On the right edge");
        popPoint.x = 714;
    }
    
    popPoint.y = location.y+20;
    
    return popPoint;
}

-(IBAction)drawModeChange: (id)sender {
    switch (drawMode) {
        case DrawOff:
            drawMode = DrawAuton;
            break;
        case DrawAuton:
            drawMode = DrawTeleop;
            break;
        case DrawTeleop:
            drawMode = DrawDefense;
            break;
        case DrawDefense:
            drawMode = DrawOff;
            break;
        case DrawLock:
            overrideMode = OverrideDrawLock;
            [self checkOverrideCode:drawModeButton];
            break;
        default:
            NSLog(@"Bad things have happened in drawModeChange");
    }
    [self drawModeSettings:drawMode];
}

-(void) drawModeSettings:(DrawingMode) mode {
    switch (mode) {
        case DrawOff:
            [drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small White Button.jpg"] forState:UIControlStateNormal];
            [drawModeButton setTitle:@"Off" forState:UIControlStateNormal];
            [drawModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            fieldImage.userInteractionEnabled = FALSE;
            break;
        case DrawAuton:
            red = 255.0/255.0;
            green = 190.0/255.0;
            blue = 0.0/255.0;
            [drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small Green Button.jpg"] forState:UIControlStateNormal];
            [drawModeButton setTitle:@"Auton" forState:UIControlStateNormal];
            [drawModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            fieldImage.userInteractionEnabled = TRUE;
            break;
        case DrawTeleop:
            red = 0.0/255.0;
            green = 0.0/255.0;
            blue = 0.0/255.0;
            [drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small Blue Button.jpg"] forState:UIControlStateNormal];
            [drawModeButton setTitle:@"TeleOp" forState:UIControlStateNormal];
            [drawModeButton setTitleColor:[UIColor colorWithRed:255.0 green:190.0 blue:0 alpha:1.0] forState:UIControlStateNormal];
            fieldImage.userInteractionEnabled = TRUE;
            break;
        case DrawDefense:
            red = 255.0/255.0;
            green = 0.0/255.0;
            blue = 0.0/255.0;
            [drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small Grey Button.jpg"] forState:UIControlStateNormal];
            [drawModeButton setTitle:@"Defense" forState:UIControlStateNormal];
            [drawModeButton setTitleColor:[UIColor colorWithRed:255.0 green:190.0 blue:0 alpha:1.0] forState:UIControlStateNormal];
            fieldImage.userInteractionEnabled = TRUE;
            break;
        case DrawLock:
            [drawModeButton setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
            [drawModeButton setTitle:@"Locked" forState:UIControlStateNormal];
            [drawModeButton setTitleColor:[UIColor colorWithRed:255.0 green:190.0 blue:0 alpha:1.0] forState:UIControlStateNormal];
            fieldImage.userInteractionEnabled = FALSE;
            break;
        default:
            break;
    }
    
}

- (void)scoreSelected:(NSString *)newScore {
 //   [self.scorePickerPopover dismissPopoverAnimated:YES];
    NSString *marker;
    CGPoint textPoint;
    popCounter++;
    textPoint.x = lastPoint.x;
    textPoint.y = lastPoint.y + popCounter*12;
    for (int i = 0 ; i < [scoreList count] ; i++) {
        if ([newScore isEqualToString:[scoreList objectAtIndex:i]]) {
            switch (i) {
                case 0:
                    marker = @"M";
                    if (drawMode == DrawAuton) {
                        [self autonMedium];
                    }
                    else if (drawMode == DrawTeleop) {
                        [self teleOpMedium];
                    }
                    break;
                case 1:
                    marker = @"H";
                    if (drawMode == DrawAuton) {
                        [self autonHigh];
                    }
                    else if (drawMode == DrawTeleop) {
                        [self teleOpHigh];
                    }
                    break;
                case 2:
                    marker = @"X";
                    if (drawMode == DrawAuton) {
                        [self autonMiss];
                    }
                    else if (drawMode == DrawTeleop) {
                        [self teleOpMiss];
                    }
                    break;
                case 3:
                    marker = @"L";
                    if (drawMode == DrawAuton) {
                        [self autonLow];
                    }
                    else if (drawMode == DrawTeleop) {
                        [self teleOpLow];
                    }
                    break;
                case 4:
                    marker = @"G";
                    [self pyramidGoals];
                    break;
                default:
                    break;
            }
            
            // NSLog(@"score selection = %@", [scoreList objectAtIndex:i]);
            break;
        }
    }
    // NSLog(@"Marker = %@", marker);
    UIGraphicsBeginImageContext(fieldImage.frame.size);
    [self.fieldImage.image drawInRect:CGRectMake(0, 0, fieldImage.frame.size.width, fieldImage.frame.size.height)];
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(myContext, kCGLineCapRound);
    CGContextSetLineWidth(myContext, 1);
    CGContextSetRGBStrokeColor(myContext, red, green, blue, opacity);
    CGContextSelectFont (myContext,
                         "Helvetica",
                         14,
                         kCGEncodingMacRoman);
    CGContextSetCharacterSpacing (myContext, 1);
    CGContextSetTextDrawingMode (myContext, kCGTextFillStroke);
    CGContextSetTextMatrix(myContext, CGAffineTransformMake(1.0,0.0, 0.0, -1.0, 0.0, 0.0));

    CGContextShowTextAtPoint (myContext, textPoint.x, textPoint.y, [marker UTF8String], marker.length);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    CGContextFlush(UIGraphicsGetCurrentContext());
    self.fieldImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

}

- (void)defenseSelected:(NSString *)newDefense {
//    [self.defensePickerPopover dismissPopoverAnimated:YES];
    NSString *marker;
    CGPoint textPoint;
    popCounter++;
    textPoint.x = lastPoint.x;
    textPoint.y = lastPoint.y + popCounter*12;
    for (int i = 0 ; i < [defenseList count] ; i++) {
        if ([newDefense isEqualToString:[defenseList objectAtIndex:i]]) {
            switch (i) {
                case 0:
                    marker = @"P";
                    [self passesMade];
                    break;
                case 1:
                    marker = @"B";
                    [self blockedShots];
                    break;
                default:
                    break;
            }
            
            // NSLog(@"defense selection = %@", [defenseList objectAtIndex:i]);
            break;
        }
    }
    // NSLog(@"Marker = %@", marker);
    UIGraphicsBeginImageContext(fieldImage.frame.size);
    [self.fieldImage.image drawInRect:CGRectMake(0, 0, fieldImage.frame.size.width, fieldImage.frame.size.height)];
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(myContext, kCGLineCapRound);
    CGContextSetLineWidth(myContext, 1);
    CGContextSetRGBStrokeColor(myContext, red, green, blue, opacity);
    CGContextSelectFont (myContext,
                         "Helvetica",
                         14,
                         kCGEncodingMacRoman);
    CGContextSetCharacterSpacing (myContext, 1);
    CGContextSetTextDrawingMode (myContext, kCGTextFillStroke);
    CGContextSetTextMatrix(myContext, CGAffineTransformMake(1.0,0.0, 0.0, -1.0, 0.0, 0.0));
    
    CGContextShowTextAtPoint (myContext, textPoint.x, textPoint.y, [marker UTF8String], marker.length);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    CGContextFlush(UIGraphicsGetCurrentContext());
    self.fieldImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

-(void)checkOverrideCode:(UIButton *)button {
    NSLog(@"Check override");
    if (alertPrompt == nil) {
        self.alertPrompt = [[AlertPromptViewController alloc] initWithNibName:nil bundle:nil];
        alertPrompt.delegate = self;
        alertPrompt.titleText = @"Enter Override Code";
        alertPrompt.msgText = @"Please be sure you really want to do this.";
        self.alertPromptPopover = [[UIPopoverController alloc]
                                   initWithContentViewController:alertPrompt];
    }
    [self.alertPromptPopover presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
    return;
}

- (void)passCodeResult:(NSString *)passCodeAttempt {
    [self.alertPromptPopover dismissPopoverAnimated:YES];
    switch (overrideMode) {
        case OverrideDrawLock:
            if ([passCodeAttempt isEqualToString:settings.overrideCode]) {
                drawMode = DrawOff;
                [self drawModeSettings:drawMode];
            }
            break;
            
        case OverrideMatchReset:
            if ([passCodeAttempt isEqualToString:settings.overrideCode]) {
                [self matchReset];
            }
            break;
            
        default:
            break;
    }
    overrideMode = NoOverride;
}

-(IBAction)matchResetRequest:(id) sender {
    NSLog(@"matchReset");
    overrideMode = OverrideMatchReset;
    [self checkOverrideCode:matchResetButton];
    // Different message for saved, locked, synced
 }

-(void)matchReset {
    currentMatch.redScore = [NSNumber numberWithInt:-1];
    currentMatch.blueScore = [NSNumber numberWithInt:-1];
    currentTeam.autonHigh = [NSNumber numberWithInt:0];
    currentTeam.autonMid = [NSNumber numberWithInt:0];
    currentTeam.autonLow = [NSNumber numberWithInt:0];
    currentTeam.autonMissed = [NSNumber numberWithInt:0];
    currentTeam.teleOpHigh = [NSNumber numberWithInt:0];
    currentTeam.teleOpMid = [NSNumber numberWithInt:0];
    currentTeam.teleOpLow = [NSNumber numberWithInt:0];
    currentTeam.teleOpMissed = [NSNumber numberWithInt:0];
    currentTeam.pyramid = [NSNumber numberWithInt:0];
    currentTeam.passes = [NSNumber numberWithInt:0];
    currentTeam.blocks = [NSNumber numberWithInt:0];
    currentTeam.pickups = [NSNumber numberWithInt:0];
    currentTeam.driverRating = [NSNumber numberWithInt:0];
    currentTeam.notes = @"";
    currentTeam.saved = [NSNumber numberWithInt:0];
    currentTeam.fieldDrawing = nil;
    currentTeam.defenseRating = [NSNumber numberWithInt:0];
    currentTeam.climbLevel = [NSNumber numberWithInt:0];
    currentTeam.climbSuccess = [NSNumber numberWithInt:-1];
    currentTeam.climbTimer = [NSNumber numberWithFloat:0.0];
    
    [self ShowTeam:teamIndex];   
}


- (void)retrieveSettings {
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
{   return UIInterfaceOrientationIsLandscape(interfaceOrientation);
   }

-(void)SetTextBoxDefaults:(UITextField *)currentTextField {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
}

-(void)SetBigButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
}

-(void)SetSmallButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
}

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchData" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchType" ascending:YES];
        NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
        // Add the search for tournament name
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournament CONTAINS %@", settings.tournament.name];
        [fetchRequest setPredicate:pred];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = 
        [[NSFetchedResultsController alloc] 
         initWithFetchRequest:fetchRequest 
         managedObjectContext:managedObjectContext 
         sectionNameKeyPath:@"matchType" 
         cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
	
	return fetchedResultsController;
}    

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
