//
//  Graph.h
//  resize_test
//
//  Created by Inbar Fried on 11/9/14.
//  Copyright (c) 2014 Team4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Graph : UIView

- (void) initializeNumberFor: (NSString*) dataType withColor: (UIColor*) color withUnits: (NSString *) units;
- (void) initializeColor: (UIColor *) color;

@property (strong, nonatomic) UILabel  *number;
@property (strong, nonatomic) UILabel  *units;
@property (strong, nonatomic) NSString *dataType;

@property (nonatomic, strong) NSMutableArray *graphXData;
@property (nonatomic, strong) NSMutableArray *graphYData;

- (void) resizeNumberUnits;

@end
