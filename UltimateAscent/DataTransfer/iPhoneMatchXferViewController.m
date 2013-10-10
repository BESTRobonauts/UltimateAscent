//
//  iPhoneMatchXferViewController.m
//  UltimateAscent
//
//  Created by FRC on 7/25/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "iPhoneMatchXferViewController.h"
#import "DataManager.h"
#import "SettingsData.h"
#import "TournamentData.h"
#import "MatchData.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "MatchResultsObject.h"

@interface iPhoneMatchXferViewController ()

@end

@implementation iPhoneMatchXferViewController {
    NSArray *teamData;
    NSMutableArray *teamOrder;
    BOOL connected;
    NSMutableArray *receivedMatches;
    NSMutableArray *receivedMatchTypes;
    NSMutableArray *receivedTeams;
    MatchResultsObject *dataFromTransfer;
}

@synthesize dataManager = _dataManager;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize currentSession = _currentSession;
@synthesize headerView = _headerView;
@synthesize settings = _settings;
@synthesize xfer_mode = _xfer_mode;
@synthesize connectStatusButton = _connectStatusButton;
@synthesize peerName = _peerName;
@synthesize matchList = _matchList;

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
    NSError *error = nil;
    NSLog(@"Mode = %d", _xfer_mode);
    [self retrieveSettings];
    if (_settings) {
        self.title =  [NSString stringWithFormat:@"%@ Sync", _settings.tournament.name];
    }
    else {
        self.title = @"Sync Match List";
    }
    connected = FALSE;
    
    [_peerName setHidden:YES];

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
    
    [_connectStatusButton setTitle:@"Connect" forState:UIControlStateNormal];

    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    _headerView.backgroundColor = [UIColor lightGrayColor];
    _headerView.opaque = YES;
    
 	UILabel *matchLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 200, 50)];
	matchLabel.text = @"M";
    matchLabel.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:matchLabel];
    
 	UILabel *matchTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(39, 0, 200, 50)];
	matchTypeLabel.text = @"T";
    matchTypeLabel.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:matchTypeLabel];
    
 	UILabel *red1Label = [[UILabel alloc] initWithFrame:CGRectMake(69, 0, 200, 50)];
	red1Label.text = @"R1";
    red1Label.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:red1Label];
    
    UILabel *red2Label = [[UILabel alloc] initWithFrame:CGRectMake(99, 0, 200, 50)];
	red2Label.text = @"R2";
    red2Label.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:red2Label];
    
    UILabel *red3Label = [[UILabel alloc] initWithFrame:CGRectMake(140, 0, 200, 50)];
	red3Label.text = @"R3";
    red3Label.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:red3Label];
    
    UILabel *blue1Label = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 200, 50)];
	blue1Label.text = @"B1";
    blue1Label.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:blue1Label];
    
    UILabel *blue2Label = [[UILabel alloc] initWithFrame:CGRectMake(245, 0, 200, 50)];
	blue2Label.text = @"B2";
    blue2Label.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:blue2Label];
    
    UILabel *blue3Label = [[UILabel alloc] initWithFrame:CGRectMake(290, 0, 200, 50)];
	blue3Label.text = @"B3";
    blue3Label.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:blue3Label];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (IBAction)gameKitHookUp:(id)sender {
    if (connected) {
        [self.currentSession disconnectFromAllPeers];
        _currentSession = nil;
    }
    else {
        picker = [[GKPeerPickerController alloc] init];
        picker.delegate = self;
        picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
        [picker show];
    }
}

- (void)peerPickerController:(GKPeerPickerController *)picker
              didConnectPeer:(NSString *)peerID
                   toSession:(GKSession *) session {
    self.currentSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
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
            connected = TRUE;
            [_connectStatusButton setTitle:@"Disconnect" forState:UIControlStateNormal];
            //      [_sendDataTable setHidden:NO];
 //           [_receiveDataTable setHidden:NO];
            break;
        case GKPeerStateDisconnected:
            NSLog(@"disconnected");
            [_connectStatusButton setTitle:@"Connect" forState:UIControlStateNormal];
            connected = FALSE;
            _currentSession = nil;
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
        [_matchList reloadData];
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

-(BOOL)addMatchScore:(MatchResultsObject *) xferData {
    // Fetch score record
    // Copy the data into the right places
    // Put the match drawing in the correct directory
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"match.number == %@ AND match.matchType CONTAINS %@ and tournament.name CONTAINS %@ and team.number == %@", xferData.match, xferData.matchType, xferData.tournament, xferData.team];
    [fetchRequest setPredicate:predicate];
    
    NSArray *scoreData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
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
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"error = %@", error);
}


-(void)setTeamList:(MatchData *)match {
    TeamScore *score;
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"alliance" ascending:YES];
    teamData = [[match.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];
    
    if (teamOrder == nil) {
        teamOrder = [NSMutableArray array];
        // Reds
        for (int i = 3; i < 6; i++) {
            score = [teamData objectAtIndex:i];
            [teamOrder addObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
        // Blues
        for (int i = 0; i < 3; i++) {
            score = [teamData objectAtIndex:i];
            [teamOrder addObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
        
    }
    else {
        // Reds
        for (int i = 3; i < 6; i++) {
            score = [teamData objectAtIndex:i];
            [teamOrder replaceObjectAtIndex:(i-3)
                                 withObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
        // Blues
        for (int i = 0; i < 3; i++) {
            score = [teamData objectAtIndex:i];
            [teamOrder replaceObjectAtIndex:(i+3)
                                 withObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
    }
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
            NSError *error;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            entity = [NSEntityDescription entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"name CONTAINS %@", @"Texas Robot Roundup"];
            [fetchRequest setPredicate:pred];
            NSArray *tournament = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            _settings.tournament = [tournament objectAtIndex:0];
            if (![_dataManager.managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
    }
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    NSLog(@"Rows = %d", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[_fetchedResultsController sections] count];
	if (count == 0) {
		count = 1;
	}
    return count;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    MatchData *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    // Configure the cell...

    [self setTeamList:info];
    
	UILabel *numberLabel = (UILabel *)[cell viewWithTag:10];
	numberLabel.text = [NSString stringWithFormat:@"%d", [info.number intValue]];
    
	UILabel *matchTypeLabel = (UILabel *)[cell viewWithTag:20];
    matchTypeLabel.text = [info.matchType substringToIndex:1];

	UILabel *red1Label = (UILabel *)[cell viewWithTag:30];
    red1Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:0] intValue]];

    UILabel *red2Label = (UILabel *)[cell viewWithTag:40];
    red2Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:1] intValue]];
    
	UILabel *red3Label = (UILabel *)[cell viewWithTag:50];
    red3Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:2] intValue]];
    
	UILabel *blue1Label = (UILabel *)[cell viewWithTag:60];
    blue1Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:3] intValue]];
    
	UILabel *blue2Label = (UILabel *)[cell viewWithTag:70];
    blue2Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:4] intValue]];
    
	UILabel *blue3Label = (UILabel *)[cell viewWithTag:80];
    blue3Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:5] intValue]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"MatchList"];
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


#pragma mark -
#pragma mark Match List Management

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchTypeSection" ascending:YES];
        NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        // Add the search for tournament name
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournament CONTAINS %@", _settings.tournament.name];
        [fetchRequest setPredicate:pred];
        [fetchRequest setFetchBatchSize:20];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc]
         initWithFetchRequest:fetchRequest
         managedObjectContext:_dataManager.managedObjectContext
         sectionNameKeyPath:nil
         cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
	return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.matchList beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.matchList;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.matchList insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.matchList deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.matchList endUpdates];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setConnectStatusButton:nil];
    [self setPeerName:nil];
    [self setMatchList:nil];
    [super viewDidUnload];
}

@end
