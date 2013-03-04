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

- (IBAction)cancelVC:(id)sender;
- (IBAction)showPopup:(id)sender;
- (void)gameTypeSelected:(NSNotification *)notification;

@end
