//
//  AlliancePickerController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlliancePickerDelegate
- (void)allianceSelected:(NSString *)newAlliance;
@end

@interface AlliancePickerController : UITableViewController

@property (nonatomic, retain) NSMutableArray *allianceChoices;
@property (nonatomic, assign) id<AlliancePickerDelegate> delegate;

@end
