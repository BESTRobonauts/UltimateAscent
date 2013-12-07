//
//  Settings.h
//  UltimateAscent
//
//  Created by FRC on 12/5/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject
@property (nonatomic, strong) NSString *adminCode;
@property (nonatomic, strong) NSString *alliance;
@property (nonatomic, strong) NSNumber *master;
@property (nonatomic, strong) NSString *mode;
@property (nonatomic, strong) NSString *overrideCode;
@property (nonatomic, strong) NSString *tournament;

@end
