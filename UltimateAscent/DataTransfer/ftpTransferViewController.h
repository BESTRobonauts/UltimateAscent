//
//  ftpTransferViewController.h
//  UltimateAscent
//
//  Created by FRC on 4/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;
@class SettingsData;

@interface ftpTransferViewController : UIViewController <UITextFieldDelegate, NSStreamDelegate>
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, strong) SettingsData *settings;
@property (weak, nonatomic) IBOutlet UIButton *pushDataButton;
@property (weak, nonatomic) IBOutlet UIButton *getDataButton;
@property (weak, nonatomic) IBOutlet UIButton *sendDatabaseButton;
@property (weak, nonatomic) IBOutlet UIButton *picturesButton;
@property (weak, nonatomic) IBOutlet UITextField *urlText;
@property (weak, nonatomic) IBOutlet UITextField *usernameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (nonatomic, strong, readwrite) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong, readwrite) IBOutlet UIButton *cancelButton;

- (IBAction)sendAction:(UIView *)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)pushData:(id)sender;
- (IBAction)getData:(id)sender;
- (IBAction)pushDatabase:(id)sender;
- (IBAction)pictures:(id)sender;
-(void)timerStart;
- (void)timerFired;
-(void)timerEnd;

- (void)retrieveSettings;
- (NSString *)applicationDocumentsDirectory;
- (NSString *)applicationLibraryDirectory;

@end
