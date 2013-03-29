//
//  MatchAnalysisViewController.h
//  UltimateAscent
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;

@interface MatchAnalysisViewController : UIViewController
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, retain) IBOutlet UIImageView *mainLogo;
@property (nonatomic, retain) IBOutlet UILabel *pictureCaption;
@property (nonatomic, retain) IBOutlet UIImageView *matchPicture;
@property (nonatomic, retain) IBOutlet UIButton *masonPageButton;
@property (nonatomic, retain) IBOutlet UIButton *rossPageButton;
@property (nonatomic, retain) IBOutlet UIImageView *splashPicture;

@end
