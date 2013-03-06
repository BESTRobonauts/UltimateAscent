//
//  AddMatchViewController.h
//  UltimateAscent
//
//  Created by FRC on 2/25/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MatchTypePickerController;
@class MatchTypeDictionary;
@class MatchData;

@protocol AddMatchDelegate
- (void)matchAdded:(NSMutableArray *)newMatch;
@end

typedef enum {
    kMatchTypePractice,
    kMatchTypeSeeding,
    kMatchTypeElimination,
    kMatchTypeTesting,
    kMatchTypeOther
} GameType;

@interface AddMatchViewController : UIViewController <UIPopoverControllerDelegate, UITableViewDelegate, UITextFieldDelegate> {
    
    GameType gameType;
}

@property (nonatomic, strong) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIButton *matchTypeButton;
@property (nonatomic, strong) IBOutlet UITextField *matchNumber;
@property (nonatomic, strong) IBOutlet UITextField *red1;
@property (nonatomic, strong) IBOutlet UITextField *red2;
@property (nonatomic, strong) IBOutlet UITextField *red3;
@property (nonatomic, strong) IBOutlet UITextField *blue1;
@property (nonatomic, strong) IBOutlet UITextField *blue2;
@property (nonatomic, strong) IBOutlet UITextField *blue3;
@property (nonatomic, assign) id<AddMatchDelegate> delegate;

- (IBAction)cancelVC:(id)sender;
- (IBAction)addAction:(id)sender;
- (IBAction)showPopup:(id)sender;
- (void)gameTypeSelected:(NSNotification *)notification;

@end
