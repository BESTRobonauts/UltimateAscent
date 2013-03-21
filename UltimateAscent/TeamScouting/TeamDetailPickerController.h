//
//  TeamDetailPickerController.h
//  UltimateAscent
//
//  Created by FRC on 3/20/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TeamDetailPickerDelegate
- (void)detailSelected:(NSString *)newDetail;
@end

@interface TeamDetailPickerController : UITableViewController

@property (nonatomic, weak) NSMutableArray *detailChoices;
@property (nonatomic, assign) id<TeamDetailPickerDelegate> delegate;

@end
