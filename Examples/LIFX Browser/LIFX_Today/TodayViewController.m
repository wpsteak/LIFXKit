//
//  TodayViewController.m
//  LIFX_Today
//
//  Created by wpsteak on 11/6/14.
//  Copyright (c) 2014 LIFX. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <LIFXKit/LIFXKit.h>

@interface TodayViewController () <NCWidgetProviding, LFXNetworkContextObserver, LFXLightCollectionObserver, LFXLightObserver>

@property (nonatomic) LFXNetworkContext *lifxNetworkContext;
@property (nonatomic) NSArray *lights;
@property (nonatomic) NSArray *taggedLightCollections;

@property (nonatomic, strong)UIView *test;

@end

@implementation TodayViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self == [super initWithCoder:aDecoder]) {
    self.lifxNetworkContext = [LFXClient sharedClient].localNetworkContext;
    }
    
    return self;
}

- (IBAction)test:(id)sender
{
    [UIView animateWithDuration:2.0f animations:^{
        self.test.frame = CGRectMake(0, 0, 20, 20);
    }];
    
    [self updateLights];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    NSLog(@"viewDidLoad");
    self.preferredContentSize = CGSizeMake(320, 600);
    
    
    self.test = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    _test.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:_test atIndex:0];
    
    [self.lifxNetworkContext addNetworkContextObserver:self];
    [self.lifxNetworkContext.allLightsCollection addLightCollectionObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler
{
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    
    NSLog(@"widgetPerformUpdateWithCompletionHandler");
    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    NSLog(@"widgetMarginInsetsForProposedMarginInsets");
    return UIEdgeInsetsZero;
}


- (void)updateLights
{
    self.lights = self.lifxNetworkContext.allLightsCollection.lights;
    
    
    if ([self.lights count] > 0) {
        LFXLight *light = self.lights[0];
        light.powerState = LFXFuzzyPowerStateOn;
        
//        LFXHSBKColor *color = [LFXHSBKColor colorWithHue:100.0 saturation:0.5 brightness:0.5];
//        light.color = color;
        LFXHSBKColor *color = [LFXHSBKColor colorWithHue:arc4random()%360 saturation:1.0 brightness:1.0];
        [light setColor:color];
    }
}

#pragma mark - LFXNetworkContextObserver

- (void)networkContextDidConnect:(LFXNetworkContext *)networkContext
{
    self.test.frame = CGRectMake(0, 0, 320, 320);
    self.test.backgroundColor = [UIColor yellowColor];
    NSLog(@"Network Context Did Connect");
//    [self updateTitle];
}

- (void)networkContextDidDisconnect:(LFXNetworkContext *)networkContext
{
    self.test.frame = CGRectMake(0, 0, 320, 320);
    self.test.backgroundColor = [UIColor grayColor];
    NSLog(@"Network Context Did Disconnect");
//    [self updateTitle];
}

- (void)networkContext:(LFXNetworkContext *)networkContext didAddTaggedLightCollection:(LFXTaggedLightCollection *)collection
{
    NSLog(@"Network Context Did Add Tagged Light Collection: %@", collection.tag);
    [collection addLightCollectionObserver:self];
//    [self updateTags];
}

- (void)networkContext:(LFXNetworkContext *)networkContext didRemoveTaggedLightCollection:(LFXTaggedLightCollection *)collection
{
    NSLog(@"Network Context Did Remove Tagged Light Collection: %@", collection.tag);
    [collection removeLightCollectionObserver:self];
//    [self updateTags];
}


#pragma mark - LFXLightCollectionObserver

- (void)lightCollection:(LFXLightCollection *)lightCollection didAddLight:(LFXLight *)light
{
    self.test.frame = CGRectMake(0, 0, 320, 320);
    self.test.backgroundColor = [UIColor greenColor];
    NSLog(@"Light Collection: %@ Did Add Light: %@", lightCollection, light);
    [light addLightObserver:self];
    [self updateLights];
}

- (void)lightCollection:(LFXLightCollection *)lightCollection didRemoveLight:(LFXLight *)light
{
    self.test.frame = CGRectMake(0, 0, 320, 320);
    self.test.backgroundColor = [UIColor redColor];
    NSLog(@"Light Collection: %@ Did Remove Light: %@", lightCollection, light);
    [light removeLightObserver:self];
    [self updateLights];
}

#pragma mark - LFXLightObserver

- (void)light:(LFXLight *)light didChangeLabel:(NSString *)label
{
    NSLog(@"Light: %@ Did Change Label: %@", light, label);
    NSUInteger rowIndex = [self.lights indexOfObject:light];
//    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:TableSectionLights]] withRowAnimation:UITableViewRowAnimationFade];
}


@end
