//
//  SyncViewController.m
//  UltimateAscent
//
//  Created by FRC on 3/13/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "SyncResultsViewController.h"
#import "SettingsData.h"
#import "DataManager.h"
#import "TournamentData.h"
#import "MatchData.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "MatchResultsObject.h"

@interface SyncResultsViewController ()

@end

@implementation SyncResultsViewController {
    SettingsData *settings;
    NSMutableArray *receivedMatches;
    NSMutableArray *receivedMatchTypes;
    NSMutableArray *receivedTeams;
    MatchResultsObject *dataFromTransfer;
}

@synthesize dataManager = _dataManager;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize currentSession = _currentSession;
@synthesize blueToothType = _blueToothType;
@synthesize headerView = _headerView;
@synthesize headerView2 = _headerView2;
@synthesize sendDataTable = _sendDataTable;
@synthesize receiveDataTable = _receiveDataTable;
@synthesize connectButton = _connectButton;
@synthesize disconnectButton = _disconnectButton;
@synthesize peerLabel = _peerLabel;
@synthesize peerName = _peerName;
@synthesize alertPrompt = _alertPrompt;
@synthesize alertPromptPopover = _alertPromptPopover;

GKPeerPickerController *picker;

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
    if (settings) {
        self.title =  [NSString stringWithFormat:@"%@ Match Synchronization", settings.tournament.name];
    }
    else {
        self.title = @"Match Synchronization";
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
    [_connectButton setHidden:NO];
    [_disconnectButton setHidden:YES];
    [_peerLabel setHidden:YES];
    [_peerName setHidden:YES];
    [_sendDataTable setHidden:YES];
    [_receiveDataTable setHidden:YES];
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,282,50)];
    _headerView.backgroundColor = [UIColor lightGrayColor];
    _headerView.opaque = YES;
    
    _headerView2 = [[UIView alloc] initWithFrame:CGRectMake(0,0,282,50)];
    _headerView2.backgroundColor = [UIColor orangeColor];
    _headerView2.opaque = YES;
 
	UILabel *matchLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 11, 55, 21)];
	matchLabel.text = @"Match";
    matchLabel.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:matchLabel];
    
 	UILabel *matchTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 11, 65, 21)];
	matchTypeLabel.text = @"Type";
    matchTypeLabel.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:matchTypeLabel];

    UILabel *teamLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 11, 65, 21)];
	teamLabel.text = @"Team";
    teamLabel.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:teamLabel];

    UILabel *syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, 11, 65, 21)];
	syncLabel.text = @"Synced";
    syncLabel.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:syncLabel];
}

- (void) viewWillDisappear:(BOOL)animated
{
    //    NSLog(@"viewWillDisappear");
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

-(IBAction) btnConnect:(id) sender {
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [_connectButton setHidden:YES];
    [_disconnectButton setHidden:NO];
    [picker show];
}

-(IBAction) btnDisconnect:(id) sender {
    [self.currentSession disconnectFromAllPeers];
    _currentSession = nil;
    
    [_connectButton setHidden:NO];
    [_disconnectButton setHidden:YES];
}

- (void)peerPickerController:(GKPeerPickerController *)picker
              didConnectPeer:(NSString *)peerID
                   toSession:(GKSession *) session {
    self.currentSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    [_peerLabel setHidden:NO];
    [_peerName setHidden:NO];
    _peerName.text = [session displayNameForPeer:peerID];
    picker.delegate = nil;
    
    [picker dismiss];

}

- (void)session:(GKSession *)sessionpeer
           peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state {
    switch (state)
    {
        case GKPeerStateConnected:
            NSLog(@"connected");
            [_sendDataTable setHidden:NO];
            [_receiveDataTable setHidden:NO];
            break;
        case GKPeerStateDisconnected:
            NSLog(@"disconnected");
            _currentSession = nil;
            [_connectButton setHidden:NO];
            [_disconnectButton setHidden:YES];
            [_peerLabel setHidden:YES];
            [_peerName setHidden:YES];
            break;
        case GKPeerStateAvailable:
        case GKPeerStateConnecting:
        case GKPeerStateUnavailable:
            break;
    }
}

- (void) mySendDataToPeers:(NSData *) data
{
    if (_currentSession)
        [self.currentSession sendDataToAllPeers:data
                                   withDataMode:GKSendDataReliable
                                          error:nil];
}

- (void) receiveData:(NSData *)data
            fromPeer:(NSString *)peer
           inSession:(GKSession *)session
             context:(void *)context {
    
    dataFromTransfer = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //---convert the NSData to NSString---
    if (receivedMatches == nil) {
        receivedMatches = [NSMutableArray array];
    }
    if (receivedMatchTypes == nil) {
        receivedMatchTypes = [NSMutableArray array];
    }
    if (receivedTeams == nil) {
        receivedTeams = [NSMutableArray array];
    }
    if ([self addMatchScore:dataFromTransfer]) {
        [receivedMatches addObject:dataFromTransfer.match];
        [receivedMatchTypes addObject:dataFromTransfer.matchType];
        [receivedTeams addObject:dataFromTransfer.team];
        [_receiveDataTable reloadData];
    }
    else {
        NSString* str = [NSString stringWithFormat:@"Match %@, Team %@ Already Synced", dataFromTransfer.match, dataFromTransfer.team];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync Again?"
                                                        message:str
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"error = %@", error);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"alert");
    if (buttonIndex == 1) { // Yes
        NSLog(@"Resync Match");
        if ([self addMatchScore:dataFromTransfer]) {
            [receivedMatches addObject:dataFromTransfer.match];
            [receivedMatchTypes addObject:dataFromTransfer.matchType];
            [receivedTeams addObject:dataFromTransfer.team];
            [_receiveDataTable reloadData];
        }        
    }
}

-(BOOL)addMatchScore:(MatchResultsObject *) xferData {
    // Fetch score record
    // Copy the data into the right places
    // Put the match drawing in the correct directory
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamScore" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"match.number == %@ AND match.matchType CONTAINS %@ and tournament.name CONTAINS %@ and team.number == %@", xferData.match, xferData.matchType, xferData.tournament, xferData.team];
    [fetchRequest setPredicate:predicate];
    
    NSArray *scoreData = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!scoreData) {
        NSLog(@"Karma disruption error");
        return FALSE;
    }
    else {
        if([scoreData count] > 0) {  // Match Exists
            TeamScore *score = [scoreData objectAtIndex:0];
 /*           if ([score.saved intValue]) {
                // Match already saved on this device
                return FALSE;
            }*/
            [self unpackXferData:xferData forScore:score];
            return TRUE;
        }
        else {
            return FALSE;
        }
    }
}

-(void)unpackXferData:(MatchResultsObject *)xferData forScore:(TeamScore *)score {
    score.alliance = xferData.alliance;
    score.autonHigh = xferData.autonHigh;
    score.autonLow = xferData.autonLow;
    score.autonMid = xferData.autonMid;
    score.autonMissed = xferData.autonMissed;
    score.autonShotsMade = xferData.autonShotsMade;
    score.blocks = xferData.blocks;
    score.climbAttempt = xferData.climbAttempt;
    score.climbLevel = xferData.climbLevel;
    score.climbTimer = xferData.climbTimer;
    score.defenseRating = xferData.defenseRating;
    score.driverRating = xferData.driverRating;
    score.fieldDrawing = xferData.fieldDrawing;
    score.floorPickUp = xferData.floorPickUp;
    score.notes = xferData.notes;
    score.otherRating = xferData.otherRating;
    score.passes = xferData.passes;
    score.pyramid = xferData.pyramid;
    score.robotSpeed = xferData.robotSpeed;
    score.teleOpHigh = xferData.teleOpHigh;
    score.teleOpLow = xferData.teleOpLow;
    score.teleOpMid = score.teleOpMid;
    score.teleOpMissed = xferData.teleOpMissed;
    score.teleOpShots = xferData.teleOpShots;
    score.totalAutonShots = xferData.totalAutonShots;
    score.totalTeleOpShots = xferData.totalTeleOpShots;
    score.wallPickUp = xferData.wallPickUp;
    score.wallPickUp1 = xferData.wallPickUp1;
    score.wallPickUp2 = xferData.wallPickUp2;
    score.wallPickUp3 = xferData.wallPickUp3;
    score.wallPickUp4 = xferData.wallPickUp4;
    score.allianceSection = xferData.allianceSection;
    score.sc1 = xferData.sc1;
    score.sc2 = xferData.sc2;
    score.sc3 = xferData.sc3;
    score.sc4 = xferData.sc4;
    score.sc5 = xferData.sc5;
    score.sc6 = xferData.sc6;
    score.sc7 = xferData.sc7;
    score.sc8 = xferData.sc8;
    score.sc9 = xferData.sc9;
    // For now, set saved to zero so that we know that this iPad didn't do the scouting
    score.saved = [NSNumber numberWithInt:0];
    // Set synced to one so that we know it has been received
    score.synced = [NSNumber numberWithInt:1];
    
    // Save the picture
    NSString *baseDrawingPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",xferData.drawingPath]];

    // Check if robot directory exists, if not, create it
    if (![[NSFileManager defaultManager] fileExistsAtPath:baseDrawingPath isDirectory:NO]) {
        if (![[NSFileManager defaultManager]createDirectoryAtPath:baseDrawingPath
                                      withIntermediateDirectories: YES
                                                       attributes: nil
                                                            error: NULL]) {
            NSLog(@"Dreadful error creating directory to save field drawings");
            return;
        }
    }
    baseDrawingPath = [baseDrawingPath stringByAppendingPathComponent:score.fieldDrawing];
    NSLog(@"score = %@", score);
    NSLog(@"base path = %@", baseDrawingPath);
    UIImage *imge = [UIImage imageWithData:xferData.fieldDrawingImage];
    [UIImagePNGRepresentation(imge) writeToFile:baseDrawingPath atomically:YES];
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _receiveDataTable) {
        return _headerView2;
    }
    else return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _receiveDataTable) {
    }
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _receiveDataTable) {
    }
    if (tableView == _sendDataTable) {
        NSInteger count = [[_fetchedResultsController sections] count];
        if (count == 0) {
            count = 1;
        }
        return count;
    }
    else {
        if ([receivedMatches count]) return 1;
        else return 0;
    }
}
        
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == _sendDataTable) {
        id <NSFetchedResultsSectionInfo> sectionInfo =
        [[_fetchedResultsController sections] objectAtIndex:section];
    
        return [sectionInfo numberOfObjects];
    }
    else {
        return [receivedMatches count];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TeamScore *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    // Configure the cell...
    // Set a background for the cell
    
	UILabel *numberLabel = (UILabel *)[cell viewWithTag:10];
	numberLabel.text = [NSString stringWithFormat:@"%d", [info.match.number intValue]];
    
	UILabel *matchTypeLabel = (UILabel *)[cell viewWithTag:20];
    matchTypeLabel.text = info.match.matchType;
    
	UILabel *teamLabel = (UILabel *)[cell viewWithTag:30];
    teamLabel.text = [NSString stringWithFormat:@"%d", [info.team.number intValue]];

	UILabel *syncLabel = (UILabel *)[cell viewWithTag:40];
    syncLabel.text = ([info.synced intValue] == 0) ? @"N" : @"Y";
}

- (void)configureReceivedCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    // Set a background for the cell
    
	UILabel *numberLabel = (UILabel *)[cell viewWithTag:10];
	numberLabel.text = [NSString stringWithFormat:@"%d", [[receivedMatches objectAtIndex:indexPath.row] intValue]];

	UILabel *matchTypeLabel = (UILabel *)[cell viewWithTag:20];
    matchTypeLabel.text = [receivedMatchTypes objectAtIndex:indexPath.row];
    
	UILabel *teamLabel = (UILabel *)[cell viewWithTag:30];
    teamLabel.text = [NSString stringWithFormat:@"%d", [[receivedTeams objectAtIndex:indexPath.row] intValue]];
    
	UILabel *syncLabel = (UILabel *)[cell viewWithTag:40];
    syncLabel.text = @"";   //([info.synced intValue] == 0) ? @"N" : @"Y";
 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _sendDataTable) {
        UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"SendData"];
        // Set up the cell...
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:@"ReceiveData"];
        [self configureReceivedCell:cell atIndexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _receiveDataTable) return;
    
    MatchResultsObject *transferObject = [[MatchResultsObject alloc] initWithScore:[_fetchedResultsController objectAtIndexPath:indexPath]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:transferObject];
    [self mySendDataToPeers:data];
    TeamScore *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    info.synced = [NSNumber numberWithInt:1];
    NSString* str = @"Sending";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data sending"
                                                    message:str
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

/*
    NSLog(@"Temp =====================================================");
    TeamScore *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (receivedMatches == nil) {
        receivedMatches = [NSMutableArray array];
    }
    if (receivedMatchTypes == nil) {
        receivedMatchTypes = [NSMutableArray array];
    }
    if (receivedTeams == nil) {
        receivedTeams = [NSMutableArray array];
    }
    [receivedMatches addObject:info.match.number];
    [receivedMatchTypes addObject:info.match.matchType];
    [receivedTeams addObject:info.team.number];
    [_receiveDataTable reloadData];
 */

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TeamScore" inManagedObjectContext:_managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.matchTypeSection" ascending:YES];
        NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.number" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
        NSLog(@"Fix this");
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(ANY tournament = %@) AND (saved == 1)", settings.tournament];
//        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(ANY tournament = %@) AND (saved == 1) AND (synced == 1)", settings.tournament];
        [fetchRequest setPredicate:pred];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc]
         initWithFetchRequest:fetchRequest
         managedObjectContext:_managedObjectContext
         sectionNameKeyPath:nil
         cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
	
	return _fetchedResultsController;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
