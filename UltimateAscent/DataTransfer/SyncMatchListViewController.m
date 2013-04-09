//
//  SyncMatchListViewController.m
//  UltimateAscent
//
//  Created by FRC on 4/4/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "SyncMatchListViewController.h"
#import "DataManager.h"
#import "SettingsData.h"
#import "TournamentData.h"
#import "MatchData.h"

@interface SyncMatchListViewController ()

@end

@implementation SyncMatchListViewController {
    NSMutableArray *receivedMatches;
}

@synthesize dataManager = _dataManager;
@synthesize settings = _settings;
@synthesize currentSession = _currentSession;
@synthesize receiveDataTable = _receiveDataTable;
@synthesize connectButton = _connectButton;
@synthesize disconnectButton = _disconnectButton;
@synthesize peerLabel = _peerLabel;
@synthesize peerName = _peerName;
@synthesize headerView = _headerView;

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
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    
    [self retrieveSettings];
    if (_settings) {
        self.title =  [NSString stringWithFormat:@"%@ Sync Match List", _settings.tournament.name];
    }
    else {
        self.title = @"Sync Match List";
    }
    [_connectButton setHidden:NO];
    [_disconnectButton setHidden:YES];
    [_peerLabel setHidden:YES];
    [_peerName setHidden:YES];
//    [_sendDataTable setHidden:YES];
//    [_receiveDataTable setHidden:YES];
    
    [self setHeaders:_headerView];
    
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
      //      [_sendDataTable setHidden:NO];
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
//
/*    dataFromTransfer = [NSKeyedUnarchiver unarchiveObjectWithData:data];*
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
    }*/
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"error = %@", error);
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
        }
    }
}

-(void) setHeaders:(UIView *)header {
    header = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    header.backgroundColor = [UIColor lightGrayColor];
    header.opaque = YES;
    
 	UILabel *matchLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 200, 50)];
	matchLabel.text = @"Match";
    matchLabel.backgroundColor = [UIColor clearColor];
    [header addSubview:matchLabel];
    
 	UILabel *matchTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(82, 0, 200, 50)];
	matchTypeLabel.text = @"Type";
    matchTypeLabel.backgroundColor = [UIColor clearColor];
    [header addSubview:matchTypeLabel];
    
 	UILabel *red1Label = [[UILabel alloc] initWithFrame:CGRectMake(145, 0, 200, 50)];
	red1Label.text = @"Red 1";
    red1Label.backgroundColor = [UIColor clearColor];
    [header addSubview:red1Label];
    
    UILabel *red2Label = [[UILabel alloc] initWithFrame:CGRectMake(216, 0, 200, 50)];
	red2Label.text = @"Red 2";
    red2Label.backgroundColor = [UIColor clearColor];
    [header addSubview:red2Label];
    
    UILabel *red3Label = [[UILabel alloc] initWithFrame:CGRectMake(286, 0, 200, 50)];
	red3Label.text = @"Red 3";
    red3Label.backgroundColor = [UIColor clearColor];
    [header addSubview:red3Label];
    
    UILabel *blue1Label = [[UILabel alloc] initWithFrame:CGRectMake(393, 0, 200, 50)];
	blue1Label.text = @"Blue 1";
    blue1Label.backgroundColor = [UIColor clearColor];
    [header addSubview:blue1Label];
    
    UILabel *blue2Label = [[UILabel alloc] initWithFrame:CGRectMake(466, 0, 200, 50)];
	blue2Label.text = @"Blue 2";
    blue2Label.backgroundColor = [UIColor clearColor];
    [header addSubview:blue2Label];
    
    UILabel *blue3Label = [[UILabel alloc] initWithFrame:CGRectMake(537, 0, 200, 50)];
	blue3Label.text = @"Blue 3";
    blue3Label.backgroundColor = [UIColor clearColor];
    [header addSubview:blue3Label];
    
    UILabel *redLabel = [[UILabel alloc] initWithFrame:CGRectMake(643, 0, 200, 50)];
	redLabel.text = @"Red";
    redLabel.backgroundColor = [UIColor clearColor];
    [header addSubview:redLabel];
    
    UILabel *blueLabel = [[UILabel alloc] initWithFrame:CGRectMake(711, 0, 200, 50)];
	blueLabel.text = @"Blue";
    blueLabel.backgroundColor = [UIColor clearColor];
    [header addSubview:blueLabel];

}


#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _receiveDataTable) {
        return _headerView;
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
/*    if (tableView == _sendDataTable) {
        NSInteger count = [[_fetchedResultsController sections] count];
        if (count == 0) {
            count = 1;
        }
        return count;
    }
    else {*/
        if ([receivedMatches count]) return 1;
        else return 0;
 //   }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
/*    if (tableView == _sendDataTable) {
        id <NSFetchedResultsSectionInfo> sectionInfo =
        [[_fetchedResultsController sections] objectAtIndex:section];
        
        return [sectionInfo numberOfObjects];
    }
    else { */
        return [receivedMatches count];
//    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
/*    TeamScore *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    // Configure the cell...
    // Set a background for the cell
    
	UILabel *numberLabel = (UILabel *)[cell viewWithTag:10];
	numberLabel.text = [NSString stringWithFormat:@"%d", [info.match.number intValue]];
    
	UILabel *matchTypeLabel = (UILabel *)[cell viewWithTag:20];
    matchTypeLabel.text = info.match.matchType;
    
	UILabel *teamLabel = (UILabel *)[cell viewWithTag:30];
    teamLabel.text = [NSString stringWithFormat:@"%d", [info.team.number intValue]];
    
	UILabel *syncLabel = (UILabel *)[cell viewWithTag:40];
    syncLabel.text = ([info.synced intValue] == 0) ? @"N" : @"Y"; */
}

- (void)configureReceivedCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    // Set a background for the cell
    MatchData *info = [receivedMatches objectAtIndex:indexPath.row];
	UILabel *numberLabel = (UILabel *)[cell viewWithTag:10];
	numberLabel.text = [NSString stringWithFormat:@"%d", [info.number intValue]];
//    [self setTeamList:info];
/*
	UILabel *matchTypeLabel = (UILabel *)[cell viewWithTag:15];
    matchTypeLabel.text = [info.matchType substringToIndex:4];
    
	UILabel *red1Label = (UILabel *)[cell viewWithTag:20];
    red1Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:0] intValue]];
    
    UILabel *red2Label = (UILabel *)[cell viewWithTag:30];
    red2Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:1] intValue]];
    
	UILabel *red3Label = (UILabel *)[cell viewWithTag:40];
    red3Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:2] intValue]];
    
	UILabel *blue1Label = (UILabel *)[cell viewWithTag:50];
    blue1Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:3] intValue]];
    
	UILabel *blue2Label = (UILabel *)[cell viewWithTag:60];
    blue2Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:4] intValue]];
    
	UILabel *blue3Label = (UILabel *)[cell viewWithTag:70];
    blue3Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:5] intValue]];
    
	UILabel *redScoreLabel = (UILabel *)[cell viewWithTag:80];
    redScoreLabel.text = [NSString stringWithFormat:@"%d", [info.redScore intValue]];
	UILabel *blueScoreLabel = (UILabel *)[cell viewWithTag:90];
    blueScoreLabel.text = [NSString stringWithFormat:@"%d", [info.blueScore intValue]];    
    */
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
/*    if (tableView == _sendDataTable) {
        UITableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:@"SendData"];
        // Set up the cell...
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
    else { */
        UITableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:@"ReceiveData"];
        [self configureReceivedCell:cell atIndexPath:indexPath];
        return cell;
  //  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
