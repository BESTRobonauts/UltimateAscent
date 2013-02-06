//
//  MainScoutingPageViewController.m
//  ReboundRumble
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
@synthesize dataChange;
@synthesize delegate;
@synthesize storePath;
@synthesize fileManager;
// Match Control Buttons 
@synthesize prevMatch;
@synthesize nextMatch;

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
@synthesize fieldDrawingChange;// Team Picker
@synthesize scoreList;
@synthesize scorePicker;
@synthesize scorePickerPopover;


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
    
    [self SetButtonDefaults:prevMatch];
    [self SetButtonDefaults:nextMatch];
    [self SetTextBoxDefaults:matchNumber];
    [self SetButtonDefaults:matchType];
    [self SetTextBoxDefaults:teamName];
    [self SetButtonDefaults:teamNumber];
    [self SetButtonDefaults:teleOpMissButton];
    [self SetButtonDefaults:teleOpHighButton];
    [self SetButtonDefaults:teleOpMediumButton];
    [self SetButtonDefaults:teleOpLowButton];
    [self SetButtonDefaults:autonMissButton];
    [self SetButtonDefaults:autonHighButton];
    [self SetButtonDefaults:autonMediumButton];
    [self SetButtonDefaults:autonLowButton];
    [self SetTextBoxDefaults:redScore];
    [self SetTextBoxDefaults:blueScore];

    driverRating.maximumValue = 5.0;
    driverRating.continuous = NO;

    NSMutableArray *itemArray = [NSMutableArray arrayWithObjects: @"None", @"One", @"Two", @"Three", nil];
    balanced = [[UISegmentedControl alloc] initWithItems:itemArray];
    balanced.frame = CGRectMake(816, 575, 207, 44);
    [balanced addTarget:self action:@selector(setBalanceSegment:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:balanced];
    
    [self SetTextBoxDefaults:notes];

    [self SetButtonDefaults:alliance];
    allianceList = [[NSMutableArray alloc] initWithObjects:@"Red 1", @"Red 2", @"Red 3", @"Blue 1", @"Blue 2", @"Blue 3", nil];
    matchTypeList = [[NSMutableArray alloc] initWithObjects:@"Practice", @"Seeding", @"Elimination", @"Other", @"Testing", nil];
    scoreList = [[NSMutableArray alloc] initWithObjects:@"High", @"Missed", @"Medium", @"Low", nil];

    [self SetButtonDefaults:teamEdit];
    [teamEdit setTitle:@"Edit Team Info" forState:UIControlStateNormal];


    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
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
    NSLog(@"Match = %@, Type = %@, Tournament = %@", currentMatch.number, currentMatch.matchType, currentMatch.tournament);
    NSLog(@"Settings = %@", settings.tournament.name);
    [self setTeamList];
    baseDrawingPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/FieldDrawings/"];
    // NSLog(@"Field Drawing Path = %@", baseDrawingPath);
    dataChange = NO;
    fieldDrawingChange = NO;
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
/*        if (!currentTeam.fieldDrawing) {
            currentTeam.fieldDrawing = fieldDrawingFile;
            // Set the data change flag force the save of the fieldDrawing file name
            dataChange = YES;
        }
        path = [fieldDrawingPath stringByAppendingPathComponent:currentTeam.fieldDrawing];
        [UIImagePNGRepresentation(fieldImage.image) writeToFile:path atomically:YES];
        // NSLog(@"Drawing path = %@", fieldDrawingFile);
        fieldDrawingChange = NO;*/
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
    NSLog(@"Auton Low");
    int score = [autonLowButton.titleLabel.text intValue];
    score++;
    currentTeam.autonLow = [NSNumber numberWithInt:score];
    [autonLowButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonLow intValue]] forState:UIControlStateNormal];
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
    NSSortDescriptor *allianceDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score.alliance" ascending:YES];
    if (teamList == nil) {
        self.teamList = [NSMutableArray array];
//        [teamList addObject:[NSString stringWithFormat:@"%d", [currentMatch.red1.teamInfo.number intValue]]];
//        [teamList addObject:[NSString stringWithFormat:@"%d", [currentMatch.red2.teamInfo.number intValue]]];
//        [teamList addObject:[NSString stringWithFormat:@"%d", [currentMatch.red3.teamInfo.number intValue]]];
//        [teamList addObject:[NSString stringWithFormat:@"%d", [currentMatch.blue1.teamInfo.number intValue]]];
//        [teamList addObject:[NSString stringWithFormat:@"%d", [currentMatch.blue2.teamInfo.number intValue]]];
//        [teamList addObject:[NSString stringWithFormat:@"%d", [currentMatch.blue3.teamInfo.number intValue]]];
    }
    else {
//        [teamList replaceObjectAtIndex:0
//                            withObject:[NSString stringWithFormat:@"%d", [currentMatch.red1.teamInfo.number intValue]]];
//        [teamList replaceObjectAtIndex:1
//                            withObject:[NSString stringWithFormat:@"%d", [currentMatch.red2.teamInfo.number intValue]]];
//        [teamList replaceObjectAtIndex:2
//                            withObject:[NSString stringWithFormat:@"%d", [currentMatch.red3.teamInfo.number intValue]]];
//        [teamList replaceObjectAtIndex:3
//                            withObject:[NSString stringWithFormat:@"%d", [currentMatch.blue1.teamInfo.number intValue]]];
//        [teamList replaceObjectAtIndex:4
//                            withObject:[NSString stringWithFormat:@"%d", [currentMatch.blue2.teamInfo.number intValue]]];
//        [teamList replaceObjectAtIndex:5
//                            withObject:[NSString stringWithFormat:@"%d", [currentMatch.blue3.teamInfo.number intValue]]];
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
/*
    // NSLog(@"Load the Picture");
    fieldDrawingPath = [baseDrawingPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", [currentTeam.teamInfo.number intValue]]];
    
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
            [fieldImage setImage:[UIImage imageNamed:@"ReboundRumbleField.png"]];
            NSLog(@"Error reading field drawing file %@", fieldDrawingFile);
        }
    }
    else {
        // NSLog(@"Field Drawing= %@", currentTeam.fieldDrawing);
        [fieldImage setImage:[UIImage imageNamed:@"ReboundRumbleField.png"]];
        NSString *match;
        if ([currentMatch.number intValue] < 10) {
            match = [NSString stringWithFormat:@"M%c%@", [currentMatch.matchType characterAtIndex:0], [NSString stringWithFormat:@"00%d", [currentMatch.number intValue]]];
        } else if ( [currentMatch.number intValue] < 100) {
            match = [NSString stringWithFormat:@"M%c%@", [currentMatch.matchType characterAtIndex:0], [NSString stringWithFormat:@"0%d", [currentMatch.number intValue]]];
        } else {
            match = [NSString stringWithFormat:@"M%c%@", [currentMatch.matchType characterAtIndex:0], [NSString stringWithFormat:@"%d", [currentMatch.number intValue]]];
        }
        NSString *team;
        if ([currentTeam.teamInfo.number intValue] < 100) {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"00%d", [currentTeam.teamInfo.number intValue]]];
        } else if ( [currentTeam.teamInfo.number intValue] < 1000) {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"0%d", [currentTeam.teamInfo.number intValue]]];
        } else {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"%d", [currentTeam.teamInfo.number intValue]]];
        }
        fieldDrawingFile = [NSString stringWithFormat:@"%@_%@.png", match, team];
        [fieldImage setImage:[UIImage imageNamed:@"ReboundRumbleField.png"]];
    } */
}

-(TeamScore *)GetTeam:(NSUInteger)currentTeamIndex {
    switch (currentTeamIndex) {/*
        case 0: return currentMatch.red1;
        case 1: return currentMatch.red2;
        case 2: return currentMatch.red3;
        case 3: return currentMatch.blue1;
        case 4: return currentMatch.blue2;
        case 5: return currentMatch.blue3;*/
    }    
    return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // NSLog(@"touchesBegan");
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:imageContainer];
    if ([touch view] != fieldImage) {
        // NSLog(@"touchesBegan not imageView");
        return;
    }
    fieldDrawingChange = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    NSLog(@"touchesMoved");
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    if ([touch view] != fieldImage) {
        // NSLog(@"touchesMoved not imageView");
        return;
    }
    
    CGPoint currentPoint = [touch locationInView: imageContainer];
    UIGraphicsBeginImageContext(imageContainer.frame.size);
    [self.fieldImage.image drawInRect:CGRectMake(0, 0, imageContainer.frame.size.width, imageContainer.frame.size.height)];
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
    if ([touch view] != fieldImage) {
        // NSLog(@"touchesEnded not imageView");
        return;
    }
    if(!mouseSwiped) {
        if (scorePicker == nil) {
            self.scorePicker = [[RecordScorePickerController alloc]
                                   initWithStyle:UITableViewStylePlain];
            scorePicker.delegate = self;
            scorePicker.scoreChoices = scoreList;
            self.scorePickerPopover = [[UIPopoverController alloc]
                                       initWithContentViewController:scorePicker];
        }
        [self.scorePickerPopover presentPopoverFromRect:CGRectMake(lastPoint.x-50, lastPoint.y, 1.0, 1.0) inView:imageContainer permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        UIGraphicsBeginImageContext(imageContainer.frame.size);
        [self.fieldImage.image drawInRect:CGRectMake(0, 0, imageContainer.frame.size.width, imageContainer.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.fieldImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    //    UIGraphicsBeginImageContext(self.fieldImage.frame.size);
    //    [self.fieldImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    //    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    //   self.fieldImage.image = UIGraphicsGetImageFromCurrentImageContext();
    //    self.tempDrawImage.image = nil;
    //    UIGraphicsEndImageContext();
}

- (void)scoreSelected:(NSString *)newScore {
    [self.scorePickerPopover dismissPopoverAnimated:YES];
    
    for (int i = 0 ; i < [scoreList count] ; i++) {
        if ([newScore isEqualToString:[scoreList objectAtIndex:i]]) {
            NSLog(@"score selection = %@", [scoreList objectAtIndex:i]);
            break;
        }
    }
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
{
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            return NO;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return YES;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return YES;
            break;
            case UIInterfaceOrientationPortraitUpsideDown:
            return NO;
            break;
            
        default:
            break;
    }
}

-(void)SetTextBoxDefaults:(UITextField *)currentTextField {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
}

-(void)SetButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
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
