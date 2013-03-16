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
}

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
        DataManager *dataManager = [DataManager new];
        _managedObjectContext = [dataManager managedObjectContext];
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
    [_headerView addSubview:syncLabel];}

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
    
    NSLog(@"Receiving");
    MatchResultsObject *dataFromTransfer = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //---convert the NSData to NSString---
    NSLog(@"Received %@", dataFromTransfer.alliance);
    if (receivedMatches == nil) {
        receivedMatches = [NSMutableArray array];
    }
    if (receivedMatchTypes == nil) {
        receivedMatchTypes = [NSMutableArray array];
    }
    if (receivedTeams == nil) {
        receivedTeams = [NSMutableArray array];
    }
    [receivedMatches addObject:dataFromTransfer.match];
    [receivedMatchTypes addObject:dataFromTransfer.matchType];
    [receivedTeams addObject:dataFromTransfer.team];
    [_receiveDataTable reloadData];
    NSString* str = @"Receiving";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data received"
                                                    message:str
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"error = %@", error);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"alert");
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _receiveDataTable) {
        NSLog(@"header table view = %@", tableView);
        return _headerView2;
    }
    else return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _receiveDataTable) {
        NSLog(@"height table view = %@", tableView);
    }
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _receiveDataTable) {
    NSLog(@"sections table view = %@", tableView);
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
    NSLog(@"rows table view = %@", tableView);
    // Return the number of rows in the section.
    if (tableView == _sendDataTable) {
        id <NSFetchedResultsSectionInfo> sectionInfo =
        [[_fetchedResultsController sections] objectAtIndex:section];
        NSLog(@"saved %d", [sectionInfo numberOfObjects]);
    
        return [sectionInfo numberOfObjects];
    }
    else {
        return [receivedMatches count];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TeamScore *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"configureCell");
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
    NSLog(@"configureReceiver");
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
    NSLog(@"cellforrow table view = %@", tableView);
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
    
    NSLog(@"did select");
    MatchResultsObject *transferObject = [[MatchResultsObject alloc] initWithScore:[_fetchedResultsController objectAtIndexPath:indexPath]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:transferObject];
    [self mySendDataToPeers:data];
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
        // Add the search for tournament name
//        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(saved == 1) AND (synced == 1)"];
        NSLog(@"Fix this");
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(ANY tournament = %@) AND (saved == 1) AND (synced == 0)", settings.tournament];
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
