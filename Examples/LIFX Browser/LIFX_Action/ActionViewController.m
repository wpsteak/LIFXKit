//
//  ActionViewController.m
//  LIFX_Action
//
//  Created by wpsteak on 11/12/14.
//  Copyright (c) 2014 LIFX. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreGraphics/CoreGraphics.h>
#import <LIFXKit/LIFXKit.h>

@interface ActionViewController () <LFXNetworkContextObserver, LFXLightCollectionObserver, LFXLightObserver>

@property (nonatomic) LFXNetworkContext *lifxNetworkContext;
@property (nonatomic) NSArray *lights;

@property(strong,nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ActionViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self == [super initWithCoder:aDecoder]) {
        self.lifxNetworkContext = [LFXClient sharedClient].localNetworkContext;
    }
    
    return self;
}

-(UIColor *)getRGBAFromImageView:(UIImageView *)imageView atPoint:(CGPoint)point
{
    CGImageRef imageRef = [imageView.image CGImage];
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    CGFloat factorX = width / CGRectGetWidth(imageView.frame);
    CGFloat factorY = height / CGRectGetHeight(imageView.frame);
    
//    int xp = point.x * factorX;
//    int yp = point.y * factorY;

    int xp = point.x;
    int yp = point.y;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    
    NSUInteger bytesPerPixel = 4;
    
    NSUInteger bytesPerRow = bytesPerPixel * width;
    
    NSUInteger bitsPerComponent = 8;
    
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpace);
    
    
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    
    int byteIndex = (bytesPerRow * yp) + xp * bytesPerPixel;
    
    CGFloat red   = (rawData[byteIndex]     * 1.0) /255.0;
    
    CGFloat green = (rawData[byteIndex + 1] * 1.0)/255.0 ;
    
    CGFloat blue  = (rawData[byteIndex + 2] * 1.0)/255.0 ;
    
    CGFloat alpha = (rawData[byteIndex + 3] * 1.0) /255.0;
    
    byteIndex += 4;
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
    NSLog(@"width:%i hight:%i Color:%@",width,height,[color description]);
    
    free(rawData);
    
    return color;
    
}

//- (void)getPixelAtPoint:(CGPoint)point
//{
//    UIImage *image1 = _imageView.image; // The image from where you want a pixel data
//    int pixelX = point.x; // The X coordinate of the pixel you want to retrieve
//    int pixelY = point.y; // The Y coordinate of the pixel you want to retrieve
//    
//    uint32_t pixel1; // Where the pixel data is to be stored
//    CGContextRef context1 = CGBitmapContextCreate(&pixel1, 1, 1, 8, 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//    CGContextDrawImage(context1, CGRectMake(-pixelX, -pixelY, CGImageGetWidth(image1.CGImage), CGImageGetHeight(image1.CGImage)), image1.CGImage);
//    CGContextRelease(context1);
//    
//    NSLog(@"%d",pixel1);
//}

- (void)changeLightColorPixelColor:(UIColor *)pixelColor
{
    self.lights = self.lifxNetworkContext.allLightsCollection.lights;
    
    if ([self.lights count] > 0) {
        LFXLight *light = self.lights[0];
        light.powerState = LFXFuzzyPowerStateOn;
        
        
        CGFloat hue;
        CGFloat saturation;
        CGFloat brightness;
        CGFloat alpha;
        BOOL success = [pixelColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        
        LFXHSBKColor *color = [LFXHSBKColor colorWithHue:hue saturation:saturation brightness:brightness];
        [light setColor:color];
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.imageView];
    
//    [self getPixelAtPoint:point];
    UIColor *color = [self getRGBAFromImageView:self.imageView atPoint:point];
    [self changeLightColorPixelColor:color];
}

- (void)initControl
{
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.imageView addGestureRecognizer:tapRecognizer];
    self.imageView.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initControl];
    
    // Get the item[s] we're handling from the extension context.
    
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    BOOL imageFound = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                // This is an image. We'll load it, then place it in our image view.
                __weak UIImageView *imageView = self.imageView;
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    if(image) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [imageView setImage:image];
                        }];
                    }
                }];
                
                imageFound = YES;
                break;
            }
        }
        
        if (imageFound) {
            // We only handle one image, so stop looking for more.
            break;
        }
    }
    
    [self.lifxNetworkContext addNetworkContextObserver:self];
    [self.lifxNetworkContext.allLightsCollection addLightCollectionObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

#pragma mark - LFXNetworkContextObserver

- (void)networkContextDidConnect:(LFXNetworkContext *)networkContext
{
    NSLog(@"Network Context Did Connect");
    //    [self updateTitle];
}

- (void)networkContextDidDisconnect:(LFXNetworkContext *)networkContext
{
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
    NSLog(@"Light Collection: %@ Did Add Light: %@", lightCollection, light);
    [light addLightObserver:self];
}

- (void)lightCollection:(LFXLightCollection *)lightCollection didRemoveLight:(LFXLight *)light
{
    NSLog(@"Light Collection: %@ Did Remove Light: %@", lightCollection, light);
    [light removeLightObserver:self];
}

#pragma mark - LFXLightObserver

- (void)light:(LFXLight *)light didChangeLabel:(NSString *)label
{
    NSLog(@"Light: %@ Did Change Label: %@", light, label);
//    NSUInteger rowIndex = [self.lights indexOfObject:light];
    //    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:TableSectionLights]] withRowAnimation:UITableViewRowAnimationFade];
}


@end
