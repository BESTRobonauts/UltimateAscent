//
//  SplashPageViewController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MainScoutingPageViewController.h"

@interface SplashPageViewController : UIViewController //<MainScoutingPageDelegate>
    @property (nonatomic, retain) IBOutlet UIImageView *mainLogo;
    @property (nonatomic, retain) IBOutlet UILabel *pictureCaption;
    @property (nonatomic, retain) IBOutlet UIButton *teamScoutingButton;
    @property (nonatomic, retain) IBOutlet UIButton *matchSetUpButton;
    @property (nonatomic, retain) IBOutlet UIButton *matchScoutingButton;
    @property (nonatomic, retain) IBOutlet UIButton *matchAnalysisButton;
    @property (nonatomic, retain) IBOutlet UIImageView *splashPicture;
@end
