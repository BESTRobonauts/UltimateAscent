//
//  SyncViewController.h
//  UltimateAscent
//
//  Created by FRC on 3/13/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "AlertPromptViewController.h"

@class DataManager;
@class MatchResultsObject;
@class TeamScore;

@interface SyncResultsViewController : UIViewController <GKPeerPickerControllerDelegate, GKSessionDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) BlueToothType blueToothType;
@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, retain) IBOutlet UITableView *sendDataTable;
@property (nonatomic, retain) IBOutlet UITableView *receiveDataTable;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UIView *headerView2;
@property (nonatomic, retain) IBOutlet UIButton *connectButton;
@property (nonatomic, retain) IBOutlet UIButton *disconnectButton;
@property (nonatomic, retain) IBOutlet UILabel *peerLabel;
@property (nonatomic, retain) IBOutlet UILabel *peerName;
@property (nonatomic, retain) AlertPromptViewController *alertPrompt;
@property (nonatomic, retain) UIPopoverController *alertPromptPopover;

-(IBAction) btnConnect:(id) sender;
-(IBAction) btnDisconnect:(id) sender;
-(BOOL)addMatchScore:(MatchResultsObject *) xferData;
-(void)unpackXferData:(MatchResultsObject *)xferData forScore:(TeamScore *)score;
- (void)retrieveSettings;

@end
