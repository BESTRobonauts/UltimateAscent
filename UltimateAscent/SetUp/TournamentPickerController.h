//
//  TournamentPickerController.h
//  UltimateAscent
//
//  Created by FRC on 2/28/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TournamentPickerDelegate
- (void)tournamentSelected:(NSString *)newTournament;
@end

@interface TournamentPickerController : UITableViewController
@property (nonatomic, retain) NSMutableArray *tournamentChoices;
@property (nonatomic, assign) id<TournamentPickerDelegate> delegate;

@end
