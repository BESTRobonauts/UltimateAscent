//
//  SyncMatchListViewController.h
//  UltimateAscent
//
//  Created by FRC on 4/4/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@class DataManager;
@class SettingsData;

@interface SyncMatchListViewController : UIViewController <GKPeerPickerControllerDelegate, GKSessionDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, strong) SettingsData *settings;
@property (nonatomic, retain) IBOutlet UIButton *connectButton;
@property (nonatomic, retain) IBOutlet UIButton *disconnectButton;
@property (nonatomic, retain) IBOutlet UILabel *peerLabel;
@property (nonatomic, retain) IBOutlet UILabel *peerName;
@property (nonatomic, retain) IBOutlet UITableView *receiveDataTable;
@property (nonatomic, retain) UIView *headerView;

-(void) setHeaders:(UIView *)header;
-(IBAction) btnConnect:(id) sender;
-(IBAction) btnDisconnect:(id) sender;
- (void)retrieveSettings;

@end
