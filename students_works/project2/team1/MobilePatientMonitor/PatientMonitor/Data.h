//
//  Data.h
//  PatientMonitor
//
//  Created by Alex Henry on 11/13/14.
//  Copyright (c) 2014 Alexander Henry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Data : NSObject

- (NSArray *) getDataX;
- (NSArray *) getDataY;
- (id)initWithFile:(NSString *) fileName;

@end
