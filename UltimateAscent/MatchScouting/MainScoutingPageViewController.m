//
//  MainScoutingPageViewController.m
//  UltimateAscent
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainScoutingPageViewController.h"
#import "TeamDetailViewController.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "TeamData.h"
#import "TournamentData.h"
#import "SettingsData.h"
#import "DataManager.h"
#import "MatchTypeDictionary.h"
#import "parseCSV.h"

@implementation MainScoutingPageViewController {
    MatchTypeDictionary *matchDictionary;
    int numberMatchTypes;
    NSTimer *climbTimer;
    int timerCount;
}

@synthesize managedObjectContext, fetchedResultsController;
// Data Markers
@synthesize currentSectionType;
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
@synthesize defenseRating;
@synthesize climbLevel;
@synthesize attemptedClimb;
@synthesize climbTimerButton;
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
@synthesize wallPickUpsButton;
@synthesize wall1Button;
@synthesize wall2Button;
@synthesize wall3Button;
@synthesize wall4Button;
@synthesize floorPickUpsButton;
@synthesize matchResetButton;

// Other Stuff
@synthesize redScore;
@synthesize blueScore;
@synthesize teamEdit;
@synthesize matchListButton;
@synthesize syncButton;

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
@synthesize currentPoint;
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

    // Set the list of match types
    matchDictionary = [[MatchTypeDictionary alloc] init];    
    matchTypeList = [self getMatchTypeList];
    numberMatchTypes = [matchTypeList count];
    // NSLog(@"Match Type List Count = %@", matchTypeList);

    // If there are no matches in any section then don't set this stuff. ShowMatch will set currentMatch to
    // nil, printing out blank info in all the display items.
    if (numberMatchTypes) {
        // Temporary method to save the data markers
        storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"dataMarker.csv"];
        fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:storePath]) {
            // Loading Default Data Markers
            currentSectionType = [[matchDictionary getMatchTypeEnum:[matchTypeList objectAtIndex:0]] intValue];
            rowIndex = 0;
            sectionIndex = [self getMatchSectionInfo:currentSectionType];
            teamIndex = 0;
        }
        else {
            CSVParser *parser = [CSVParser new];
            [parser openFile: storePath];
            NSMutableArray *csvContent = [parser parseFile];
            // NSLog(@"data marker = %@", csvContent);
            rowIndex = [[[csvContent objectAtIndex:0] objectAtIndex:0] intValue];
            teamIndex = [[[csvContent objectAtIndex:0] objectAtIndex:2] intValue];
            currentSectionType = [[[csvContent objectAtIndex:0] objectAtIndex:1] intValue];
            sectionIndex = [self getMatchSectionInfo:currentSectionType];
            if (sectionIndex == -1) { // The selected match type does not exist
                // Go back to the first section in the table
                currentSectionType = [[matchDictionary getMatchTypeEnum:[matchTypeList objectAtIndex:0]] intValue];
                sectionIndex = [self getMatchSectionInfo:currentSectionType];
            }
        }
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
    [self SetBigButtonDefaults:wallPickUpsButton];
    [self SetSmallButtonDefaults:wall1Button];
    [self SetSmallButtonDefaults:wall2Button];
    [self SetSmallButtonDefaults:wall3Button];
    [self SetSmallButtonDefaults:wall4Button];
    [self SetBigButtonDefaults:floorPickUpsButton];
    [self SetTextBoxDefaults:redScore];
    [self SetTextBoxDefaults:blueScore];
    [self SetBigButtonDefaults:climbTimerButton];
    matchResetButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [self SetBigButtonDefaults:teamEdit];
    [teamEdit setTitle:@"Edit Team Info" forState:UIControlStateNormal];
    [self SetBigButtonDefaults:syncButton];
    [syncButton setTitle:@"Sync" forState:UIControlStateNormal];
    [self SetBigButtonDefaults:matchListButton];
    [matchListButton setTitle:@"Show Match List" forState:UIControlStateNormal];

    driverRating.maximumValue = 5.0;
    driverRating.continuous = NO;
    defenseRating.maximumValue = 5.0;
    defenseRating.continuous = NO;

    NSMutableArray *itemArray = [NSMutableArray arrayWithObjects: @"None", @"One", @"Two", @"Three", nil];
    climbLevel = [[UISegmentedControl alloc] initWithItems:itemArray];
    climbLevel.frame = CGRectMake(738, 600, 207, 44);
    [climbLevel addTarget:self action:@selector(setClimbSegment:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:climbLevel];
    
    [self SetTextBoxDefaults:notes];

    [self SetBigButtonDefaults:alliance];
    allianceList = [[NSMutableArray alloc] initWithObjects:@"Red 1", @"Red 2", @"Red 3", @"Blue 1", @"Blue 2", @"Blue 3", nil];

    // Drawing Stuff
    scoreList = [[NSMutableArray alloc] initWithObjects:@"Medium", @"High", @"Missed", @"Low", @"Pyramid", nil];
    defenseList = [[NSMutableArray alloc] initWithObjects:@"Passed", @"Blocked", nil];
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(floorDiskPickUp:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [fieldImage addGestureRecognizer:doubleTapGestureRecognizer];
    
    UITapGestureRecognizer *tapPressGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scoreDisk:)];
    tapPressGesture.numberOfTapsRequired = 1;
    [tapPressGesture requireGestureRecognizerToFail: doubleTapGestureRecognizer];
    [fieldImage addGestureRecognizer:tapPressGesture];
    
    UIPanGestureRecognizer *drawGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawPath:)];
    [fieldImage addGestureRecognizer:drawGesture];


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
    
    currentMatch = [self getCurrentMatch];
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
    dataMarkerString = [NSString stringWithFormat:@"%d, %d, %d\n", rowIndex, currentSectionType, teamIndex];
    [dataMarkerString writeToFile:storePath 
                       atomically:YES 
                         encoding:NSUTF8StringEncoding 
                            error:nil];
   [self CheckDataStatus];
    //    [delegate scoutingPageStatus:sectionIndex forRow:rowIndex forTeam:teamIndex];
}

-(NSMutableArray *)getMatchTypeList {
    NSMutableArray *matchTypes = [NSMutableArray array];
    NSString *sectionName;
    for (int i=0; i < [[fetchedResultsController sections] count]; i++) {
        sectionName = [[[fetchedResultsController sections] objectAtIndex:i] name];
        // NSLog(@"Section = %@", sectionName);
        NSString *str = [matchDictionary getMatchTypeString:[NSNumber numberWithInt:[sectionName intValue]]];
        // NSLog(@"Match Type = %@", str);
        [matchTypes addObject:[matchDictionary getMatchTypeString:[NSNumber numberWithInt:[sectionName intValue]]]];
    }
    return matchTypes;
}

-(NSUInteger)getMatchSectionInfo:(MatchType)matchSection {
    NSString *sectionName;
    sectionIndex = -1;
    // Loop for number of sections in table
    for (int i=0; i < [[fetchedResultsController sections] count]; i++) {
        sectionName = [[[fetchedResultsController sections] objectAtIndex:i] name];
        if ([sectionName intValue] == matchSection) {
            sectionIndex = i;
            break;
        }
    }
    return sectionIndex;
}
-(int)getNumberOfMatches:(NSUInteger)section {
    if ([[fetchedResultsController sections] count]) {
        return [[[[fetchedResultsController sections] objectAtIndex:sectionIndex] objects] count];
    }
    else return 0;
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
        sectionIndex = [self GetPreviousSection:currentSectionType];
        rowIndex =  [self getNumberOfMatches:sectionIndex]-1;
    }
    
    currentMatch = [self getCurrentMatch];
    [self setTeamList];
    [self ShowTeam:teamIndex];
}

-(IBAction)NextButton {
    [self CheckDataStatus];
    int nrows;
    nrows =  [self getNumberOfMatches:sectionIndex];
    if (rowIndex < (nrows-1)) rowIndex++;
    else { 
        rowIndex = 0; 
        sectionIndex = [self GetNextSection:currentSectionType];
    }
    currentMatch = [self getCurrentMatch];
    
    [self setTeamList];
    [self ShowTeam:teamIndex];
}

// Move through the rounds
-(NSUInteger)GetNextSection:(MatchType) currentSection {
    //    NSLog(@"GetNextSection");
    NSUInteger nextSection;
    switch (currentSection) {
        case Practice:
            currentSectionType = Seeding;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no seeding matches
                nextSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Seeding:
            currentSectionType = Elimination;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no Elimination matches
                nextSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Elimination:
            currentSectionType = Practice;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no Practice matches
                // Try seeding matches instead
                currentSectionType = Seeding;
                nextSection = [self getMatchSectionInfo:currentSectionType];
                if (nextSection == -1) { // There are no seeding matches either
                    nextSection = [self getMatchSectionInfo:currentSection];
                    currentSectionType = currentSection;
                }
            }
            break;
        case Other:
            currentSectionType = Testing;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no Test matches
                nextSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Testing:
            currentSectionType = Other;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no Other matches
                nextSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
    }
    return nextSection;
}

-(NSUInteger)GetPreviousSection:(NSUInteger) currentSection {
    //    NSLog(@"GetPreviousSection");
    NSUInteger newSection;
    switch (currentSection) {
        case Practice:
            currentSectionType = Testing;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Test matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Seeding:
            currentSectionType = Practice;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Practice matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Elimination:
            currentSectionType = Seeding;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Seeding matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Other:
            currentSectionType = Testing;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Test matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Testing:
            currentSectionType = Other;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Other matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
    }
    return newSection;
}

-(IBAction)AllianceSelectionChanged:(id)sender {
    //    NSLog(@"AllianceSelectionChanged");
    if ([settings.mode isEqualToString:@"Test"]) {
        [self AllianceSelectionPopUp];
    }
    else {
        overrideMode = OverrideAllianceSelection;
        [self checkAdminCode:alliance];
    }
}

-(void)AllianceSelectionPopUp {
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
            currentSectionType = [[matchDictionary getMatchTypeEnum:newMatchType] intValue];
            sectionIndex = [self getMatchSectionInfo:currentSectionType];
            break;
        }
    }
    rowIndex = 0;
    currentMatch = [self getCurrentMatch];
    [self setTeamList];
    [self ShowTeam:teamIndex];
}

-(IBAction)TeamSelectionChanged:(id)sender {
    //    NSLog(@"TeamSelectionChanged");
    if ([settings.mode isEqualToString:@"Test"]) {
        [self TeamSelectionPopUp];
    }
    else {
        overrideMode = OverrideTeamSelection;
        [self checkAdminCode:teamNumber];
    }
}

-(void)TeamSelectionPopUp {
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
    currentMatch = [self getCurrentMatch];
    
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

- (IBAction) updateDefenseRating:(id) sender
{
    defenseRating.value = roundf(defenseRating.value);
    dataChange = YES;
    currentTeam.defenseRating = [NSNumber numberWithInt:defenseRating.value];
}

-(IBAction)toggleForClimbAttempt: (id) sender {
    [UIView beginAnimations:nil context:NULL];  
    [UIView setAnimationDuration: 0.3];  
    dataChange = YES;
    if ([attemptedClimb isOn]) {
        currentTeam.climbAttempt = [NSNumber numberWithInt:1];
    }
    else {
        currentTeam.climbAttempt = [NSNumber numberWithInt:0];
    }
    [UIView commitAnimations];  
    
}

- (void) setClimbSegment:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    dataChange = YES;
    currentTeam.climbLevel = [NSNumber numberWithInt:segmentedControl.selectedSegmentIndex];
    if (segmentedControl.selectedSegmentIndex) {
        currentTeam.climbAttempt = [NSNumber numberWithInt:1];
        [attemptedClimb setOn:YES animated:YES];
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
    // Update the number of shots taken
    int total = [currentTeam.totalTeleOpShots intValue];
    total++;
    currentTeam.totalTeleOpShots = [NSNumber numberWithInt:total];
    
    // Update the number of missed shots
    int score = [teleOpMissButton.titleLabel.text intValue];
    score++;
    currentTeam.teleOpMissed = [NSNumber numberWithInt:score];
    [teleOpMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpMissed intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)teleOpHigh {
    // Update the number of shots taken
    int total = [currentTeam.totalTeleOpShots intValue];
    total++;
    currentTeam.totalTeleOpShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentTeam.teleOpShots intValue];
    total++;
    currentTeam.teleOpShots = [NSNumber numberWithInt:total];
    
    // Update the number of high shots
    int score = [teleOpHighButton.titleLabel.text intValue];
    score++;
    currentTeam.teleOpHigh = [NSNumber numberWithInt:score];
    [teleOpHighButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpHigh intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)teleOpMedium {
    // Update the number of shots taken
    int total = [currentTeam.totalTeleOpShots intValue];
    total++;
    currentTeam.totalTeleOpShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentTeam.teleOpShots intValue];
    total++;
    currentTeam.teleOpShots = [NSNumber numberWithInt:total];
    
    // Update the number of medium shots
    int score = [teleOpMediumButton.titleLabel.text intValue];
    score++;
    currentTeam.teleOpMid = [NSNumber numberWithInt:score];
    [teleOpMediumButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpMid intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)teleOpLow {
    // Update the number of shots taken
    int total = [currentTeam.totalTeleOpShots intValue];
    total++;
    currentTeam.totalTeleOpShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentTeam.teleOpShots intValue];
    total++;
    currentTeam.teleOpShots = [NSNumber numberWithInt:total];
    
    // Update the number of high shots
    int score = [teleOpLowButton.titleLabel.text intValue];
    score++;
    currentTeam.teleOpLow = [NSNumber numberWithInt:score];
    [teleOpLowButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.teleOpLow intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)autonMiss {
    // Update the number of shots taken
    int total = [currentTeam.totalAutonShots intValue];
    total++;
    currentTeam.totalAutonShots = [NSNumber numberWithInt:total];

    // Update the number of missed shots 
    int score = [autonMissButton.titleLabel.text intValue];
    score++;
    currentTeam.autonMissed = [NSNumber numberWithInt:score];
    [autonMissButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonMissed intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)autonHigh {
    // Update the number of shots taken
    int total = [currentTeam.totalAutonShots intValue];
    total++;
    currentTeam.totalAutonShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentTeam.autonShotsMade intValue];
    total++;
    currentTeam.autonShotsMade = [NSNumber numberWithInt:total];

    // Update the number of high shots
    int score = [autonHighButton.titleLabel.text intValue];
    score++;
    currentTeam.autonHigh = [NSNumber numberWithInt:score];
    [autonHighButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonHigh intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)autonMedium {
    // Update the number of shots taken
    int total = [currentTeam.totalAutonShots intValue];
    total++;
    currentTeam.totalAutonShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentTeam.autonShotsMade intValue];
    total++;
    currentTeam.autonShotsMade = [NSNumber numberWithInt:total];
    
    // Update the number of medium shots
    int score = [autonMediumButton.titleLabel.text intValue];
    score++;
    currentTeam.autonMid = [NSNumber numberWithInt:score];
    [autonMediumButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.autonMid intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(void)autonLow {
    // Update the number of shots taken
    int total = [currentTeam.totalAutonShots intValue];
    total++;
    currentTeam.totalAutonShots = [NSNumber numberWithInt:total];
    
    // Update the number of shots made
    total = [currentTeam.autonShotsMade intValue];
    total++;
    currentTeam.autonShotsMade = [NSNumber numberWithInt:total];
    
    // Update the number of Low shots
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

-(IBAction)wallPickUpsMade:(id) sender {
    UIButton * PressedButton = (UIButton*)sender;
   // NSLog(@"PickUps");
    if (drawMode == DrawAuton || drawMode == DrawDefense || drawMode == DrawTeleop) {
        int score = [wallPickUpsButton.titleLabel.text intValue];
        score++;
        currentTeam.wallPickUp = [NSNumber numberWithInt:score];
        [wallPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp intValue]] forState:UIControlStateNormal];
        dataChange = YES;
        if (PressedButton == wall1Button) {
            score = [wall1Button.titleLabel.text intValue];
            score++;
            currentTeam.wallPickUp1 = [NSNumber numberWithInt:score];
            [wall1Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp1 intValue]] forState:UIControlStateNormal];
        } else if (PressedButton == wall2Button) {
            score = [wall2Button.titleLabel.text intValue];
            score++;
            currentTeam.wallPickUp2 = [NSNumber numberWithInt:score];
            [wall2Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp2 intValue]] forState:UIControlStateNormal];
        } else if (PressedButton == wall3Button) {
            score = [wall3Button.titleLabel.text intValue];
            score++;
            currentTeam.wallPickUp3 = [NSNumber numberWithInt:score];
            [wall3Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp3 intValue]] forState:UIControlStateNormal];
        } else if (PressedButton == wall4Button) {
            score = [wall4Button.titleLabel.text intValue];
            score++;
            currentTeam.wallPickUp4 = [NSNumber numberWithInt:score];
            [wall4Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp4 intValue]] forState:UIControlStateNormal];
        }
    }
}

-(void)floorPickUpsMade {
    // NSLog(@"PickUps");
    int score = [floorPickUpsButton.titleLabel.text intValue];
    score++;
    currentTeam.floorPickUp = [NSNumber numberWithInt:score];
    [floorPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.floorPickUp intValue]] forState:UIControlStateNormal];
    dataChange = YES;
}

-(IBAction)climbTimerStart:(id)sender {
    if (drawMode == DrawAuton || drawMode == DrawDefense || drawMode == DrawTeleop) {
        dataChange = YES;
        NSLog(@"Start Timer");
        if (climbTimer == nil) {
            climbTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                        selector:@selector(timerFired)
                                                        userInfo:nil
                                                        repeats:YES];
        }
        timerCount = 0;
    }
}

-(IBAction)climbTimerStop:(id)sender {
    if (drawMode == DrawAuton || drawMode == DrawDefense || drawMode == DrawTeleop) {
        NSLog(@"Stop Timer %d", timerCount);
        int newTimer = [currentTeam.climbTimer intValue] + timerCount;
        currentTeam.climbTimer = [NSNumber numberWithInt:newTimer];
        [climbTimerButton setTitle:[NSString stringWithFormat:@"%02d:%02d", newTimer/60, newTimer%60] forState:UIControlStateNormal];
    }
}

- (void)timerFired {
    timerCount++;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIButton *button = (UIButton *)sender;

    [self CheckDataStatus];
    
    if (button == teamEdit) {
        TeamDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.team = currentTeam.team;
    }
 /*   else {
        MatchDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.match = currentMatch;               
    }*/
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

-(MatchData *)getCurrentMatch {
    if (numberMatchTypes == 0) {
        return nil;
    }
    else {
        NSIndexPath *matchIndex = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
        return [fetchedResultsController objectAtIndexPath:matchIndex];
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
    defenseRating.value =  [currentTeam.defenseRating floatValue];
    if ([currentTeam.climbAttempt intValue] == 0) [attemptedClimb setOn:NO animated:YES];
    else [attemptedClimb setOn:YES animated:YES];

    
    double seconds = fmod([currentTeam.climbTimer floatValue], 60.0);
    double minutes = fmod(trunc([currentTeam.climbTimer floatValue] / 60.0), 60.0);
    [climbTimerButton setTitle:[NSString stringWithFormat:@"%02.0f:%02.0f", minutes, seconds] forState:UIControlStateNormal];

    
    climbLevel.selectedSegmentIndex = [currentTeam.climbLevel intValue];

    notes.text = currentTeam.notes;
    [alliance setTitle:[allianceList objectAtIndex:currentTeamIndex] forState:UIControlStateNormal];
    
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
    [wallPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp intValue]] forState:UIControlStateNormal];
    [wall1Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp1 intValue]] forState:UIControlStateNormal];
    [wall2Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp2 intValue]] forState:UIControlStateNormal];
    [wall3Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp3 intValue]] forState:UIControlStateNormal];
    [wall4Button setTitle:[NSString stringWithFormat:@"%d", [currentTeam.wallPickUp4 intValue]] forState:UIControlStateNormal];
    [floorPickUpsButton setTitle:[NSString stringWithFormat:@"%d", [currentTeam.floorPickUp intValue]] forState:UIControlStateNormal];

    // NSLog(@"Load the Picture");
    fieldDrawingPath = [baseDrawingPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", [currentTeam.team.number intValue]]];
    
    // Check the database to see if this team and match have a drawing already
    if (currentTeam.fieldDrawing && ![currentTeam.fieldDrawing isEqualToString:@""]) {
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

-(void)floorDiskPickUp:(UITapGestureRecognizer *)gestureRecognizer {
    fieldDrawingChange = YES;
    // NSLog(@"floorDiskPickUp");
    NSString *marker = @"O";
    currentPoint = [gestureRecognizer locationInView:fieldImage];
    [self drawText:marker location:currentPoint];
    [self floorPickUpsMade];
}

-(void)scoreDisk:(UITapGestureRecognizer *)gestureRecognizer {
    fieldDrawingChange = YES;
    currentPoint = [gestureRecognizer locationInView:fieldImage];
    // NSLog(@"scoreDisk point = %f %f", currentPoint.x, currentPoint.y);
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
        CGPoint popPoint = [self defensePopOverLocation:currentPoint];
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
        CGPoint popPoint = [self scorePopOverLocation:currentPoint];
        [self.scorePickerPopover presentPopoverFromRect:CGRectMake(popPoint.x, popPoint.y, 1.0, 1.0) inView:fieldImage permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
}

-(void)drawPath:(UIPanGestureRecognizer *)gestureRecognizer {
    fieldDrawingChange = YES;
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // NSLog(@"drawPath Began");
        lastPoint = [gestureRecognizer locationInView:fieldImage];
    }
    else {
        currentPoint = [gestureRecognizer locationInView: fieldImage];
        // NSLog(@"current point = %lf, %lf", currentPoint.x, currentPoint.y);
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
        // NSLog(@"On the left edge");
        popPoint.x = -22;
    }
    else if (location.x < 750) {
        // NSLog(@"In the middle");
        popPoint.x = location.x-55;
    } else {
        // NSLog(@"On the right edge");
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
            drawMode = DrawTeleop;
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
    textPoint.x = currentPoint.x;
    textPoint.y = currentPoint.y + popCounter*16;
    // NSLog(@"Text Point = %f %f", textPoint.x, textPoint.y);
    popCounter++;
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
    [self drawText:marker location:textPoint];
}

- (void)defenseSelected:(NSString *)newDefense {
//    [self.defensePickerPopover dismissPopoverAnimated:YES];
    NSString *marker;
    CGPoint textPoint;
    textPoint.x = currentPoint.x;
    textPoint.y = currentPoint.y + popCounter*16;
    popCounter++;
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
    [self drawText:marker location:textPoint];
 }

-(void)drawText:(NSString *) marker location:(CGPoint) point {
    UIGraphicsBeginImageContext(fieldImage.frame.size);
    [self.fieldImage.image drawInRect:CGRectMake(0, 0, fieldImage.frame.size.width, fieldImage.frame.size.height)];
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(myContext, kCGLineCapRound);
    CGContextSetLineWidth(myContext, 1);
    CGContextSetRGBStrokeColor(myContext, red, green, blue, opacity);
    CGContextSelectFont (myContext,
                         "Helvetica",
                         16,
                         kCGEncodingMacRoman);
    CGContextSetCharacterSpacing (myContext, 1);
    CGContextSetTextDrawingMode (myContext, kCGTextFillStroke);
    CGContextSetTextMatrix(myContext, CGAffineTransformMake(1.0,0.0, 0.0, -1.0, 0.0, 0.0));
    
    CGContextShowTextAtPoint (myContext, point.x, point.y, [marker UTF8String], marker.length);
    CGContextFlush(UIGraphicsGetCurrentContext());
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.fieldImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

-(void)checkOverrideCode:(UIButton *)button {
    // NSLog(@"Check override");
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

-(void)checkAdminCode:(UIButton *)button {
    // NSLog(@"Check override");
    if (alertPrompt == nil) {
        self.alertPrompt = [[AlertPromptViewController alloc] initWithNibName:nil bundle:nil];
        alertPrompt.delegate = self;
        alertPrompt.titleText = @"Enter Admin Code";
        alertPrompt.msgText = @"Danielle will kill you.";
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

        case OverrideAllianceSelection:
            if ([passCodeAttempt isEqualToString:settings.adminCode]) {
                [self AllianceSelectionPopUp];
            }
            break;

        case OverrideTeamSelection:
            if ([passCodeAttempt isEqualToString:settings.adminCode]) {
                [self TeamSelectionPopUp];
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
    currentTeam.autonShotsMade = [NSNumber numberWithInt:0];
    currentTeam.totalAutonShots = [NSNumber numberWithInt:0];
    currentTeam.teleOpHigh = [NSNumber numberWithInt:0];
    currentTeam.teleOpMid = [NSNumber numberWithInt:0];
    currentTeam.teleOpLow = [NSNumber numberWithInt:0];
    currentTeam.teleOpMissed = [NSNumber numberWithInt:0];
    currentTeam.teleOpShots = [NSNumber numberWithInt:0];
    currentTeam.totalTeleOpShots = [NSNumber numberWithInt:0];
    currentTeam.pyramid = [NSNumber numberWithInt:0];
    currentTeam.passes = [NSNumber numberWithInt:0];
    currentTeam.blocks = [NSNumber numberWithInt:0];
    currentTeam.wallPickUp = [NSNumber numberWithInt:0];
    currentTeam.wallPickUp1 = [NSNumber numberWithInt:0];
    currentTeam.wallPickUp2 = [NSNumber numberWithInt:0];
    currentTeam.wallPickUp3 = [NSNumber numberWithInt:0];
    currentTeam.wallPickUp4 = [NSNumber numberWithInt:0];
    currentTeam.floorPickUp = [NSNumber numberWithInt:0];
    currentTeam.driverRating = [NSNumber numberWithInt:0];
    currentTeam.notes = @"";
    currentTeam.saved = [NSNumber numberWithInt:0];
    currentTeam.fieldDrawing = nil;
    currentTeam.defenseRating = [NSNumber numberWithInt:0];
    currentTeam.climbLevel = [NSNumber numberWithInt:0];
    currentTeam.climbAttempt = [NSNumber numberWithInt:0];
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
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchTypeSection" ascending:YES];
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
         sectionNameKeyPath:@"matchTypeSection"
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
