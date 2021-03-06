//
//  MasonPageViewController.m
//  UltimateAscent
//
//  Created by FRC on 3/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "MasonPageViewController.h"
#import "SettingsData.h"
#import "TournamentData.h"
#import "DataManager.h"
#import "MatchTypeDictionary.h"
#import "MatchData.h"
#import "TeamData.h"
#import "TeamDataInterfaces.h"
#import "TeamScore.h"
#import "Statistics.h"
#import "CalculateTeamStats.h"
#import "TeamDetailViewController.h"
#import "FieldDrawingViewController.h"
#import "parseCSV.h"
#import  "QuartzCore/QuartzCore.h"

@interface MasonPageViewController ()

@end

@implementation MasonPageViewController {
    int numberMatchTypes;
    CalculateTeamStats *teamStats;
    MatchTypeDictionary *matchDictionary;
    NSFileManager *fileManager;
    NSString *storePath;
}
@synthesize dataManager = _dataManager;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize settings = _settings;

// Match Control Buttons
@synthesize prevMatch;
@synthesize nextMatch;
@synthesize ourPrevMatch;
@synthesize ourNextMatch;

// Match Data
@synthesize matchNumber;
@synthesize matchType;
@synthesize matchTypeList;
@synthesize matchTypePicker;
@synthesize matchTypePickerPopover;

@synthesize teamData;
@synthesize teamList = _teamList;
@synthesize teamMatches = _teamMatches;
@synthesize teamAuton = _teamAuton;
@synthesize teamTeleOp = _teamTeleOp;
@synthesize teamHang = _teamHang;
@synthesize teamHangLevel = _teamHangLevel;
@synthesize teamDriving = _teamDriving;
@synthesize teamDefense = _teamDefense;
@synthesize teamSpeed = _teamSpeed;
@synthesize teamHeader = _teamHeader;
@synthesize teamInfo = _teamInfo;

// Team Match List
@synthesize red1Matches = _red1Matches;
@synthesize red1 = _red1;



// Team Tables
@synthesize red1Team = _red1Team;
@synthesize red1Stats = _red1Stats;
@synthesize red1Table = _red1Table;

@synthesize red2Team = _red2Team;
@synthesize red2Table = _red2Table;

@synthesize red3Team = _red3Team;
@synthesize red3Table = _red3Table;

@synthesize blue1Team = _blue1Team;
@synthesize blue1Table = _blue1Table;

@synthesize blue2Team = _blue2Team;
@synthesize blue2Table = _blue2Table;

@synthesize blue3Team = _blue3Team;
@synthesize blue3Table = _blue3Table;

// Team Score for Segue
@synthesize red1Scores = _red1Scores;
@synthesize red2Scores = _red2Scores;
@synthesize red3Scores = _red3Scores;
@synthesize blue1Scores = _blue1Scores;
@synthesize blue2Scores = _blue2Scores;
@synthesize blue3Scores = _blue3Scores;

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
    NSError *error = nil;
    if (!_managedObjectContext) {
        if (_dataManager) {
            _managedObjectContext = _dataManager.managedObjectContext;
        }
        else {
            _dataManager = [DataManager new];
            _managedObjectContext = [_dataManager managedObjectContext];
        }
    }
    [self retrieveSettings];
    if (_settings) {
        self.title =  [NSString stringWithFormat:@"%@ Match Analysis", _settings.tournament.name];
    }
    else {
        self.title = @"Match Analysis";
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
    teamStats = [[CalculateTeamStats alloc] initWithDataManager:_dataManager];
    matchDictionary = [[MatchTypeDictionary alloc] init];
    
    matchTypeList = [self getMatchTypeList];
    numberMatchTypes = [matchTypeList count];
    // NSLog(@"Match Type List Count = %@", matchTypeList);
    
    // If there are no matches in any section then don't set this stuff. ShowMatch will set currentMatch to
    // nil, printing out blank info in all the display items.
    if (numberMatchTypes) {
        // Temporary method to save the data markers
        storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"dataMarkerMason.csv"];
        fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:storePath]) {
            // Loading Default Data Markers
            _currentSectionType = [[matchDictionary getMatchTypeEnum:[matchTypeList objectAtIndex:0]] intValue];
            _rowIndex = 0;
            _teamIndex = 0;
            _sectionIndex = [self getMatchSectionInfo:_currentSectionType];
        }
        else {
            CSVParser *parser = [CSVParser new];
            [parser openFile: storePath];
            NSMutableArray *csvContent = [parser parseFile];
            // NSLog(@"data marker = %@", csvContent);
            _rowIndex = [[[csvContent objectAtIndex:0] objectAtIndex:0] intValue];
            _teamIndex = [[[csvContent objectAtIndex:0] objectAtIndex:2] intValue];
            _currentSectionType = [[[csvContent objectAtIndex:0] objectAtIndex:1] intValue];
            _sectionIndex = [self getMatchSectionInfo:_currentSectionType];
            if (_sectionIndex == -1) { // The selected match type does not exist
                // Go back to the first section in the table
                _currentSectionType = [[matchDictionary getMatchTypeEnum:[matchTypeList objectAtIndex:0]] intValue];
                _sectionIndex = [self getMatchSectionInfo:_currentSectionType];
            }
        }
    }
        
    [self SetTextBoxDefaults:matchNumber];
    [self SetBigButtonDefaults:matchType];
    [self SetBigButtonDefaults:prevMatch];
    [self SetBigButtonDefaults:nextMatch];

    _red1Table.layer.borderWidth = 2.0;
    _red2Table.layer.borderWidth = 2.0;
    _red3Table.layer.borderWidth = 2.0;
    _blue1Table.layer.borderWidth = 2.0;
    _blue2Table.layer.borderWidth = 2.0;
    _blue3Table.layer.borderWidth = 2.0;

    _teamHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    _teamHeader.backgroundColor = [UIColor lightGrayColor];
    _teamHeader.opaque = YES;
    
	UILabel *teamLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
	teamLabel.text = @"Team";
    teamLabel.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:teamLabel];
    
	UILabel *nMatchesLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 200, 50)];
	nMatchesLabel.text = @"Matches";
    nMatchesLabel.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:nMatchesLabel];
    
	UILabel *autonLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 0, 200, 50)];
	autonLabel.text = @"Auton Points";
    autonLabel.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:autonLabel];

    UILabel *teleOpLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, 0, 200, 50)];
	teleOpLabel.text = @"TeleOp Points";
    teleOpLabel.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:teleOpLabel];

    UILabel *hangLabel = [[UILabel alloc] initWithFrame:CGRectMake(420, 0, 200, 50)];
	hangLabel.text = @"Hangs?";
    hangLabel.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:hangLabel];
   
    UILabel *hangLevelLabel = [[UILabel alloc] initWithFrame:CGRectMake(500, 0, 200, 50)];
	hangLevelLabel.text = @"Hang Level";
    hangLevelLabel.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:hangLevelLabel];

    UILabel *drivingLabel = [[UILabel alloc] initWithFrame:CGRectMake(620, 0, 200, 50)];
	drivingLabel.text = @"Driving";
    drivingLabel.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:drivingLabel];

    UILabel *defenseLabel = [[UILabel alloc] initWithFrame:CGRectMake(710, 0, 200, 50)];
	defenseLabel.text = @"Defense";
    defenseLabel.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:defenseLabel];
    
    UILabel *speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(800, 0, 200, 50)];
	speedLabel.text = @"Speed";
    speedLabel.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:speedLabel];
    
    UILabel *minHeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(880, 0, 200, 50)];
	minHeightLabel.text = @"Minimum Height";
    minHeightLabel.backgroundColor = [UIColor clearColor];
    [_teamHeader addSubview:minHeightLabel];

    teamData = [NSMutableArray arrayWithCapacity:6];
    _teamList = [[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0", @"0", nil];
    _teamMatches = [[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0", @"0", nil];
    _teamAuton = [[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0", @"0", nil];
    _teamTeleOp = [[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0", @"0", nil];
    _teamHang = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", @"", nil];
    _teamHangLevel = [[NSMutableArray alloc] initWithObjects:@"0.0", @"0.0", @"0.0", @"0.0", @"0.0", @"0.0", nil];
    _teamDriving = [[NSMutableArray alloc] initWithObjects:@"0.0", @"0.0", @"0.0", @"0.0", @"0.0", @"0.0", nil];
    _teamDefense = [[NSMutableArray alloc] initWithObjects:@"0.0", @"0.0", @"0.0", @"0.0", @"0.0", @"0.0", nil];
    _teamSpeed = [[NSMutableArray alloc] initWithObjects:@"0.0", @"0.0", @"0.0", @"0.0", @"0.0", @"0.0", nil];
    _teamHeight = [[NSMutableArray alloc] initWithObjects:@"0.0", @"0.0", @"0.0", @"0.0", @"0.0", @"0.0", nil];
    [self ShowMatch];
}


-(NSMutableArray *)getMatchTypeList {
    NSMutableArray *matchTypes = [NSMutableArray array];
    NSString *sectionName;
    for (int i=0; i < [[_fetchedResultsController sections] count]; i++) {
        sectionName = [[[_fetchedResultsController sections] objectAtIndex:i] name];
        // NSLog(@"Section = %@", sectionName);
        [matchTypes addObject:[matchDictionary getMatchTypeString:[NSNumber numberWithInt:[sectionName intValue]]]];
    }
    return matchTypes;
    
}

-(NSUInteger)getMatchSectionInfo:(MatchType)matchSection {
    NSString *sectionName;
    _sectionIndex = -1;
    // Loop for number of sections in table
    for (int i=0; i < [[_fetchedResultsController sections] count]; i++) {
        sectionName = [[[_fetchedResultsController sections] objectAtIndex:i] name];
        if ([sectionName intValue] == matchSection) {
            _sectionIndex = i;
            break;
        }
    }
    return _sectionIndex;
}

-(int)getNumberOfMatches:(NSUInteger)section {
    if ([[_fetchedResultsController sections] count]) {
        return [[[[_fetchedResultsController sections] objectAtIndex:_sectionIndex] objects] count];
    }
    else return 0;
}

-(IBAction)MatchNumberChanged {
    // NSLog(@"MatchNumberChanged");
    
    int matchField = [matchNumber.text intValue];
    int nmatches =  [self getNumberOfMatches:_sectionIndex];
    
    if (matchField > nmatches) { /* Ooops, not that many matches */
        // For now, just change the match field to the last match in the section
        matchField = nmatches;
    }
    _rowIndex = matchField-1;
    
    [self ShowMatch];
    
}

-(IBAction)MatchTypeSelectionChanged:(id)sender {
    //    NSLog(@"matchTypeSelectionChanged");
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
    
    for (int i = 0 ; i < [matchTypeList count] ; i++) {
        if ([newMatchType isEqualToString:[matchTypeList objectAtIndex:i]]) {
            // NSLog(@"New section = %@", newMatchType);
            _currentSectionType = [[matchDictionary getMatchTypeEnum:newMatchType] intValue];
            _sectionIndex = [self getMatchSectionInfo:_currentSectionType];
            break;
        }
    }
    _rowIndex = 0;
    [self ShowMatch];
}

-(IBAction)PrevButton {
    if (_rowIndex > 0) _rowIndex--;
    else {
        _sectionIndex = [self GetPreviousSection:_currentSectionType];
        _rowIndex =  [[[[_fetchedResultsController sections] objectAtIndex:_sectionIndex] objects] count]-1;
    }
    [self ShowMatch];
}

-(IBAction)NextButton {
    int nrows;
    nrows =  [self getNumberOfMatches:_sectionIndex];
    if (_rowIndex < (nrows-1)) _rowIndex++;
    else {
        _rowIndex = 0;
        _sectionIndex = [self GetNextSection:_currentSectionType];
    }
    [self ShowMatch];
}

-(NSUInteger)GetNextSection:(MatchType) currentSection {
    //    NSLog(@"GetNextSection");
    NSUInteger nextSection;
    switch (currentSection) {
        case Practice:
            _currentSectionType = Seeding;
            nextSection = [self getMatchSectionInfo:_currentSectionType];
            if (nextSection == -1) { // There are no seeding matches
                nextSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
        case Seeding:
            _currentSectionType = Elimination;
            nextSection = [self getMatchSectionInfo:_currentSectionType];
            if (nextSection == -1) { // There are no Elimination matches
                nextSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
        case Elimination:
            _currentSectionType = Practice;
            nextSection = [self getMatchSectionInfo:_currentSectionType];
            if (nextSection == -1) { // There are no Practice matches
                // Try seeding matches instead
                _currentSectionType = Seeding;
                nextSection = [self getMatchSectionInfo:_currentSectionType];
                if (nextSection == -1) { // There are no seeding matches either
                    nextSection = [self getMatchSectionInfo:currentSection];
                    _currentSectionType = currentSection;
                }
            }
            break;
        case Other:
            _currentSectionType = Testing;
            nextSection = [self getMatchSectionInfo:_currentSectionType];
            if (nextSection == -1) { // There are no Test matches
                nextSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
        case Testing:
            _currentSectionType = Other;
            nextSection = [self getMatchSectionInfo:_currentSectionType];
            if (nextSection == -1) { // There are no Other matches
                nextSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
    }
    return nextSection;
}

// Move through the rounds
-(NSUInteger)GetPreviousSection:(NSUInteger) currentSection {
    //    NSLog(@"GetPreviousSection");
    NSUInteger newSection;
    switch (currentSection) {
        case Practice:
            _currentSectionType = Testing;
            newSection = [self getMatchSectionInfo:_currentSectionType];
            if (newSection == -1) { // There are no Test matches
                newSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
        case Seeding:
            _currentSectionType = Practice;
            newSection = [self getMatchSectionInfo:_currentSectionType];
            if (newSection == -1) { // There are no Practice matches
                newSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
        case Elimination:
            _currentSectionType = Seeding;
            newSection = [self getMatchSectionInfo:_currentSectionType];
            if (newSection == -1) { // There are no Seeding matches
                newSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
        case Other:
            _currentSectionType = Testing;
            newSection = [self getMatchSectionInfo:_currentSectionType];
            if (newSection == -1) { // There are no Test matches
                newSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
        case Testing:
            _currentSectionType = Other;
            newSection = [self getMatchSectionInfo:_currentSectionType];
            if (newSection == -1) { // There are no Other matches
                newSection = [self getMatchSectionInfo:currentSection];
                _currentSectionType = currentSection;
            }
            break;
    }
    return newSection;
}

-(MatchData *)getCurrentMatch {
    if (numberMatchTypes == 0) {
        return nil;
    }
    else {
        NSIndexPath *matchIndex = [NSIndexPath indexPathForRow:_rowIndex inSection:_sectionIndex];
        return [_fetchedResultsController objectAtIndexPath:matchIndex];
    }
}


-(void)ShowMatch {
    _currentMatch = [self getCurrentMatch];
    [self setTeamList];
    
    [matchType setTitle:_currentMatch.matchType forState:UIControlStateNormal];
    matchNumber.text = [NSString stringWithFormat:@"%d", [_currentMatch.number intValue]];
//    [red1 setTitle: [teamOrder objectAtIndex:0] forState:UIControlStateNormal];
//    [red2 setTitle:[teamOrder objectAtIndex:1] forState:UIControlStateNormal];
//    [red3 setTitle:[teamOrder objectAtIndex:2] forState:UIControlStateNormal];
//    [blue1 setTitle:[teamOrder objectAtIndex:3] forState:UIControlStateNormal];
//    [blue2 setTitle:[teamOrder objectAtIndex:4] forState:UIControlStateNormal];
//    [blue3 setTitle:[teamOrder objectAtIndex:5] forState:UIControlStateNormal];
}

-(void)setTeamList {
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"alliance" ascending:YES];
    NSArray *data = [[_currentMatch.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];

    if (!data) return;

    TeamScore *score;
    [teamData removeAllObjects];

    if ([data count] == 6) {
        // Reds
        for (int i=3; i<6; i++) {
            score = [data objectAtIndex:i];
            [_teamList replaceObjectAtIndex:(i-3)
                                withObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
            [teamStats calculateMasonStats:score.team forTournament:_settings.tournament.name];
            [_teamMatches replaceObjectAtIndex:(i-3)
                                    withObject:[NSString stringWithFormat:@"%d", teamStats.nmatches]];
            [_teamAuton replaceObjectAtIndex:(i-3)
                                    withObject:[NSString stringWithFormat:@"%d", teamStats.autonPoints]];
            [_teamTeleOp replaceObjectAtIndex:(i-3)
                                  withObject:[NSString stringWithFormat:@"%d", teamStats.teleOpPoints]];
            [_teamHang replaceObjectAtIndex:(i-3)
                                   withObject:[NSString stringWithFormat:@"%d", teamStats.hangs]];
            [_teamHangLevel replaceObjectAtIndex:(i-3)
                                    withObject:[NSString stringWithFormat:@"%.1f", teamStats.aveClimbHeight]];
            [_teamDriving replaceObjectAtIndex:(i-3)
                                 withObject:[NSString stringWithFormat:@"%.1f", teamStats.aveDriving]];
            [_teamDefense replaceObjectAtIndex:(i-3)
                                 withObject:[NSString stringWithFormat:@"%.1f", teamStats.aveDefense]];
            [_teamSpeed replaceObjectAtIndex:(i-3)
                                 withObject:[NSString stringWithFormat:@"%.1f", teamStats.aveSpeed]];
            if (score.team.minHeight) {
                [_teamHeight replaceObjectAtIndex:(i-3)
                                  withObject:[NSString stringWithFormat:@"%.1f", [score.team.minHeight floatValue]]];
            }
            else {
                [_teamHeight replaceObjectAtIndex:(i-3)
                                       withObject:[NSString stringWithFormat:@""]];
            }
        }
        // Blues
        for (int i=0; i<3; i++) {
            score = [data objectAtIndex:i];
            [_teamList replaceObjectAtIndex:(i+3)
                                 withObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
            [teamStats calculateMasonStats:score.team forTournament:_settings.tournament.name];
            [_teamMatches replaceObjectAtIndex:(i+3)
                                    withObject:[NSString stringWithFormat:@"%d", teamStats.nmatches]];
            [_teamAuton replaceObjectAtIndex:(i+3)
                                  withObject:[NSString stringWithFormat:@"%d", teamStats.autonPoints]];
            [_teamTeleOp replaceObjectAtIndex:(i+3)
                                   withObject:[NSString stringWithFormat:@"%d", teamStats.teleOpPoints]];
            [_teamHang replaceObjectAtIndex:(i+3)
                                 withObject:[NSString stringWithFormat:@"%d", teamStats.hangs]];
            [_teamHangLevel replaceObjectAtIndex:(i+3)
                                      withObject:[NSString stringWithFormat:@"%.1f", teamStats.aveClimbHeight]];
            [_teamDriving replaceObjectAtIndex:(i+3)
                                    withObject:[NSString stringWithFormat:@"%.1f", teamStats.aveDriving]];
            [_teamDefense replaceObjectAtIndex:(i+3)
                                    withObject:[NSString stringWithFormat:@"%.1f", teamStats.aveDefense]];
            [_teamSpeed replaceObjectAtIndex:(i+3)
                                  withObject:[NSString stringWithFormat:@"%.1f", teamStats.aveSpeed]];
            if (score.team.minHeight) {
                [_teamHeight replaceObjectAtIndex:(i+3)
                                       withObject:[NSString stringWithFormat:@"%.1f", [score.team.minHeight floatValue]]];
            }
            else {
                [_teamHeight replaceObjectAtIndex:(i+3)
                                       withObject:[NSString stringWithFormat:@""]];
            }
        }
    }
    _red1Team.text = [_teamList objectAtIndex:0];
    [_red1Scores removeAllObjects];
    _red1Scores = [self getScoreList:[[data objectAtIndex:3] valueForKey:@"team"]];
    _red2Team.text = [_teamList objectAtIndex:1];
    [_red2Scores removeAllObjects];
    _red2Scores = [self getScoreList:[[data objectAtIndex:4] valueForKey:@"team"]];
    _red3Team.text = [_teamList objectAtIndex:2];
    [_red3Scores removeAllObjects];
    _red3Scores = [self getScoreList:[[data objectAtIndex:5] valueForKey:@"team"]];
    _blue1Team.text = [_teamList objectAtIndex:3];
    [_blue1Scores removeAllObjects];
    _blue1Scores = [self getScoreList:[[data objectAtIndex:0] valueForKey:@"team"]];
    _blue2Team.text = [_teamList objectAtIndex:4];
    [_blue2Scores removeAllObjects];
    _blue2Scores = [self getScoreList:[[data objectAtIndex:1] valueForKey:@"team"]];
    _blue3Team.text = [_teamList objectAtIndex:5];
    [_blue3Scores removeAllObjects];
    _blue3Scores = [self getScoreList:[[data objectAtIndex:2] valueForKey:@"team"]];
    [self.teamInfo reloadData];
    [self.red1Table reloadData];
    [self.red2Table reloadData];
    [self.red3Table reloadData];
    [self.blue1Table reloadData];
    [self.blue2Table reloadData];
    [self.blue3Table reloadData];
}

-(NSMutableArray *)getScoreList:(TeamData *)team {
    NSLog(@"Team = %@", team.number);
    NSArray *allMatches = [team.match allObjects];
    NSMutableArray *scores = [allMatches mutableCopy];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournament.name = %@", _settings.tournament.name];
    [scores filterUsingPredicate:pred];

    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.matchTypeSection" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];

    [scores sortUsingDescriptors:sortDescriptors];
    return scores;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TeamDetail"]) {
        NSIndexPath *indexPath = [ self.teamInfo indexPathForCell:sender];
        TeamDetailViewController *detailViewController = [segue destinationViewController];
        [segue.destinationViewController setDataManager:_dataManager];
        NSLog(@"Team = %@", [_teamList objectAtIndex:indexPath.row]);
        TeamData *team = [[[TeamDataInterfaces alloc] initWithDataManager:_dataManager] getTeam:[_teamList objectAtIndex:indexPath.row]];
        detailViewController.team = team;
        [_teamInfo deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        NSIndexPath *indexPath;
        [segue.destinationViewController setDrawDirectory:_settings.tournament.directory];
        if ([segue.identifier isEqualToString:@"Red1"]) {
            indexPath = [self.red1Table indexPathForCell:sender];
            [_red1Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:_red1Scores];
        }
        else if ([segue.identifier isEqualToString:@"Red2"]) {
            indexPath = [self.red2Table indexPathForCell:sender];
            [_red2Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:_red2Scores];
        }
        else if ([segue.identifier isEqualToString:@"Red3"]) {
            indexPath = [self.red3Table indexPathForCell:sender];
            [_red3Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:_red3Scores];
        }
        else if ([segue.identifier isEqualToString:@"Blue1"]) {
            indexPath = [self.blue1Table indexPathForCell:sender];
            [_blue1Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:_blue1Scores];
        }
        else if ([segue.identifier isEqualToString:@"Blue2"]) {
            indexPath = [self.blue2Table indexPathForCell:sender];
            [_blue2Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:_blue2Scores];
        }
        else if ([segue.identifier isEqualToString:@"Blue3"]) {
            indexPath = [self.blue3Table indexPathForCell:sender];
            [_blue3Table deselectRowAtIndexPath:indexPath animated:YES];
            [segue.destinationViewController setTeamScores:_blue3Scores];
        }
        [segue.destinationViewController setStartingIndex:indexPath.row];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    //    NSLog(@"viewWillDisappear");
    NSString *dataMarkerString;
    storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"dataMarkerMason.csv"];
    dataMarkerString = [NSString stringWithFormat:@"%d, %d, %d\n", _rowIndex, _currentSectionType, _teamIndex];
    [dataMarkerString writeToFile:storePath
                       atomically:YES
                         encoding:NSUTF8StringEncoding
                            error:nil];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _teamInfo) return _teamHeader;
    else return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _teamInfo) return 50;
    else return 0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _teamInfo) return [_teamList count];
    if (tableView == _red1Table) return [_red1Scores count];
    if (tableView == _red2Table) return [_red2Scores count];
    if (tableView == _red3Table) return [_red3Scores count];
    if (tableView == _blue1Table) return [_blue1Scores count];
    if (tableView == _blue2Table) return [_blue2Scores count];
    if (tableView == _blue3Table) return [_blue3Scores count];
    else return [teamData count];
}

- (void)configureScoreCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    // Set a background for the cell
    // UIImageView *tableBackground = [[UIImageView alloc] initWithFrame:cell.frame];
    // UIImage *image = [UIImage imageNamed:@"Blue Fade.gif"];
    // tableBackground.image = image;
    //  cell.backgroundView = imageView; Change Varable Name "soon"
    
	UILabel *teamNumber = (UILabel *)[cell viewWithTag:10];
	teamNumber.text = [_teamList objectAtIndex:indexPath.row];

	UILabel *nMatchesLabel = (UILabel *)[cell viewWithTag:20];
    nMatchesLabel.text = [_teamMatches objectAtIndex:indexPath.row];

	UILabel *autonLabel = (UILabel *)[cell viewWithTag:30];
	autonLabel.text = [_teamAuton objectAtIndex:indexPath.row];

    UILabel *teleOpLabel = (UILabel *)[cell viewWithTag:40];
	teleOpLabel.text = [_teamTeleOp objectAtIndex:indexPath.row];

    UILabel *hangLabel = (UILabel *)[cell viewWithTag:50];
    hangLabel.text = ([[_teamHang objectAtIndex:indexPath.row] intValue]) ? @"Y": @"N";

    UILabel *hangLevel = (UILabel *)[cell viewWithTag:55];
	hangLevel.text = [_teamHangLevel objectAtIndex:indexPath.row];

    UILabel *drivingLabel = (UILabel *)[cell viewWithTag:60];
	drivingLabel.text = [_teamDriving objectAtIndex:indexPath.row];

    UILabel *defenseLabel = (UILabel *)[cell viewWithTag:70];
	defenseLabel.text = [_teamDefense objectAtIndex:indexPath.row];

    UILabel *speedLabel = (UILabel *)[cell viewWithTag:80];
	speedLabel.text = [_teamSpeed objectAtIndex:indexPath.row];

    UILabel *heightLabel = (UILabel *)[cell viewWithTag:90];
	heightLabel.text = [_teamHeight objectAtIndex:indexPath.row];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _teamInfo) {
        UITableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:@"TeamInfo"];
        // Set up the cell...
        [self configureScoreCell:cell atIndexPath:indexPath];
        
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"TeamCell"];
        TeamScore *score;
        if (tableView == _red1Table) {
            score = [_red1Scores objectAtIndex:indexPath.row];
        }
        else if (tableView == _red2Table) {
            score = [_red2Scores objectAtIndex:indexPath.row];
        }
        else if (tableView == _red3Table) {
            score = [_red3Scores objectAtIndex:indexPath.row];
        }
        else if (tableView == _blue1Table) {
            score = [_blue1Scores objectAtIndex:indexPath.row];
        }
        else if (tableView == _blue2Table) {
            score = [_blue2Scores objectAtIndex:indexPath.row];
        }
        else if (tableView == _blue3Table) {
            score = [_blue3Scores objectAtIndex:indexPath.row];
        }
        UILabel *number = (UILabel *)[cell viewWithTag:10];
        number.text = [NSString stringWithFormat:@"%d", [score.match.number intValue]];
 
        UILabel *type = (UILabel *)[cell viewWithTag:20];
        type.text = score.match.matchType; 
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _red1Table) {
    NSLog(@"Cell frame.size.width=%f", cell.frame.size.width);
//        cell.frame.size.width = 125.0;
    }
}

-(void)SetTextBoxDefaults:(UITextField *)currentTextField {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
}

-(void)SetBigButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    // Round button corners
    CALayer *btnLayer = [currentButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:10.0f];
    // Apply a 1 pixel, black border
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    // Set the button Background Color
    [currentButton setBackgroundColor:[UIColor whiteColor]];
    // Set the button Text Color
    [currentButton setTitleColor:[UIColor colorWithRed:(0.0/255) green:(0.0/255) blue:(120.0/255) alpha:1.0 ]forState: UIControlStateNormal];
}

-(void)SetSmallButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    // Round button corners
    CALayer *btnLayer = [currentButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:10.0f];
    // Apply a 1 pixel, black border
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    // Set the button Background Color
    [currentButton setBackgroundColor:[UIColor whiteColor]];
    // Set the button Text Color
    [currentButton setTitleColor:[UIColor colorWithRed:(0.0/255) green:(0.0/255) blue:(120.0/255) alpha:1.0 ]forState: UIControlStateNormal];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField != matchNumber)  return YES;
    
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    
    NSInteger holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    
    return [scan scanInteger: &holder] && [scan isAtEnd];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //    NSLog(@"should end editing");
	return YES;
}

#pragma mark -
#pragma mark Text

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)retrieveSettings {
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SettingsData" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *settingsRecord = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
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

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchData" inManagedObjectContext:_managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchTypeSection" ascending:YES];
        NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
        // Add the search for tournament name
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournament CONTAINS %@", _settings.tournament.name];
        [fetchRequest setPredicate:pred];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc]
         initWithFetchRequest:fetchRequest
         managedObjectContext:_managedObjectContext
         sectionNameKeyPath:@"matchTypeSection"
         cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
	
	return _fetchedResultsController;
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{   return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setRed2Team:nil];
    [self setRed3Team:nil];
    [self setRed3Table:nil];
    [self setBlue1Table:nil];
    [self setBlue2Team:nil];
    [self setBlue2Table:nil];
    [self setBlue3Table:nil];
    [super viewDidUnload];
}
@end
