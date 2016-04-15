//
//  Request.m
//  HealthVisual
//
//  Created by Adisa Narula on 4/12/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "Request.h"

@interface Request()

@property (weak, nonatomic) NSString *api_key;
@property (weak, nonatomic) NSString *url;
@property (weak, nonatomic) NSString *session_id;
@property (weak, nonatomic) NSString *base_url;
@property NSInteger capacity;

@end

@implementation Request

-(instancetype) initRequest
{
    self = [super init];
    if (self) //init
    {
        self.api_key = [NSString stringWithFormat:@"wrsbhbkuabkgpueshggym5sb"];
        self.session_id = [NSString stringWithFormat: @"bc3a46ef-aa6c-48bd-85c3-d1ec89f70fd4"];
        self.base_url = [NSString stringWithFormat: @"http://api.foodessentials.com/productscore?"];
    }
    
    return self;
}

/*
- (void)sendData:(NSDictionary *)sendDict completion:(void (^)(NSDictionary *))completion {
    
    // the stuff you're already doing
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        // the stuff you're already doing
                                                        // now tell the caller that you're done
                                                        completion(jsonArray);
                                                    }];
}*/


-(void) sendHTTPGet: (void (^)(NSDictionary *))completion
{
    //configure session
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: (id)self delegateQueue: [NSOperationQueue mainQueue]];
    NSURL * url = [NSURL URLWithString:self.url];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithURL:url
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        if(error == nil)
                                                        {
                                                            //NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                            //NSLog(@"data = %@", text);
                                                            
                                                            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                            
                                                            //did not return json dictionary
                                                            if(!json) {
                                                                NSLog(@"error returning dictionary");
                                                            } else {
                                                                completion(json); //let the caller know that the function completed
                                                            }
                                                            
                                                        }
                                                    }];
    [dataTask resume];
    
}

//wrapper for request method 
-(void) makeRequest: (NSString *) upc done: (void (^)(NSDictionary *))completion
{
    NSMutableString *u = [[NSMutableString alloc]init];
    
    //make URL
    if ([upc length] > 12) {
        if ([upc characterAtIndex:0] == '0') {
            [u appendString:[upc substringFromIndex:1]]; //strip out the first character
        }
    } else {
        [u appendString:upc];
    }
    
    NSArray *arr = [NSArray arrayWithObjects:self.base_url, @"u=", u, @"&sid=", self.session_id, @"&f=json&api_key=", self.api_key, nil];
    
    self.url= [arr componentsJoinedByString:@""];
    //send http get
    
    [self sendHTTPGet:^(NSDictionary *json) {
        completion(json); //pass back
    }];
}

@end
