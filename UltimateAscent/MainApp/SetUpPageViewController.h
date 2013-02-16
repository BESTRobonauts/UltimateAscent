//
//  SetUpPageViewController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetUpPageViewController : UIViewController
@property (nonatomic, retain) IBOutlet UIImageView *mainLogo;
@property (nonatomic, retain) IBOutlet UILabel *pictureCaption;
@property (nonatomic, retain) IBOutlet UIButton *matchSetUpButton;
@property (nonatomic, retain) IBOutlet UIButton *tournamentSetUpButton;
@property (nonatomic, retain) IBOutlet UIButton *importDataButton;
@property (nonatomic, retain) IBOutlet UIButton *exportDataButton;

@end
