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
    NSLog(@"initWithCoder:");
    if (self == [super initWithCoder:aDecoder]) {
        self.lifxNetworkContext = [LFXClient sharedClient].localNetworkContext;
    }
    
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

- (void)changeLightColorWithLFXHSBKColor:(LFXHSBKColor *)color
{
    self.lights = self.lifxNetworkContext.allLightsCollection.lights;
    if ([self.lights count] > 0) {
        LFXLight *light = self.lights[0];
        light.powerState = LFXFuzzyPowerStateOn;
        [light setColor:color];
    }
}

- (IBAction)whitColor:(id)sender
{
    LFXHSBKColor *color = [LFXHSBKColor colorWithHue:0 saturation:0.0 brightness:1.0 kelvin:4000];
    [self changeLightColorWithLFXHSBKColor:color];
}

- (IBAction)yellowColor:(id)sender
{
    LFXHSBKColor *color = [LFXHSBKColor colorWithHue:0 saturation:0.0 brightness:1.0 kelvin:2000];
    [self changeLightColorWithLFXHSBKColor:color];
}

- (IBAction)randomColor:(id)sender
{
    [self updateLights];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"viewDidLoad");
    
    self.preferredContentSize = CGSizeMake(320, 160);
    
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
    LFXHSBKColor *color = [LFXHSBKColor colorWithHue:arc4random()%360 saturation:1.0 brightness:1.0];
    [self changeLightColorWithLFXHSBKColor:color];
}

#pragma mark - LFXNetworkContextObserver

- (void)networkContextDidConnect:(LFXNetworkContext *)networkContext
{
    NSLog(@"Network Context Did Connect");
}

- (void)networkContextDidDisconnect:(LFXNetworkContext *)networkContext
{
    NSLog(@"Network Context Did Disconnect");
//    [self updateTitle];
}

//- (void)networkContext:(LFXNetworkContext *)networkContext didAddTaggedLightCollection:(LFXTaggedLightCollection *)collection
//{
//    NSLog(@"Network Context Did Add Tagged Light Collection: %@", collection.tag);
//    [collection addLightCollectionObserver:self];
////    [self updateTags];
//}
//
//- (void)networkContext:(LFXNetworkContext *)networkContext didRemoveTaggedLightCollection:(LFXTaggedLightCollection *)collection
//{
//    NSLog(@"Network Context Did Remove Tagged Light Collection: %@", collection.tag);
//    [collection removeLightCollectionObserver:self];
////    [self updateTags];
//}

#pragma mark - LFXLightCollectionObserver

- (void)lightCollection:(LFXLightCollection *)lightCollection didAddLight:(LFXLight *)light
{
    NSLog(@"Light Collection: %@ Did Add Light: %@", lightCollection, light);
    [light addLightObserver:self];
    [self updateLights];
}

- (void)lightCollection:(LFXLightCollection *)lightCollection didRemoveLight:(LFXLight *)light
{
    NSLog(@"Light Collection: %@ Did Remove Light: %@", lightCollection, light);
    [light removeLightObserver:self];
    [self updateLights];
}

#pragma mark - LFXLightObserver

- (void)light:(LFXLight *)light didChangeLabel:(NSString *)label
{
    NSLog(@"Light: %@ Did Change Label: %@", light, label);
}


@end
