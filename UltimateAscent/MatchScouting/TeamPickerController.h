//
//  TeamPickerController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TeamPickerDelegate
- (void)teamSelected:(NSString *)team;
@end

@interface TeamPickerController : UITableViewController

@property (nonatomic, retain) NSMutableArray *teamList;
@property (nonatomic, assign) id<TeamPickerDelegate> delegate;

@end
