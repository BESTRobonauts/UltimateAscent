//
//  LucienTableViewController.h
//  UltimateAscent
//
//  Created by FRC on 7/13/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LucienNumberObject;

@interface LucienTableViewController : UITableViewController
@property (weak, nonatomic) NSMutableArray *lucienNumbers;
@property (nonatomic, strong) UIView *headerView;

@end
