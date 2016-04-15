//
//  Request.h
//  HealthVisual
//
//  Created by Adisa Narula on 4/12/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Request : NSObject

-(instancetype) initRequest;
-(void) makeRequest: (NSString *) upc done: (void (^)(NSDictionary *))completion;

@end
