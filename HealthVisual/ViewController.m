//
//  ViewController.m
//  HealthVisual
//
//  Created by Adisa Narula on 4/12/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "Request.h"
#import "Border.h"


@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic, strong) UIView *previewView;
@property(nonatomic, strong) IBOutlet UILabel *label;
@property(nonatomic, strong) Request *r;
@property(nonatomic, strong) Border *border;
@property (nonatomic, assign) int recognize;

//array of allergens
@property(nonatomic, strong) NSMutableDictionary *allergens;
@property(nonatomic, strong) NSMutableArray *picture;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //allocate allergy array
    self.allergens = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"wheat.png", @"Wheat", @"egg.png", @"Egg", @"milk.png", @"Lactose", @"nuts.png", @"Tree Nuts", @"fish.png", @"Shellfish",  @"gluten.png", @"Gluten", nil];
    
    //add background tap
    UITapGestureRecognizer *tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    
    //initilization
    tapBackground.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapBackground];
    self.picture = [[NSMutableArray alloc]init];
    self.recognize = 0;
    
    //start AVCaptureSession
    self.session = [[AVCaptureSession alloc] init];
    
    //set layer for video
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    
    //The view in which to present the layer;
    self.previewView = [[UIView alloc] init];
    
    self.previewView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //places the specified view on top of other siblings.
    [self.view addSubview:self.previewView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_previewView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_previewView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_previewView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_previewView)]];
    
    
    [self.previewView.layer addSublayer:self.previewLayer];
    
    //set label and bring to front
    self.label = [[UILabel alloc] init];
    [self setLabel];
    [self.view addSubview:self.label];
    [self.view bringSubviewToFront:self.label];

    
    // video should be stretched to fill the layer’s bounds.
    self.previewLayer.videoGravity = AVLayerVideoGravityResize;
    
    //get camera device
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *camera = nil; //[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    for(camera in devices) {
        if(camera.position == AVCaptureDevicePositionBack) {
            break;
        }
    }
    
    NSError *error = nil;
    [camera lockForConfiguration:&error];
    if([camera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        [camera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
    if([camera isAutoFocusRangeRestrictionSupported]) {
        [camera setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
    }
    [camera unlockForConfiguration];
    if(error) {
        NSLog(@"Erorr locking for configuration, %@", error);
    }
    
    // Create a AVCaptureInput with the camera device
    AVCaptureDeviceInput *cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
    if (cameraInput == nil) {
        NSLog(@"Error to create camera capture:%@",error);
    }
    // Add the input and output
    [self.session addInput:cameraInput];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:output];
    
    // see what types are supported (do this after adding otherwise the output reports nothing supported
    NSSet *potentialDataTypes = [NSSet setWithArray:@[AVMetadataObjectTypeAztecCode,
                                                      AVMetadataObjectTypeCode128Code,
                                                      AVMetadataObjectTypeCode39Code,
                                                      AVMetadataObjectTypeCode39Mod43Code,
                                                      AVMetadataObjectTypeCode93Code,
                                                      AVMetadataObjectTypeEAN13Code,
                                                      AVMetadataObjectTypeEAN8Code,
                                                      AVMetadataObjectTypePDF417Code,
                                                      //                                                      AVMetadataObjectTypeQRCode,
                                                      AVMetadataObjectTypeUPCECode]];
    
    NSMutableArray *supportedMetaDataTypes = [NSMutableArray array];
    for(NSString *availableMetadataObject in output.availableMetadataObjectTypes) {
        if([potentialDataTypes containsObject:availableMetadataObject]) {
            [supportedMetaDataTypes addObject:availableMetadataObject];
        }
    }
    
    [output setMetadataObjectTypes:supportedMetaDataTypes];
    
    // Get called back everytime something is recognised
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Start the session running
    [self.session startRunning];
}

-(void) setImage: (NSMutableArray *)allergens {
    
    NSInteger x = 15;
    NSInteger y = 30;
    
    for (UIImageView *allergen in allergens) {
        
        [allergen setFrame:CGRectMake(x, y, 80, 80)];
        allergen.alpha = 0.0;
        
        [UIView beginAnimations:@"fade in" context:nil];
        [UIView setAnimationDuration:5.0];
        allergen.alpha = 0.6;
        [UIView commitAnimations];
        
        [[self view] addSubview:allergen];
        x+= 90; //move x axis
    }
}

-(void) removeIcon {
    
    for (UIImageView *allergen in self.picture) {
        [allergen removeFromSuperview];
    }
    
}

-(void)backgroundTapped: (UITapGestureRecognizer *)recognizer
{
//    NSLog(@"Tapped background");
    
    //reset label and start another session
    self.recognize = 0;
    [self removeIcon];
    [self setLabel];
    [self.picture removeAllObjects];
    [self.session startRunning];
}

//Informs the delegate that the capture output object emitted new metadata objects.
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if(metadataObjects.count > 0) {
        //passes work back to the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            AVMetadataMachineReadableCodeObject *recognizedObject = metadataObjects.firstObject;
            if (recognizedObject.stringValue != nil){
                
                [self.label setFont: [UIFont fontWithName:@"Helvetica" size:20]];
                self.label.text = recognizedObject.stringValue;
                self.recognize += 1;
                
            } else {
                [self setLabel];
            }
            //make request object and call request
            
            
            //do the request only once
            if (self.recognize <= 1) {
                
                self.r = [[Request alloc] initRequest];
                [self.r makeRequest:self.label.text done:^(NSDictionary *json) {
                    //data stored in json
                    
                    /*NSMutableArray *contains = [[NSMutableArray alloc]init];*/
                    
                    //print all of the allergies
                    for (NSDictionary *allergies in json[@"product"][@"allergens"]) {
                        
                        //get key and value - make sure image of allergen is there
                        NSInteger value = [allergies[@"allergen_value"] intValue];
                        NSString *key = [NSString stringWithFormat: @"%@", allergies[@"allergen_name"]];
                        
                        if ((value > 1) && (self.allergens[key] != nil)) {
                            [self.picture addObject:[[UIImageView alloc] initWithImage: [UIImage imageNamed:self.allergens[key]]]];
                        }
                    }
                    [self setImage: self.picture];
                }];
            }
        });
        
        /*find another way to keep the camera going*/
        /*[self.session stopRunning];*/
    }
}

-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.previewLayer.frame = self.previewView.bounds;
}

-(void) setLabel{
    //initialize label and draw a rectangle around it as a frame
    //find the label into the frame
    self.label.frame = CGRectMake(0, self.view.bounds.size.height-80, self.view.bounds.size.width, 80);
    self.label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    self.label.textColor = [UIColor whiteColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.label setFont: [UIFont fontWithName:@"Helvetica" size:17]];
    self.label.text = @"Scan a food product's code to display valuable nutritional and diet information";
    
    self.label.lineBreakMode = NSLineBreakByWordWrapping;
    self.label.numberOfLines = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
