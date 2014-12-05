//
//  TheData.h
//  resize_test
//
//  Created by Inbar Fried on 11/9/14.
//  Copyright (c) 2014 Team4. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TheData : NSObject

    - (NSArray *) getDataX;
    - (NSArray *) getDataY;
    - (id) initWithFile: (NSString*) file;

@end
