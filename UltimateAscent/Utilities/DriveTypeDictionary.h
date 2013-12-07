//
//  DriveTypeDictionary.h
//  UltimateAscent
//
//  Created by FRC on 10/10/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriveTypeDictionary : NSObject
-(NSString *)getDriveTypeString:(id) key;
-(id)getDriveTypeEnum:(NSString *) value;
-(NSArray *)getDriveTypes;
@end
