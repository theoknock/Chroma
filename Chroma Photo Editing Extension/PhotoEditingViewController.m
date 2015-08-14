//
//  PhotoEditingViewController.m
//  Chroma Photo Editing Extension
//
//  Created by James Alan Bush on 6/23/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import "PhotoEditingViewController.h"
#import "GlobalContext.h"
#import "AppSingleton.h"
#import "GlobalCIImage.h"
#import "View.h"

#import "AAPLAVReaderWriter.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

#import <UIKit/UIKit.h>

@import Foundation;

#import "UIImage-vImage.h"
#import "UIImage-Utils.h"


NSString *const kFilterInfoFilterNameKey = @"filterName";
NSString *const kFilterInfoDisplayNameKey = @"displayName";
NSString *const kFilterInfoPreviewImageKey = @"previewImage";
//vImage_Buffer buffer;
//vImage_Buffer buffer_v;
float inputMin;
float gammaLevels;
float inputMax;
float outputMin;
float outputMax;

NSArray *_pickerData;
GlobalContext *sharedContext;
GlobalCIImage *sharedCIImage;
CGImageRef cgImage;
CGImageRef cgImage2;

@interface PhotoEditingViewController () <PHContentEditingController, UICollectionViewDataSource, UICollectionViewDelegate, AAPLAVReaderWriterAdjustDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet View *myView;
@property (nonatomic, strong) NSTimer *viewInactiveTimer;
@property (strong, nonatomic) IBOutlet UIImageView *histogramView;
@property (strong, nonatomic) IBOutlet UIImageView *originalHistogramView;
@property (strong, nonatomic) IBOutlet UISwitch *equalizeHistogramSwitch;
- (IBAction)equalizeHistogram:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UISwitch *stretchContrastSwitch;
- (IBAction)stretchContrast:(UISwitch *)sender;



@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIImageView *filterPreviewView;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

@property (strong, nonatomic) IBOutlet UIStepper *skimStepper;
- (IBAction)skim:(UIStepper *)sender;

@property (strong, nonatomic) IBOutlet UIStepper *brightnessStepper;
- (IBAction)adjustBrightness:(UIStepper *)sender;
@property (strong, nonatomic) IBOutlet UIStepper *saturationStepper;
- (IBAction)adjustSaturation:(UIStepper *)sender;
@property (strong, nonatomic) IBOutlet UIStepper *contrastStepper;
- (IBAction)adjustContrast:(UIStepper *)sender;
@property (strong, nonatomic) IBOutlet UIStepper *exposureStepper;
- (IBAction)adjustEV:(UIStepper *)sender;
@property (strong, nonatomic) IBOutlet UIStepper *gammaStepper;
- (IBAction)adjustGamma:(UIStepper *)sender;
@property (strong, nonatomic) IBOutlet UIView *colorControlView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *colorSegmentedControl;
- (IBAction)controlColors:(UISegmentedControl *)sender;
@property (strong, nonatomic) IBOutlet UILabel *brightnessValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *saturationValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *contrastValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *gammaValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *exposureValueLabel;
@property (strong, nonatomic) IBOutlet UISwitch *sRGBSwitch;
- (IBAction)sRGB:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UIButton *resetColorControlsButton;
- (IBAction)resetColorControls:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIStepper *erodeIterator;
- (IBAction)iterateErosion:(UIStepper *)sender;

@property (strong, nonatomic) IBOutlet UIStepper *dilateIterator;
- (IBAction)iterateDilation:(UIStepper *)sender;

@property (strong, nonatomic) IBOutlet UISwitch *equalizeSwitch;
- (IBAction)equalize:(UISwitch *)sender;

@property (strong, nonatomic) IBOutlet UISwitch *stretchSwitch;
- (IBAction)stretch:(UISwitch *)sender;

// Morphology View and Controls
@property (strong, nonatomic) IBOutlet UIView *morphologyView;

@property (strong, nonatomic) IBOutlet UISwitch *morphologySwitch;
- (IBAction)activateMorphology:(UISwitch *)sender;

@property (strong, nonatomic) IBOutlet UISegmentedControl *openCloseSegmentedControl;
- (IBAction)toggleOpenClose:(UISegmentedControl *)sender;

@property (strong, nonatomic) IBOutlet UILabel *dilateIterationsLabel;
@property (strong, nonatomic) IBOutlet UILabel *erodeIterationsLabel;

@property (strong, nonatomic) IBOutlet UISegmentedControl *erodeShapeSegmentedControl;
- (IBAction)chooseErodeShape:(UISegmentedControl *)sender;

@property (strong, nonatomic) IBOutlet UISegmentedControl *dilateShapeSegmentedControl;
- (IBAction)chooseDilateShape:(UISegmentedControl *)sender;

@property (strong, nonatomic) IBOutlet UIStepper *radiusErodeStepper;
- (IBAction)setErodeRadius:(UIStepper *)sender;
@property (strong, nonatomic) IBOutlet UILabel *erodeRadiusLabel;

@property (strong, nonatomic) IBOutlet UIStepper *radiusDilateStepper;
- (IBAction)setDilateRadius:(UIStepper *)sender;
@property (strong, nonatomic) IBOutlet UILabel *dilateRadiusLabel;

@property (strong, nonatomic) IBOutlet UISegmentedControl *morphologyBlendModeSegmentedControl;
- (IBAction)setMorphologyBlendMode:(UISegmentedControl *)sender;

@property (strong, nonatomic) IBOutlet UIView *blendModeView;
@property (strong, nonatomic) IBOutlet UISwitch *subtractSwitch;
- (IBAction)subtract:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UISwitch *differenceSwitch;
- (IBAction)difference:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UISwitch *overlaySwitch;
- (IBAction)overlay:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UISwitch *invertSwitch;
- (IBAction)invert:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UISwitch *multiplySwitch;
- (IBAction)multiply:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UISwitch *screenSwitch;
- (IBAction)screen:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UISwitch *additionSwitch;
- (IBAction)addition:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UISwitch *originalBackgroundSwitch;
- (IBAction)blendOriginal:(UISwitch *)sender;


// ANDWP view
@property (strong, nonatomic) IBOutlet UIPickerView *neighborhoodOperatorPickerView;
@property (strong, nonatomic) IBOutlet UIView *directionalMeanView;
@property (strong, nonatomic) IBOutlet UILabel *northLabel;
@property (strong, nonatomic) IBOutlet UIStepper *northStepper;
@property (strong, nonatomic) IBOutlet UILabel *eastLabel;
@property (strong, nonatomic) IBOutlet UIStepper *eastStepper;
@property (strong, nonatomic) IBOutlet UILabel *southLabel;
@property (strong, nonatomic) IBOutlet UIStepper *southStepper;
@property (strong, nonatomic) IBOutlet UILabel *westLabel;
@property (strong, nonatomic) IBOutlet UIStepper *westStepper;
- (IBAction)setNorthRadius:(UIStepper *)sender;
- (IBAction)setEastRadius:(UIStepper *)sender;
- (IBAction)setSouthRadius:(UIStepper *)sender;
- (IBAction)setWestRadius:(UIStepper *)sender;
@property (strong, nonatomic) IBOutlet UIStepper *andwpIterationsStepper;
- (IBAction)iterateANDWP:(UIStepper *)sender;
@property (strong, nonatomic) IBOutlet UILabel *andwpIterationsLabel;

// Levels view
@property (strong, nonatomic) IBOutlet UIView *levelsView;
@property (strong, nonatomic) IBOutlet UILabel *inputMinLabel;
@property (strong, nonatomic) IBOutlet UISlider *inputMinSlider;
- (IBAction)setInputMin:(UISlider *)sender;

@property (strong, nonatomic) IBOutlet UILabel *gammaLabel;
@property (strong, nonatomic) IBOutlet UISlider *gammaSlider;
- (IBAction)setGamma:(UISlider *)sender;

@property (strong, nonatomic) IBOutlet UILabel *inputMaxLabel;
@property (strong, nonatomic) IBOutlet UISlider *inputMaxSlider;
- (IBAction)setInputMax:(UISlider *)sender;

@property (strong, nonatomic) IBOutlet UILabel *outputMinLabel;
@property (strong, nonatomic) IBOutlet UISlider *outputMinSlider;
- (IBAction)setOutputMin:(UISlider *)sender;

@property (strong, nonatomic) IBOutlet UILabel *outputMaxLabel;
@property (strong, nonatomic) IBOutlet UISlider *outputMaxSlider;
- (IBAction)setOutputMax:(UISlider *)sender;
@property (strong, nonatomic) IBOutlet UIButton *resetLevelsButton;
- (IBAction)resetLevels:(UIButton *)sender;

// Edge view
@property (strong, nonatomic) IBOutlet UIView *edgeView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *compassGradientSegmentedControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *unitsSegmentedControl;
- (IBAction)setUnits:(UISegmentedControl *)sender;

- (IBAction)setCompassGradient:(UISegmentedControl *)sender;
@property (strong, nonatomic) IBOutlet UITextField *h1TextField;
- (IBAction)changeH1:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *h2TextField;
- (IBAction)changeH2:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *h3TextField;
- (IBAction)changeH3:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *h4TextField;
- (IBAction)changeH4:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *h5TextField;
- (IBAction)changeH5:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *h6TextField;
- (IBAction)changeH6:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *h7TextField;
- (IBAction)changeH7:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *h8TextField;
- (IBAction)changeH8:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *h9TextField;
- (IBAction)changeH9:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UISwitch *edgeSwitch;
- (IBAction)toggleEdge:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UITextField *v1TextField;
- (IBAction)changeV1:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *v2TextField;
- (IBAction)changeV2:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *v3TextField;
- (IBAction)changeV3:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *v4TextField;
- (IBAction)changeV4:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *v5TextField;
- (IBAction)changeV5:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *v6TextField;
- (IBAction)changeV6:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *v7TextField;
- (IBAction)changeV7:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *v8TextField;
- (IBAction)changeV8:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *v9TextField;
- (IBAction)changeV9:(UITextField *)sender;

@property (strong, nonatomic) IBOutlet UIView *ToneView;
@property (strong, nonatomic) IBOutlet UISwitch *toneCurveSwitch;
@property (strong, nonatomic) IBOutlet UIButton *ToneCurveResetButton;
- (IBAction)resetToneCurve:(UIButton *)sender;

- (IBAction)curveTones:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UILabel *X1Label;
@property (strong, nonatomic) IBOutlet UIStepper *X1;
- (IBAction)X1set:(UIStepper *)sender;

@property (strong, nonatomic) IBOutlet UILabel *Y1Label;
@property (strong, nonatomic) IBOutlet UIStepper *Y1;
- (IBAction)Y1set:(UIStepper *)sender;

@property (strong, nonatomic) IBOutlet UILabel *X2Label;
@property (strong, nonatomic) IBOutlet UIStepper *X2;
- (IBAction)X2set:(UIStepper *)sender;

@property (strong, nonatomic) IBOutlet UILabel *Y2Label;
@property (strong, nonatomic) IBOutlet UIStepper *Y2;
- (IBAction)Y2set:(UIStepper *)sender;

@property (strong, nonatomic) IBOutlet UILabel *X3Label;
@property (strong, nonatomic) IBOutlet UIStepper *X3;
- (IBAction)X3set:(UIStepper *)sender;

@property (strong, nonatomic) IBOutlet UILabel *Y3Label;
@property (strong, nonatomic) IBOutlet UIStepper *Y3;
- (IBAction)Y3set:(UIStepper *)sender;

@property (strong, nonatomic) IBOutlet UILabel *X4Label;
@property (strong, nonatomic) IBOutlet UIStepper *X4;
- (IBAction)X4set:(UIStepper *)sender;

@property (strong, nonatomic) IBOutlet UILabel *Y4Label;
@property (strong, nonatomic) IBOutlet UIStepper *Y4;
- (IBAction)Y4set:(UIStepper *)sender;

@property (strong, nonatomic) IBOutlet UILabel *X5Label;
@property (strong, nonatomic) IBOutlet UIStepper *X5;
- (IBAction)X5set:(UIStepper *)sender;

@property (strong, nonatomic) IBOutlet UILabel *Y5Label;
@property (strong, nonatomic) IBOutlet UIStepper *Y5;
- (IBAction)Y5set:(UIStepper *)sender;

// Contrast adjustment steppers and labels
@property (strong, nonatomic) IBOutlet UILabel *minValueContrastLabel;

@property (strong, nonatomic) IBOutlet UILabel *maxValueContrastLabel;
@property (strong, nonatomic) IBOutlet UISlider *upperCurveSlider;
- (IBAction)setUpperCurve:(UISlider *)sender;
@property (strong, nonatomic) IBOutlet UISlider *lowerCurveSlider;
- (IBAction)setLowerCurve:(UISlider *)sender;
@property (strong, nonatomic) IBOutlet UIImageView *UpperCurveView;
@property (strong, nonatomic) IBOutlet UIImageView *AverageCurveView;
@property (strong, nonatomic) IBOutlet UIImageView *LowerCurveView;


// Gaussian blur slider
@property (strong, nonatomic) IBOutlet UISlider *gaussianBlurSlider;

- (IBAction)blur:(UISlider *)sender;
@property (nonatomic, strong) NSArray *availableFilterInfos;
@property (nonatomic, strong) NSString *selectedFilterName;
@property (nonatomic, strong) NSString *initialFilterName;

@property (nonatomic, strong) UIImage *inputImage;

@property (nonatomic, strong) CIFilter *ciFilter;
//@property (nonatomic, strong) CIContext *ciContext;
//@property (nonatomic, strong) GlobalContext *sharedContext;


@property (nonatomic, strong) PHContentEditingInput *contentEditingInput;

@end



@implementation PhotoEditingViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Hide views/disable controls
    self.colorControlView.hidden = YES;
    self.morphologyView.hidden = YES;
    self.blendModeView.hidden = YES;
    self.directionalMeanView.hidden = YES;
    self.levelsView.hidden = YES;
    self.edgeView.hidden = YES;
    self.ToneView.hidden = YES;
    [self.differenceSwitch setOn:FALSE];
    [self.subtractSwitch setOn:FALSE];
    [self.overlaySwitch setOn:FALSE];
    [self.multiplySwitch setOn:FALSE];
    [self.additionSwitch setOn:FALSE];
    [self.screenSwitch setOn:FALSE];
    [self.equalizeSwitch setOn:FALSE];
    [self.sRGBSwitch setOn:FALSE];
    [self.stretchSwitch setOn:FALSE];
    [self.invertSwitch setOn:FALSE];
    [self.morphologySwitch setOn:FALSE];
    [self.edgeSwitch setOn:FALSE];
    [self.toneCurveSwitch setOn:FALSE];
    [self.originalBackgroundSwitch setOn:FALSE];
    _pickerData = @[@"Off", @"Mean", @"Max-Min", @"Median", @"Mode", @"Hybrid Median", @"Median Absolute Deviation", @"Variance", @"Chroma Unsharp" ];
    self.neighborhoodOperatorPickerView.dataSource = self;
    self.neighborhoodOperatorPickerView.delegate = self;
    
    self.h1TextField.text = [NSString stringWithFormat:@"%2.0f", -1.0];
    self.h1TextField.delegate = self;
    self.h2TextField.text = [NSString stringWithFormat:@"%2.0f", -1.0];
    self.h2TextField.delegate = self;
    self.h3TextField.text = [NSString stringWithFormat:@"%2.0f", -1.0];
    self.h3TextField.delegate = self;
    self.h4TextField.text = [NSString stringWithFormat:@"%2.0f", 0.0];
    self.h4TextField.delegate = self;
    self.h5TextField.text = [NSString stringWithFormat:@"%2.0f", 0.0];
    self.h5TextField.delegate = self;
    self.h6TextField.text = [NSString stringWithFormat:@"%2.0f", 0.0];
    self.h6TextField.delegate = self;
    self.h7TextField.text = [NSString stringWithFormat:@"%2.0f", 1.0];
    self.h7TextField.delegate = self;
    self.h8TextField.text = [NSString stringWithFormat:@"%2.0f", 1.0];
    self.h8TextField.delegate = self;
    self.h9TextField.text = [NSString stringWithFormat:@"%2.0f", 1.0];
    self.h9TextField.delegate = self;
    self.v1TextField.text = [NSString stringWithFormat:@"%2.0f", -1.0];
    self.v1TextField.delegate = self;
    self.v2TextField.text = [NSString stringWithFormat:@"%2.0f", 0.0];
    self.v2TextField.delegate = self;
    self.v3TextField.text = [NSString stringWithFormat:@"%2.0f", 1.0];
    self.v3TextField.delegate = self;
    self.v4TextField.text = [NSString stringWithFormat:@"%2.0f", -1.0];
    self.v4TextField.delegate = self;
    self.v5TextField.text = [NSString stringWithFormat:@"%2.0f", 0.0];
    self.v5TextField.delegate = self;
    self.v6TextField.text = [NSString stringWithFormat:@"%2.0f", 1.0];
    self.v6TextField.delegate = self;
    self.v7TextField.text = [NSString stringWithFormat:@"%2.0f", -1.0];
    self.v7TextField.delegate = self;
    self.v8TextField.text = [NSString stringWithFormat:@"%2.0f", 0.0];
    self.v8TextField.delegate = self;
    self.v9TextField.text = [NSString stringWithFormat:@"%2.0f", 1.0];
    self.v9TextField.delegate = self;






    
    sharedContext = [GlobalContext sharedSingleton];
    sharedCIImage = [GlobalCIImage sharedSingleton];
    
    // Setup collection view
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.allowsSelection = YES;
    
    // Load the available filters
    NSString *plist = [[NSBundle mainBundle] pathForResource:@"Filters" ofType:@"plist"];
    self.availableFilterInfos = [NSArray arrayWithContentsOfFile:plist];
    
    // Add the background image and UIEffectView for the blur
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [effectView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view insertSubview:effectView aboveSubview:self.backgroundImageView];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[effectView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(effectView)];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[effectView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(effectView)];
    [self.view addConstraints:verticalConstraints];
    [self.view addConstraints:horizontalConstraints];
    
    // Load the view from HoverView.xib
    UINib *viewXib = [UINib nibWithNibName:@"View" bundle:nil];
    [viewXib instantiateWithOwner:self options:nil];
    
    [self.view addSubview:self.myView];
    self.myView.alpha = 0.0f;
    
    
}

// -------------------------------------------------------------------------------
//	viewDidLayoutSubviews
// -------------------------------------------------------------------------------
- (void)viewDidLayoutSubviews
{
    // Position view in the lower center of the view.
    self.myView.frame = CGRectMake(0, 0, 320, 320);
    self.myView.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0);
    self.myView.bounds = CGRectMake(0, 0, 320, 320);
    self.myView.clipsToBounds = YES;
    self.myView.transform = CGAffineTransformIdentity;
    //self.frame.origin.x = round((self.view.bounds.size.width - frame.size.width) / 2.0);
    //frame.origin.y = round((self.view.bounds.size.height / 2.0) - (frame.size.height / 2.0));
    //frame.size.width = 320;
    //frame.size.height = 240;
    //self.myView.frame = frame;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Update the selection UI
    NSInteger item = [self.availableFilterInfos indexOfObjectPassingTest:^BOOL(NSDictionary *filterInfo, NSUInteger idx, BOOL *stop) {
        return [filterInfo[kFilterInfoFilterNameKey] isEqualToString:self.selectedFilterName];
    }];
    if (item != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        [self.collectionView selectItemAtIndexPath:indexPath animated:NO
                                    scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [self updateSelectionForCell:[self.collectionView cellForItemAtIndexPath:indexPath]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // self.contentEditingInput = nil; // stopped crash, but froze skimmer functionality
/*
    if (cgImage != nil)
        cgImage = nil;
    sharedContext.ciContext = nil;
*/
    if (cgImage2 != nil)
        cgImage2 = nil;
    [self.myView removeFromSuperview];
    self.myView = nil;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

#pragma mark - PHContentEditingController

- (BOOL)canHandleAdjustmentData:(PHAdjustmentData *)adjustmentData {
    BOOL result = [adjustmentData.formatIdentifier isEqualToString:@"com.example.apple-samplecode.photofilter"];
    result &= [adjustmentData.formatVersion isEqualToString:@"1.0"];
    return result;
}

- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput placeholderImage:(UIImage *)placeholderImage {
    self.contentEditingInput = contentEditingInput;
    
    // Load input image
    switch (self.contentEditingInput.mediaType) {
        case PHAssetMediaTypeImage:
            // self.inputImage = [self.contentEditingInput.displaySizeImage equalize];
            self.inputImage = self.contentEditingInput.displaySizeImage;
            break;
            
        case PHAssetMediaTypeVideo:
            self.skimStepper.maximumValue = CMTimeGetSeconds(self.contentEditingInput.avAsset.duration);
            //self.inputImage = [[self imageForAVAsset:self.contentEditingInput.avAsset atTime:self.skimStepper.value] equalize];
            self.inputImage = [self imageForAVAsset:self.contentEditingInput.avAsset atTime:self.skimStepper.value];
            break;
            
        default:
            break;
    
    // Load adjustment data, if any
    @try {
        PHAdjustmentData *adjustmentData = self.contentEditingInput.adjustmentData;
        if (adjustmentData) {
            self.selectedFilterName = [NSKeyedUnarchiver unarchiveObjectWithData:adjustmentData.data];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception decoding adjustment data: %@", exception);
    }
    if (!self.selectedFilterName) {
        NSString *defaultFilterName = @"LevelsInput";
        self.selectedFilterName = defaultFilterName;
    }
    self.initialFilterName = self.selectedFilterName;
    
    // Update filter and background image
    [self updateFilter];
    [self updateFilterPreview];
    self.backgroundImageView.image = placeholderImage;
        
    }
}

- (void)finishContentEditingWithCompletionHandler:(void (^)(PHContentEditingOutput *))completionHandler {
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ */
        
        PHContentEditingOutput *contentEditingOutput = [[PHContentEditingOutput alloc] initWithContentEditingInput:self.contentEditingInput];
        
        // Adjustment data
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:self.selectedFilterName];
        PHAdjustmentData *adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:@"com.example.apple-samplecode.photofilter"
                                                                                formatVersion:@"1.0"
                                                                                         data:archivedData];
        contentEditingOutput.adjustmentData = adjustmentData;
        
        switch (self.contentEditingInput.mediaType) {
            case PHAssetMediaTypeImage: {
                // Get full size image
                NSURL *url = self.contentEditingInput.fullSizeImageURL;
                int orientation = self.contentEditingInput.fullSizeImageOrientation;
                
                // Generate rendered JPEG data
                UIImage *image = [UIImage imageWithContentsOfFile:url.path];
                image = [self transformedImage:image withOrientation:orientation usingFilter:self.ciFilter];
                NSData *renderedJPEGData = UIImagePNGRepresentation(image);
                
                // Save JPEG data
                NSError *error = nil;
                BOOL success = [renderedJPEGData writeToURL:contentEditingOutput.renderedContentURL options:NSDataWritingAtomic error:&error];
                if (success) {
                    completionHandler(contentEditingOutput);
                } else {
                    NSLog(@"An error occured: %@", error);
                    completionHandler(nil);
                }
                break;
            }
                
            case PHAssetMediaTypeVideo: {
                // Get AV asset
                AAPLAVReaderWriter *avReaderWriter = [[AAPLAVReaderWriter alloc] initWithAsset:self.contentEditingInput.avAsset];
                avReaderWriter.delegate = self;
                
                // Save filtered video
                [avReaderWriter writeToURL:contentEditingOutput.renderedContentURL
                                  progress:^(float progress) {
                                  }
                                completion:^(NSError *error) {
                                    if (!error) {
                                        completionHandler(contentEditingOutput);
                                    } else {
                                        NSLog(@"An error occured: %@", error);
                                        completionHandler(nil);
                                    }
                                }];
                break;
            }
                
            default:
                break;
        }
   /* });*/
}

- (void)cancelContentEditing {
    // Handle cancellation
}

- (BOOL)shouldShowCancelConfirmation {
    BOOL shouldShowCancelConfirmation = NO;
    
    if (![self.selectedFilterName isEqualToString:self.initialFilterName]) {
        shouldShowCancelConfirmation = YES;
    }
    
    return shouldShowCancelConfirmation;
}

#pragma mark - Image Filtering

- (void)updateFilter {
    self.ciFilter = [CIFilter filterWithName:self.selectedFilterName];
    [GlobalCIImage sharedSingleton].ciImage = [CIImage imageWithCGImage:self.inputImage.CGImage];
    int orientation = [self orientationFromImageOrientation:self.inputImage.imageOrientation];
    [GlobalCIImage sharedSingleton].ciImage = [[GlobalCIImage sharedSingleton].ciImage imageByApplyingOrientation:orientation];
    
    if (self.gaussianBlurSlider.value != 0.0)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"GaussianKernel" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputRadius", [NSNumber numberWithFloat:self.gaussianBlurSlider.value], nil].outputImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [self controlColor:[GlobalCIImage sharedSingleton].ciImage];
    
    if (self.edgeSwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [self convolution:[GlobalCIImage sharedSingleton].ciImage];
    
    [self.ciFilter setValue:[GlobalCIImage sharedSingleton].ciImage forKey:kCIInputImageKey];
}

/*
 - (void)updateFilterPreview {
 CIImage *outputImage = self.ciFilter.outputImage;
 CGImageRef cgImage = [self.ciContext createCGImage:outputImage fromRect:outputImage.extent];
 
 if (self.equalizeHistogramSwitch.on)
 {
 //vImage_Buffer buffer;
 vImage_CGImageFormat format = {
 .bitsPerComponent = 8,
 .bitsPerPixel = 32,
 .bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst,
 .colorSpace = NULL,
 };
 vImage_Error err;
 err = vImageBuffer_InitWithCGImage( &buffer, &format, NULL, cgImage, kvImageNoFlags );
 if (err != kvImageNoError)
 NSLog(@"Error: %ld", err);
 
 [self vImageFilter:buffer];
 
 vImage_CGImageFormat format_cgi = {
 .bitsPerComponent = 8,
 .bitsPerPixel = 32,
 .bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast,
 };
 cgImage = vImageCreateCGImageFromBuffer( &buffer, &format_cgi, NULL, NULL, kvImageNoFlags, &err);
 }
 UIImage *transformedImage = [UIImage imageWithCGImage:cgImage];
 CGImageRelease(cgImage);
 //free((void*)&buffer);
 
 self.filterPreviewView.image = transformedImage;
 }
 */

- (CIImage *)controlColor:(CIImage *)image
{
    inputMin    = self.inputMinSlider.value;
    gammaLevels = self.gammaSlider.value;
    inputMax    = self.inputMaxSlider.value;
    outputMin   = self.outputMinSlider.value;
    outputMax   = self.outputMaxSlider.value;
    image = [CIFilter filterWithName:@"LevelsInput" keysAndValues:kCIInputImageKey, image, @"inputMinInput", [NSNumber numberWithFloat:inputMin], @"inputGamma", [NSNumber numberWithFloat:gammaLevels], @"inputMaxInput", [NSNumber numberWithFloat:inputMax], @"inputMinOutput", [NSNumber numberWithFloat:outputMin], @"inputMaxOutput", [NSNumber numberWithFloat:outputMax], nil].outputImage;
    
    float CIgamma = self.gammaStepper.value;
    image = [CIFilter filterWithName:@"CIGammaAdjust" keysAndValues:kCIInputImageKey, image, @"inputPower", [NSNumber numberWithFloat:CIgamma], nil].outputImage;
    
    float ev = self.exposureStepper.value;
    image = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, image, kCIInputEVKey, [NSNumber numberWithFloat:ev], nil].outputImage;
    
    float brightness = self.brightnessStepper.value;
    float saturation = self.saturationStepper.value;
    float contrast = self.contrastStepper.value;
    image = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, image, kCIInputBrightnessKey, [NSNumber numberWithFloat:brightness], kCIInputSaturationKey, [NSNumber numberWithFloat:saturation], kCIInputContrastKey, [NSNumber numberWithFloat:contrast], nil].outputImage;
    
    if (self.invertSwitch.on)
    image = [CIFilter filterWithName:@"CIColorInvert" keysAndValues:kCIInputImageKey, image, nil].outputImage;
    
    if (self.sRGBSwitch.on)
        image = [CIFilter filterWithName:@"CILinearToSRGBToneCurve" keysAndValues:kCIInputImageKey, image, nil].outputImage;
    
    if (self.invertSwitch.on)
        image = [CIFilter filterWithName:@"CIColorInvert" keysAndValues:kCIInputImageKey, image, nil].outputImage;
    
    return image;
}

- (CIImage *)postControlColor:(CIImage *)image
{
    // Output levels
    inputMin  = self.inputMinSlider.value;
    gammaLevels = self.gammaSlider.value;
    inputMax  = self.inputMaxSlider.value;
    outputMin = self.outputMinSlider.value;
    outputMax = self.outputMaxSlider.value;
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"LevelsOutput" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputMinInput", [NSNumber numberWithFloat:inputMin], @"inputGamma", [NSNumber numberWithFloat:gammaLevels], @"inputMaxInput", [NSNumber numberWithFloat:inputMax], @"inputMinOutput", [NSNumber numberWithFloat:outputMin], @"inputMaxOutput", [NSNumber numberWithFloat:outputMax], nil].outputImage;
    
    if (self.stretchSwitch.on)
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"ContrastStretch" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage; // self.inputImage = [self.inputImage stretchContrast];
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

- (CIImage *)morph:(CIImage *)image
{
    if (self.morphologyBlendModeSegmentedControl.selectedSegmentIndex == 0) /* apply to original image */
    {
        [GlobalCIImage sharedSingleton].ciImage = [self morphologize:[GlobalCIImage sharedSingleton].ciImage];
    }
    else if (self.morphologyBlendModeSegmentedControl.selectedSegmentIndex == 1) /* subtract from image */
    {
        if (self.openCloseSegmentedControl.selectedSegmentIndex == 0) /* Edge Out */
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:kCIInputImageKey, [self morphologize:[GlobalCIImage sharedSingleton].ciImage], kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
        else if (self.openCloseSegmentedControl.selectedSegmentIndex == 1) /* Edge In */
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:kCIInputImageKey, [self morphologize:[GlobalCIImage sharedSingleton].ciImage], kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
        else if (self.openCloseSegmentedControl.selectedSegmentIndex == 2) /* White Tophat */
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:kCIInputImageKey, [self morphologize:[GlobalCIImage sharedSingleton].ciImage], kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
        else if (self.openCloseSegmentedControl.selectedSegmentIndex == 3) /* Black Tophat */
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:kCIInputImageKey, [self morphologize:[GlobalCIImage sharedSingleton].ciImage], kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    }
    else if (self.morphologyBlendModeSegmentedControl.selectedSegmentIndex == 2) /* subtract from operator */
    {
        if (self.openCloseSegmentedControl.selectedSegmentIndex == 0) /* Gradient */
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:kCIInputImageKey, [self dilation:[GlobalCIImage sharedSingleton].ciImage], kCIInputBackgroundImageKey, [self erosion:[GlobalCIImage sharedSingleton].ciImage], nil].outputImage;
        else if (self.openCloseSegmentedControl.selectedSegmentIndex == 1) /* Edge */
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:kCIInputImageKey, [self erosion:[GlobalCIImage sharedSingleton].ciImage], kCIInputBackgroundImageKey, [self dilation:[GlobalCIImage sharedSingleton].ciImage], nil].outputImage;
        else if (self.openCloseSegmentedControl.selectedSegmentIndex == 2) /* Corner (Non-Square) */
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:kCIInputImageKey, [self erosion:[GlobalCIImage sharedSingleton].ciImage], kCIInputBackgroundImageKey, [self dilation:[GlobalCIImage sharedSingleton].ciImage], nil].outputImage;
        else if (self.openCloseSegmentedControl.selectedSegmentIndex == 3) /* Corner */
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:kCIInputImageKey, [self dilation:[GlobalCIImage sharedSingleton].ciImage], kCIInputBackgroundImageKey, [self erosion:[GlobalCIImage sharedSingleton].ciImage], nil].outputImage;
    }
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

- (CIImage *)morphologize:(CIImage *)image
{
    if (self.openCloseSegmentedControl.selectedSegmentIndex == 0) /* dilate */
        return [self dilation:[GlobalCIImage sharedSingleton].ciImage];
    else if (self.openCloseSegmentedControl.selectedSegmentIndex == 1) /* erode */
        return [self erosion:[GlobalCIImage sharedSingleton].ciImage];
    else if (self.openCloseSegmentedControl.selectedSegmentIndex == 2) /* open */
    {
        [GlobalCIImage sharedSingleton].ciImage = [self erosion:[GlobalCIImage sharedSingleton].ciImage];
        return [self dilation:[GlobalCIImage sharedSingleton].ciImage];
    }
    else if (self.openCloseSegmentedControl.selectedSegmentIndex == 3) /* close */
    {
        [GlobalCIImage sharedSingleton].ciImage = [self dilation:[GlobalCIImage sharedSingleton].ciImage];
        return [self erosion:[GlobalCIImage sharedSingleton].ciImage];
    }
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

- (CIImage *)dilation:(CIImage *)image
{
    float radius = self.radiusDilateStepper.value;
    for (int i = 0; i < self.dilateIterator.value; i++)
    {
        if (self.dilateShapeSegmentedControl.selectedSegmentIndex == 0)
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"Dilate" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputRadius", [NSNumber numberWithFloat:radius], nil].outputImage;
        if (self.dilateShapeSegmentedControl.selectedSegmentIndex == 1)
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"DilateDiamond" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputRadius", [NSNumber numberWithFloat:radius], nil].outputImage;
        if (self.dilateShapeSegmentedControl.selectedSegmentIndex == 2)
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"DilateCross" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputRadius", [NSNumber numberWithFloat:radius], nil].outputImage;
        if (self.dilateShapeSegmentedControl.selectedSegmentIndex == 3)
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"DilateX" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputRadius", [NSNumber numberWithFloat:radius], nil].outputImage;
    }
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

- (CIImage *)erosion:(CIImage *)image
{
    float radius = self.radiusErodeStepper.value;
    for (int j = 0; j < self.erodeIterator.value; j++)
    {
        if (self.erodeShapeSegmentedControl.selectedSegmentIndex == 0)
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"Erode" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputRadius", [NSNumber numberWithFloat:radius], nil].outputImage;
        if (self.erodeShapeSegmentedControl.selectedSegmentIndex == 1)
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"ErodeDiamond" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputRadius", [NSNumber numberWithFloat:radius], nil].outputImage;
        if (self.erodeShapeSegmentedControl.selectedSegmentIndex == 2)
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"ErodeCross" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputRadius", [NSNumber numberWithFloat:radius], nil].outputImage;
        if (self.erodeShapeSegmentedControl.selectedSegmentIndex == 3)
            [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"ErodeX" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputRadius", [NSNumber numberWithFloat:radius], nil].outputImage;

    }
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

- (CIImage *)convolution:(CIImage *)image
{
    float h1Value = self.h1TextField.text.floatValue;
    float h2Value = self.h2TextField.text.floatValue;
    float h3Value = self.h3TextField.text.floatValue;
    float h4Value = self.h4TextField.text.floatValue;
    float h5Value = self.h5TextField.text.floatValue;
    float h6Value = self.h6TextField.text.floatValue;
    float h7Value = self.h7TextField.text.floatValue;
    float h8Value = self.h8TextField.text.floatValue;
    float h9Value = self.h9TextField.text.floatValue;
    float v1Value = self.v1TextField.text.floatValue;
    float v2Value = self.v2TextField.text.floatValue;
    float v3Value = self.v3TextField.text.floatValue;
    float v4Value = self.v4TextField.text.floatValue;
    float v5Value = self.v5TextField.text.floatValue;
    float v6Value = self.v6TextField.text.floatValue;
    float v7Value = self.v7TextField.text.floatValue;
    float v8Value = self.v8TextField.text.floatValue;
    float v9Value = self.v9TextField.text.floatValue;
    float compassGradientValue = [NSNumber numberWithInteger:self.compassGradientSegmentedControl.selectedSegmentIndex].floatValue;
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CustomConvolution" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputCompassGradient", [NSNumber numberWithFloat:compassGradientValue], @"inputH1", [NSNumber numberWithFloat:h1Value], @"inputH2", [NSNumber numberWithFloat:h2Value], @"inputH3", [NSNumber numberWithFloat:h3Value], @"inputH4", [NSNumber numberWithFloat:h4Value], @"inputH5", [NSNumber numberWithFloat:h5Value], @"inputH6", [NSNumber numberWithFloat:h6Value], @"inputH7", [NSNumber numberWithFloat:h7Value], @"inputH8", [NSNumber numberWithFloat:h8Value], @"inputH9", [NSNumber numberWithFloat:h9Value], @"inputV1", [NSNumber numberWithFloat:v1Value], @"inputV2", [NSNumber numberWithFloat:v2Value], @"inputV3", [NSNumber numberWithFloat:v3Value], @"inputV4", [NSNumber numberWithFloat:v4Value], @"inputV5", [NSNumber numberWithFloat:v5Value], @"inputV6", [NSNumber numberWithFloat:v6Value], @"inputV7", [NSNumber numberWithFloat:v7Value], @"inputV8", [NSNumber numberWithFloat:v8Value], @"inputV9", [NSNumber numberWithFloat:v9Value], nil].outputImage;

    return [GlobalCIImage sharedSingleton].ciImage;
}

- (CIImage *)applyDirectionalMean:(CIImage *)image
{
    float operator = [NSNumber numberWithInteger:[self.neighborhoodOperatorPickerView selectedRowInComponent:0]].floatValue;
    float units    = [NSNumber numberWithInteger:self.unitsSegmentedControl.selectedSegmentIndex].floatValue;
    float inputNorth = self.northStepper.value;
    float inputSouth = self.southStepper.value;
    float inputEast  = self.eastStepper.value;
    float inputWest  = self.westStepper.value;
    float iterations = self.andwpIterationsStepper.value;
    if (operator == 1.0)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"Mean" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputIterations", [NSNumber numberWithFloat:iterations], @"inputUnits", [NSNumber numberWithFloat:units], @"inputNorth", [NSNumber numberWithFloat:inputNorth], @"inputSouth", [NSNumber numberWithFloat:inputSouth], @"inputEast", [NSNumber numberWithFloat:inputEast], @"inputWest", [NSNumber numberWithFloat:inputWest], nil].outputImage;
    else if (operator == 2.0)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"MaxMin" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputIterations", [NSNumber numberWithFloat:iterations], @"inputUnits", [NSNumber numberWithFloat:units], @"inputNorth", [NSNumber numberWithFloat:inputNorth], @"inputSouth", [NSNumber numberWithFloat:inputSouth], @"inputEast", [NSNumber numberWithFloat:inputEast], @"inputWest", [NSNumber numberWithFloat:inputWest], nil].outputImage;
    else if (operator == 3.0)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"Median" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputIterations", [NSNumber numberWithFloat:iterations], @"inputUnits", [NSNumber numberWithFloat:units], @"inputNorth", [NSNumber numberWithFloat:inputNorth], @"inputSouth", [NSNumber numberWithFloat:inputSouth], @"inputEast", [NSNumber numberWithFloat:inputEast], @"inputWest", [NSNumber numberWithFloat:inputWest], nil].outputImage;
    else if (operator == 4.0)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"Mode" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputIterations", [NSNumber numberWithFloat:iterations], @"inputUnits", [NSNumber numberWithFloat:units], @"inputNorth", [NSNumber numberWithFloat:inputNorth], @"inputSouth", [NSNumber numberWithFloat:inputSouth], @"inputEast", [NSNumber numberWithFloat:inputEast], @"inputWest", [NSNumber numberWithFloat:inputWest], nil].outputImage;
    else if (operator == 5.0)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"HybridMedian" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputIterations", [NSNumber numberWithFloat:iterations], @"inputUnits", [NSNumber numberWithFloat:units], @"inputNorth", [NSNumber numberWithFloat:inputNorth], @"inputSouth", [NSNumber numberWithFloat:inputSouth], @"inputEast", [NSNumber numberWithFloat:inputEast], @"inputWest", [NSNumber numberWithFloat:inputWest], nil].outputImage;
    else if (operator == 6.0)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"MedianAbsoluteDeviation" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputIterations", [NSNumber numberWithFloat:iterations], @"inputUnits", [NSNumber numberWithFloat:units], @"inputNorth", [NSNumber numberWithFloat:inputNorth], @"inputSouth", [NSNumber numberWithFloat:inputSouth], @"inputEast", [NSNumber numberWithFloat:inputEast], @"inputWest", [NSNumber numberWithFloat:inputWest], nil].outputImage;
    else if (operator == 7.0)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"ShiftedDataVariance" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputIterations", [NSNumber numberWithFloat:iterations], @"inputUnits", [NSNumber numberWithFloat:units], @"inputNorth", [NSNumber numberWithFloat:inputNorth], @"inputSouth", [NSNumber numberWithFloat:inputSouth], @"inputEast", [NSNumber numberWithFloat:inputEast], @"inputWest", [NSNumber numberWithFloat:inputWest], nil].outputImage;
    else if (operator == 8.0)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"ChromaUnsharp" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputIterations", [NSNumber numberWithFloat:iterations], @"inputUnits", [NSNumber numberWithFloat:units], @"inputNorth", [NSNumber numberWithFloat:inputNorth], @"inputSouth", [NSNumber numberWithFloat:inputSouth], @"inputEast", [NSNumber numberWithFloat:inputEast], @"inputWest", [NSNumber numberWithFloat:inputWest], nil].outputImage;

    return [GlobalCIImage sharedSingleton].ciImage;
}

- (CIImage *)toneCurve:(CIImage *)image
{
    float x1 = [NSNumber numberWithFloat:self.X1.value].floatValue;
    float y1 = [NSNumber numberWithFloat:self.Y1.value].floatValue;
    float x2 = [NSNumber numberWithFloat:self.X2.value].floatValue;
    float y2 = [NSNumber numberWithFloat:self.Y2.value].floatValue;
    float x3 = [NSNumber numberWithFloat:self.X3.value].floatValue;
    float y3 = [NSNumber numberWithFloat:self.Y3.value].floatValue;
    float x4 = [NSNumber numberWithFloat:self.X4.value].floatValue;
    float y4 = [NSNumber numberWithFloat:self.Y4.value].floatValue;
    float x5 = [NSNumber numberWithFloat:self.X5.value].floatValue;
    float y5 = [NSNumber numberWithFloat:self.Y5.value].floatValue;
    if (self.toneCurveSwitch.on)
    {
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIToneCurve" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputPoint0", [CIVector vectorWithX:x1 Y:y1], @"inputPoint1", [CIVector vectorWithX:x2 Y:y2], @"inputPoint2", [CIVector vectorWithX:x3 Y:y3], @"inputPoint3", [CIVector vectorWithX:x4 Y:y4], @"inputPoint4", [CIVector vectorWithX:x5 Y:y5], nil].outputImage;
    }
    return [GlobalCIImage sharedSingleton].ciImage;
}

- (CIImage *)blend:(CIImage *)image
{
    CIImage *inputImg = [CIImage imageWithCGImage:self.inputImage.CGImage];
    if (self.invertSwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIColorInvert" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    
    if (self.multiplySwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIMultiplyBlendMode" keysAndValues:kCIInputImageKey, image, kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage];// ( self.originalBackgroundSwitch.on ) ? [GlobalCIImage sharedSingleton].ciImage : inputImg, nil].outputImage;
    if (self.overlaySwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIOverlayBlendMode" keysAndValues:kCIInputImageKey, image, kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage]; // ( self.originalBackgroundSwitch.on ) ? [GlobalCIImage sharedSingleton].ciImage : inputImg, nil].outputImage;
    if (self.screenSwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIScreenBlendMode" keysAndValues:kCIInputImageKey, image, kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage]; // ( self.originalBackgroundSwitch.on ) ? [GlobalCIImage sharedSingleton].ciImage : inputImg, nil].outputImage;
    if (self.subtractSwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CISubtractBlendMode" keysAndValues:kCIInputImageKey, ( self.originalBackgroundSwitch.on ) ? [GlobalCIImage sharedSingleton].ciImage : inputImg, kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    if (self.differenceSwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:kCIInputImageKey, ( self.originalBackgroundSwitch.on ) ? [GlobalCIImage sharedSingleton].ciImage : inputImg, kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    if (self.additionSwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIAdditionCompositing" keysAndValues:kCIInputImageKey, ( self.originalBackgroundSwitch.on ) ? [GlobalCIImage sharedSingleton].ciImage : inputImg, kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

- (CIImage *)displayHistogram:(CIImage *)image
{
    sharedCIImage.ciImage = [CIFilter filterWithName:@"CIAreaHistogram" keysAndValues:kCIInputImageKey, sharedCIImage.ciImage, @"inputExtent", sharedCIImage.ciImage.extent, @"inputScale", [NSNumber numberWithFloat:1.0], @"inputCount", [NSNumber numberWithFloat:256.0], nil].outputImage;
    sharedCIImage.ciImage = [CIFilter filterWithName:@"CIHistogramDisplayFilter" keysAndValues:kCIInputImageKey, sharedCIImage.ciImage, @"inputHeight", [NSNumber numberWithFloat:100.0], @"inputHighLimit", [NSNumber numberWithFloat:1.0], @"inputLowLimit", [NSNumber numberWithFloat:0.0], nil].outputImage;
    return sharedCIImage.ciImage;
}

- (CIImage *)adjustCurves:(CIImage *)image
{
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"BushCurve" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputMinContrastValue", [NSNumber numberWithFloat:self.lowerCurveSlider.value], @"inputMaxContrastValue", [NSNumber numberWithFloat:self.upperCurveSlider.value], nil].outputImage;
    return [GlobalCIImage sharedSingleton].ciImage;
}

- (CIImage *)overlayCurves:(CIImage *)image applyCurve:(int)curve
{
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"OverlayCurves" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputCurve", [NSNumber numberWithFloat:(float)curve], @"inputMinContrastValue", [NSNumber numberWithFloat:self.lowerCurveSlider.value], @"inputMaxContrastValue", [NSNumber numberWithFloat:self.upperCurveSlider.value], nil].outputImage;
    return [GlobalCIImage sharedSingleton].ciImage;
}



// Add two switches for subtracting 1) the output of two morphological operators and 2) the output of a morphological operation and the input image
// Black Tophat: Closing (dilation followed by an erosion) subtracted from the original
// White Tophat: Opening (erosion followed by a dilation) subtracted from the original
// Edge In: Erosion subtracted (or differenced) from original
// Edge Out: Dilation subtracted (or differenced) from original

// Edge: Difference between erosion and dilation of an image
// Gradient: Difference between dilation and erosion of an image
// Morphological: Difference between erosion and dilation of an image, using non-square structuring elements
// NOTE: Edge and Gradient will be activated by selecting either Opening or Closing and then a separate button for edge finding;
//       Morphological will be activated by same, but only when non-square shapes for Erosion and Dilation are selected

// Smooth: Opening followed by closing

- (void)updateFilterPreview {
    //CIImage *inputImg = [CIImage imageWithCGImage:self.inputImage.CGImage];
    [GlobalCIImage sharedSingleton].ciImage = self.ciFilter.outputImage;
    
    if (self.morphologySwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [self morph:[GlobalCIImage sharedSingleton].ciImage];
    
    //img = [CIFilter filterWithName:@"Equalize" keysAndValues:kCIInputImageKey, img, @"inputContext", self.ciContext, nil].outputImage;
    
    if ([self.neighborhoodOperatorPickerView selectedRowInComponent:0] != 0)
    {
        [GlobalCIImage sharedSingleton].ciImage = [self applyDirectionalMean:[GlobalCIImage sharedSingleton].ciImage];
        //float thresholdType = [NSNumber numberWithInteger:self.thresholdSegmentedControl.selectedSegmentIndex].floatValue;
        //img = [CIFilter filterWithName:@"LocalAdaptiveThreshold" keysAndValues:kCIInputImageKey, img, @"inputThresholdType", [NSNumber numberWithFloat:thresholdType], nil].outputImage;
    }

    [GlobalCIImage sharedSingleton].ciImage = [self postControlColor:[GlobalCIImage sharedSingleton].ciImage];
    
    if (self.toneCurveSwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [self toneCurve:[GlobalCIImage sharedSingleton].ciImage];
    
    [GlobalCIImage sharedSingleton].ciImage = [self blend:[GlobalCIImage sharedSingleton].ciImage];
    
    [GlobalCIImage sharedSingleton].ciImage = [self adjustCurves:[GlobalCIImage sharedSingleton].ciImage];
    
    int orientation = [self orientationFromImageOrientation:self.inputImage.imageOrientation];
    [GlobalCIImage sharedSingleton].ciImage = [[GlobalCIImage sharedSingleton].ciImage imageByApplyingOrientation:orientation];
    if (cgImage != nil)
        cgImage = nil;
    cgImage = [[GlobalContext sharedSingleton].ciContext createCGImage:[GlobalCIImage sharedSingleton].ciImage fromRect:[GlobalCIImage sharedSingleton].ciImage.extent];
    UIImage *transformedImage = [[UIImage imageWithCGImage:cgImage] equalize:(self.equalizeHistogramSwitch.on) stretchContrast:(self.stretchContrastSwitch.on)];
    //UIImage *transformedImage = [UIImage imageWithCGImage:cgImage];
    self.filterPreviewView.image = transformedImage;
    //self.filterPreviewView.image = [transformedImage stretchContrast:(self.stretchContrastSwitch.on)];
    
    /*
    if (cgImage != nil)
        cgImage = nil;
    cgImage = [[GlobalContext sharedSingleton].ciContext createCGImage:[self displayHistogram:[GlobalCIImage sharedSingleton].ciImage] fromRect:[GlobalCIImage sharedSingleton].ciImage.extent];
    self.histogramView.image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationLeft]; //[UIImage imageWithCGImage:cgImage];
    
    int curve = 0;
    if (cgImage != nil)
        cgImage = nil;
    cgImage = [[GlobalContext sharedSingleton].ciContext createCGImage:[self overlayCurves:[GlobalCIImage sharedSingleton].ciImage applyCurve:curve] fromRect:[GlobalCIImage sharedSingleton].ciImage.extent];
    self.UpperCurveView.image = [UIImage imageWithCGImage:cgImage];
    
    curve = 1;
    if (cgImage != nil)
        cgImage = nil;
    cgImage = [[GlobalContext sharedSingleton].ciContext createCGImage:[self overlayCurves:[GlobalCIImage sharedSingleton].ciImage applyCurve:curve] fromRect:[GlobalCIImage sharedSingleton].ciImage.extent];
    self.AverageCurveView.image = [UIImage imageWithCGImage:cgImage];

    curve = 2;
    if (cgImage != nil)
        cgImage = nil;
    cgImage = [[GlobalContext sharedSingleton].ciContext createCGImage:[self overlayCurves:[GlobalCIImage sharedSingleton].ciImage applyCurve:curve] fromRect:[GlobalCIImage sharedSingleton].ciImage.extent];
    self.LowerCurveView.image = [UIImage imageWithCGImage:cgImage];
    
    if (cgImage != nil)
        cgImage = nil;
    cgImage = [[GlobalContext sharedSingleton].ciContext createCGImage:[self displayHistogram:[GlobalCIImage sharedSingleton].ciImage] fromRect:[GlobalCIImage sharedSingleton].ciImage.extent];
    self.filterPreviewView.image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp]; //[UIImage imageWithCGImage:cgImage];
    */
    CGImageRelease(cgImage);
}

-(UIImage*)removeColorFromImage:(UIImage*)sourceImage grayLevel:(int)grayLevel
{
    // Place line below in calling method:
    // self.curvesView.image = [self removeColorFromImage:transformedImage grayLevel:255];
    int width = sourceImage.size.width * sourceImage.scale;
    int height = sourceImage.size.height * sourceImage.scale;
    CGFloat scale = sourceImage.scale;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), sourceImage.CGImage);
    
    unsigned int *colorData = CGBitmapContextGetData(context);
    
    for (int i = 0; i < width * height; i++)
    {
        unsigned int color = *colorData;
        
        short a = color & 0xFF;
        short r = (color >> 8) & 0xFF;
        short g = (color >> 16) & 0xFF;
        short b = (color >> 24) & 0xFF;
        
        if ((r == grayLevel) && (g == grayLevel) && (b == grayLevel))
        {
            a = r = g = b = 0;
            *colorData = (unsigned int)(r << 8) + ((unsigned int)(g) << 16) + ((unsigned int)(b) << 24) + ((unsigned int)(a));
        }
        
        colorData++;
    }
    
    CGImageRef output = CGBitmapContextCreateImage(context);
    UIImage* retImage = [UIImage imageWithCGImage:output scale:scale orientation:UIImageOrientationUp];
    
    CGImageRelease(output);
    CGContextRelease(context);
    
    return retImage;
}

/*
 - (UIImage *)transformedImage:(UIImage *)image withOrientation:(int)orientation usingFilter:(CIFilter *)filter {
 CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
 inputImage = [inputImage imageByApplyingOrientation:orientation];
 
 [self.ciFilter setValue:inputImage forKey:kCIInputImageKey];
 CIImage *outputImage = [self.ciFilter outputImage];
 CGImageRef cgImage = [self.ciContext createCGImage:outputImage fromRect:outputImage.extent];
 
 if (self.equalizeHistogramSwitch.on)
 {
 //vImage_Buffer buffer;
 vImage_CGImageFormat format = {
 .bitsPerComponent = 8,
 .bitsPerPixel = 32,
 .bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst,
 .colorSpace = NULL,
 };
 vImage_Error err;
 err = vImageBuffer_InitWithCGImage( &buffer, &format, NULL, cgImage, kvImageNoFlags );
 if (err != kvImageNoError)
 NSLog(@"Error: %ld", err);
 
 [self vImageFilter:buffer];
 
 vImage_CGImageFormat format_cgi = {
 .bitsPerComponent = 8,
 .bitsPerPixel = 32,
 .bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast,
 };
 cgImage = vImageCreateCGImageFromBuffer( &buffer, &format_cgi, NULL, NULL, kvImageNoFlags, &err);
 }
 
 UIImage *transformedImage = [UIImage imageWithCGImage:cgImage];
 CGImageRelease(cgImage);
 //free((void*)&buffer);
 
 return transformedImage;
 }
 */

- (UIImage *)transformedImage:(UIImage *)image withOrientation:(int)orientation usingFilter:(CIFilter *)filter {
    //CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    //CIImage *inputImg = [CIImage imageWithCGImage:image.CGImage];
    [GlobalCIImage sharedSingleton].ciImage = [CIImage imageWithCGImage:image.CGImage];
    [GlobalCIImage sharedSingleton].ciImage = [[GlobalCIImage sharedSingleton].ciImage imageByApplyingOrientation:orientation];
    
    if (self.gaussianBlurSlider.value != 0.0)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"GaussianKernel" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputRadius", [NSNumber numberWithFloat:self.gaussianBlurSlider.value], nil].outputImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [self controlColor:[GlobalCIImage sharedSingleton].ciImage];
    
    if (self.edgeSwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [self convolution:[GlobalCIImage sharedSingleton].ciImage];
    
    [self.ciFilter setValue:[GlobalCIImage sharedSingleton].ciImage forKey:kCIInputImageKey];
    [GlobalCIImage sharedSingleton].ciImage = self.ciFilter.outputImage;
    
    if (self.morphologySwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [self morph:[GlobalCIImage sharedSingleton].ciImage];
    
    if ([self.neighborhoodOperatorPickerView selectedRowInComponent:0] != 0)
    {
        [GlobalCIImage sharedSingleton].ciImage = [self applyDirectionalMean:[GlobalCIImage sharedSingleton].ciImage];
        /*
        float thresholdType = [NSNumber numberWithInteger:self.thresholdSegmentedControl.selectedSegmentIndex].floatValue;
        img = [CIFilter filterWithName:@"LocalAdaptiveThreshold" keysAndValues:kCIInputImageKey, img, @"inputThresholdType", [NSNumber numberWithFloat:thresholdType], nil].outputImage;
        */
    }
    
    [GlobalCIImage sharedSingleton].ciImage = [self postControlColor:[GlobalCIImage sharedSingleton].ciImage];
    
    if (self.toneCurveSwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [self toneCurve:[GlobalCIImage sharedSingleton].ciImage];
    
    [GlobalCIImage sharedSingleton].ciImage = [self blend:[GlobalCIImage sharedSingleton].ciImage];
    
    [GlobalCIImage sharedSingleton].ciImage = [self adjustCurves:[GlobalCIImage sharedSingleton].ciImage];
    
    orientation = [self orientationFromImageOrientation:self.inputImage.imageOrientation];
    [GlobalCIImage sharedSingleton].ciImage = [[GlobalCIImage sharedSingleton].ciImage imageByApplyingOrientation:orientation];
    if (cgImage != nil)
        cgImage = nil;
    cgImage = [[GlobalContext sharedSingleton].ciContext createCGImage:[GlobalCIImage sharedSingleton].ciImage fromRect:[GlobalCIImage sharedSingleton].ciImage.extent];
    //UIImage *transformedImage = [UIImage imageWithCGImage:cgImage];
    UIImage *transformedImage = [[UIImage imageWithCGImage:cgImage] equalize:(self.equalizeHistogramSwitch.on) stretchContrast:(self.stretchContrastSwitch.on)];
    CGImageRelease(cgImage);
    
    return transformedImage;
}

/*
 - (void)vImageFilter:(vImage_Buffer)buffer
 {
 if (self.equalizeHistogramSwitch.on)
 {
 vImage_Error err;
 
 const unsigned int percent_low = 20;
 const unsigned int percent_high = 80;
 err = vImageEndsInContrastStretch_ARGB8888(&buffer, &buffer, &percent_low, &percent_high, kvImageNoError);
 if (err != kvImageNoError)
 NSLog(@"vImageEndsInContrastStretch_ARGB8888 error: %ld", err);
 
 Pixel_8 table[256];
 for (int i = 0; i < 256; i++)
 {
 table[i] = pow((float)(i / 255.0), 2.2) * 255.0;
 }
 err = vImageTableLookUp_ARGB8888( &buffer, &buffer, NULL, table, table, table, kvImageNoFlags );
 if (err != kvImageNoFlags)
 NSLog(@"Error: %ld", err);
 
 size_t width = buffer.width;
 size_t height = buffer.height;
 vImage_Buffer _dstA, _dstR, _dstG, _dstB;
 err = vImageBuffer_Init( &_dstA, height, width, 32 * sizeof( uint32_t ), kvImageNoFlags);
 if (err != kvImageNoError)
 NSLog(@"vImageBuffer_Init (alpha) error: %ld", err);
 err = vImageBuffer_Init( &_dstR, height, width, 32 * sizeof( uint32_t ), kvImageNoFlags);
 if (err != kvImageNoError)
 NSLog(@"vImageBuffer_Init (red) error: %ld", err);
 err = vImageBuffer_Init( &_dstG, height, width, 32 * sizeof( uint32_t ), kvImageNoFlags);
 if (err != kvImageNoError)
 NSLog(@"vImageBuffer_Init (green) error: %ld", err);
 err = vImageBuffer_Init( &_dstB, height, width, 32 * sizeof( uint32_t ), kvImageNoFlags);
 if (err != kvImageNoError)
 NSLog(@"vImageBuffer_Init (blue) error: %ld", err);
 
 Pixel_F max_val = 255;
 Pixel_F min_val = 0;
 err = vImageConvert_ARGBFFFFtoPlanarF(&buffer, &_dstA, &_dstR, &_dstG, &_dstB, kvImageDoNotTile);
 if (err != kvImageNoError)
 NSLog(@"vImageConvert_ARGB8888toPlanar8 error: %ld", err);
 
 GammaFunction func = vImageCreateGammaFunction(2.3f, kvImageGamma_UseGammaValue, 0);
 
 err = vImageEqualization_PlanarF(&_dstA, &_dstA, NULL, NULL, min_val, max_val, kvImageNoFlags);
 if (err != kvImageNoError)
 NSLog(@"vImageEqualization_PlanarF (alpha) error: %ld", err);
 err = vImageContrastStretch_PlanarF(&_dstA, &_dstA, NULL, NULL, min_val, max_val, kvImageNoFlags);
 if (err != kvImageNoError)
 NSLog(@"vImageContrastStretch_PlanarF (alpha) error: %ld", err);
 err = vImageGamma_PlanarF(&_dstA, &_dstA, func, 0);
 if (err != kvImageNoError)
 NSLog(@"vImageGamma_PlanarF (alpha) error: %ld", err);
 
 err = vImageEqualization_PlanarF(&_dstR, &_dstR, NULL, NULL, min_val, max_val, kvImageNoFlags);
 if (err != kvImageNoError)
 NSLog(@"vImageEqualization_PlanarF (red) error: %ld", err);
 err = vImageContrastStretch_PlanarF(&_dstR, &_dstR, NULL, NULL, min_val, max_val, kvImageNoFlags);
 if (err != kvImageNoError)
 NSLog(@"vImageContrastStretch_PlanarF (red) error: %ld", err);
 func = vImageCreateGammaFunction(2.3f, kvImageGamma_UseGammaValue, 0);
 err = vImageGamma_PlanarF(&_dstR, &_dstR, func, 0);
 if (err != kvImageNoError)
 NSLog(@"vImageGamma_PlanarF (red) error: %ld", err);
 
 err = vImageEqualization_PlanarF(&_dstG, &_dstG, NULL, NULL, min_val, max_val, kvImageNoFlags);
 if (err != kvImageNoError)
 NSLog(@"vImageEqualization_PlanarF (green) error: %ld", err);
 err = vImageContrastStretch_PlanarF(&_dstG, &_dstG, NULL, NULL, min_val, max_val, kvImageNoFlags);
 if (err != kvImageNoError)
 NSLog(@"vImageContrastStretch_PlanarF (green) error: %ld", err);
 func = vImageCreateGammaFunction(2.3f, kvImageGamma_UseGammaValue, 0);
 err = vImageGamma_PlanarF(&_dstG, &_dstG, func, 0);
 if (err != kvImageNoError)
 NSLog(@"vImageGamma_PlanarF (green) error: %ld", err);
 
 err = vImageEqualization_PlanarF(&_dstB, &_dstB, NULL, NULL, min_val, max_val, kvImageNoFlags);
 if (err != kvImageNoError)
 NSLog(@"vImageEqualization_PlanarF (blue) error: %ld", err);
 err = vImageContrastStretch_PlanarF(&_dstB, &_dstB, NULL, NULL, min_val, max_val, kvImageNoFlags);
 if (err != kvImageNoError)
 NSLog(@"vImageContrastStretch_PlanarF (blue) error: %ld", err);
 func = vImageCreateGammaFunction(2.3f, kvImageGamma_UseGammaValue, 0);
 err = vImageGamma_PlanarF(&_dstB, &_dstB, func, 0);
 if (err != kvImageNoError)
 NSLog(@"vImageGamma_PlanarF (blue) error: %ld", err);
 
 vImageDestroyGammaFunction(func);
 
 err = vImageConvert_PlanarFtoARGBFFFF(&_dstA, &_dstR, &_dstG, &_dstB, &buffer, kvImageNoError);
 const float mx_val = 255;
 const float mn_val = 0;
 //err = vImageConvert_PlanarFToARGB8888(&_dstA, &_dstR, &_dstG, &_dstB, &buffer, &mx_val, &mn_val, kvImageNoError);
 if (err != kvImageNoError)
 NSLog(@"vImageConvert_PlanarFtoARGBFFFF error: %ld", err);
 
 free(_dstA.data);
 free(_dstR.data);
 free(_dstG.data);
 free(_dstB.data);
 
 vImagePixelCount				histogramA[256];
 vImagePixelCount				histogramR[256];
 vImagePixelCount				histogramG[256];
 vImagePixelCount				histogramB[256];
 vImagePixelCount*				histograms[4];
 vImagePixelCount				histogramA1[256];
 vImagePixelCount				histogramR1[256];
 vImagePixelCount				histogramG1[256];
 vImagePixelCount				histogramB1[256];
 vImagePixelCount*				histograms1[4];
 
 histograms[0] = histogramA;
 histograms[1] = histogramR;
 histograms[2] = histogramG;
 histograms[3] = histogramB;
 histograms1[0] = histogramA1;
 histograms1[1] = histogramR1;
 histograms1[2] = histogramG1;
 histograms1[3] = histogramB1;
 
 err = vImageHistogramCalculation_ARGB8888(&buffer, histograms, kvImageNoError);
 if (err != kvImageNoError)
 NSLog(@"vImageHistogramCalculation_ARGB8888 error: %ld", err);
 
 for (int i = 0; i < 224; i++)
 {
 histogramA1[i] = histogramA[i + 224];
 histogramR1[i] = histogramR[i + 224];
 histogramG1[i] = histogramG[i + 224];
 histogramB1[i] = histogramB[i + 224];
 }
 
 for (int i = 225; i < 255; i++)
 {
 histogramA1[i] = 0;
 histogramR1[i] = 0;
 histogramG1[i] = 0;
 histogramB1[i] = 0;
 }
 
 err = vImageHistogramSpecification_ARGB8888(&buffer, &buffer, (const vImagePixelCount**)histograms1, kvImageNoError);
 if (err != kvImageNoError)
 NSLog(@"Error: %ld", err);
 }
 }
 */
#pragma mark - AAPLAVReaderWriterAdjustDelegate (Video Filtering)
/*
 - (void)adjustPixelBuffer:(CVPixelBufferRef)inputBuffer toOutputBuffer:(CVPixelBufferRef)outputBuffer
 {
 if (self.equalizeHistogramSwitch.on)
 {
 CVPixelBufferLockBaseAddress( inputBuffer, 0 );
 unsigned char *base = (unsigned char *)CVPixelBufferGetBaseAddress( inputBuffer );
 size_t width = CVPixelBufferGetWidth( inputBuffer );
 size_t height = CVPixelBufferGetHeight( inputBuffer );
 size_t stride = CVPixelBufferGetBytesPerRow( inputBuffer );
 buffer_v.data = base;
 buffer_v.height = height;
 buffer_v.width = width;
 buffer_v.rowBytes = stride;
 //vImage_Buffer buffer_v = { .data = base, .height = height, .width = width, .rowBytes = stride };
 
 [self vImageFilter:buffer_v];
 
 CVPixelBufferUnlockBaseAddress( inputBuffer, 0 );
 }
 
 CIImage *img = [CIImage imageWithCVPixelBuffer:inputBuffer];
 [self.ciFilter setValue:img forKey:kCIInputImageKey];
 img = self.ciFilter.outputImage;
 [self.ciContext render:img toCVPixelBuffer:outputBuffer];
 //free((void*)&buffer_v);
 }
 */

- (void)adjustPixelBuffer:(CVPixelBufferRef)inputBuffer toOutputBuffer:(CVPixelBufferRef)outputBuffer {
    CVPixelBufferLockBaseAddress(inputBuffer, kCVPixelBufferLock_ReadOnly);
    [GlobalCIImage sharedSingleton].ciImage = [CIImage imageWithCVPixelBuffer:inputBuffer];
    /*
    UIImage *uiimage = [UIImage imageWithCIImage:img];
    if (self.equalizeSwitch.on)
        uiimage = [uiimage equalize];
    if (self.stretchSwitch.on)
        uiimage = [uiimage stretchContrast];
    img = [CIImage imageWithCGImage:uiimage.CGImage];
    */
    //CIImage *inputImg = [CIImage imageWithCVPixelBuffer:inputBuffer];
    
    //[GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"StretchContrastAverage" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage; // img = [img stretchContrast];
    
    if (self.gaussianBlurSlider.value != 0.0)
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"GaussianKernel" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputRadius", [NSNumber numberWithFloat:self.gaussianBlurSlider.value], nil].outputImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [self controlColor:[GlobalCIImage sharedSingleton].ciImage];
    
    if (self.edgeSwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [self convolution:[GlobalCIImage sharedSingleton].ciImage];
    
    [self.ciFilter setValue:[GlobalCIImage sharedSingleton].ciImage forKey:kCIInputImageKey];
    [GlobalCIImage sharedSingleton].ciImage = self.ciFilter.outputImage;
    
    if (self.morphologySwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [self morph:[GlobalCIImage sharedSingleton].ciImage];
        
    if ([self.neighborhoodOperatorPickerView selectedRowInComponent:0] != 0)
    {
        [GlobalCIImage sharedSingleton].ciImage = [self applyDirectionalMean:[GlobalCIImage sharedSingleton].ciImage];
        /*
        float thresholdType = [NSNumber numberWithInteger:self.thresholdSegmentedControl.selectedSegmentIndex].floatValue;
        img = [CIFilter filterWithName:@"LocalAdaptiveThreshold" keysAndValues:kCIInputImageKey, img, @"inputThresholdType", [NSNumber numberWithFloat:thresholdType], nil].outputImage;
        */
    }

    [GlobalCIImage sharedSingleton].ciImage = [self postControlColor:[GlobalCIImage sharedSingleton].ciImage];
    
    if (self.toneCurveSwitch.on)
        [GlobalCIImage sharedSingleton].ciImage = [self toneCurve:[GlobalCIImage sharedSingleton].ciImage];
    
    [GlobalCIImage sharedSingleton].ciImage = [self blend:[GlobalCIImage sharedSingleton].ciImage];
    
    [GlobalCIImage sharedSingleton].ciImage = [self adjustCurves:[GlobalCIImage sharedSingleton].ciImage];
    
    int orientation = [self orientationFromImageOrientation:self.inputImage.imageOrientation];
    [GlobalCIImage sharedSingleton].ciImage = [[GlobalCIImage sharedSingleton].ciImage imageByApplyingOrientation:orientation];
    [[GlobalContext sharedSingleton].ciContext render:[GlobalCIImage sharedSingleton].ciImage toCVPixelBuffer:outputBuffer];
    CVPixelBufferUnlockBaseAddress(inputBuffer, 0);
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.availableFilterInfos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *filterInfo = self.availableFilterInfos[indexPath.item];
    NSString *displayName = filterInfo[kFilterInfoDisplayNameKey];
    NSString *previewImageName = filterInfo[kFilterInfoPreviewImageKey];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoFilterCell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:999];
    imageView.image = [UIImage imageNamed:previewImageName];
    
    UILabel *label = (UILabel *)[cell viewWithTag:998];
    label.text = displayName;
    
    [self updateSelectionForCell:cell];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedFilterName = self.availableFilterInfos[indexPath.item][kFilterInfoFilterNameKey];
    [self updateFilter];
    [self updateSelectionForCell:[collectionView cellForItemAtIndexPath:indexPath]];
    [self updateFilterPreview];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self updateSelectionForCell:[collectionView cellForItemAtIndexPath:indexPath]];
}

- (void)updateSelectionForCell:(UICollectionViewCell *)cell {
    BOOL isSelected = cell.selected;
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:999];
    imageView.layer.borderColor = self.view.tintColor.CGColor;
    imageView.layer.borderWidth = isSelected ? 2.0 : 0.0;
    
    UILabel *label = (UILabel *)[cell viewWithTag:998];
    label.textColor = isSelected ? self.view.tintColor : [UIColor whiteColor];
}

#pragma mark - Utilities

// Returns the EXIF/TIFF orientation value corresponding to the given UIImageOrientation value.
- (int)orientationFromImageOrientation:(UIImageOrientation)imageOrientation {
    int orientation = 0;
    switch (imageOrientation) {
        case UIImageOrientationUp:            orientation = 1; break;
        case UIImageOrientationDown:          orientation = 3; break;
        case UIImageOrientationLeft:          orientation = 8; break;
        case UIImageOrientationRight:         orientation = 6; break;
        case UIImageOrientationUpMirrored:    orientation = 2; break;
        case UIImageOrientationDownMirrored:  orientation = 4; break;
        case UIImageOrientationLeftMirrored:  orientation = 5; break;
        case UIImageOrientationRightMirrored: orientation = 7; break;
        default: break;
    }
    return orientation;
}

- (UIImage *)imageForAVAsset:(AVAsset *)avAsset atTime:(NSTimeInterval)time {
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:avAsset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CGImageRef posterImage = [imageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(time, 100) actualTime:NULL error:NULL];
    UIImage *image = [UIImage imageWithCGImage:posterImage];
    CGImageRelease(posterImage);
    return image;
}

- (IBAction)skim:(UIStepper *)sender {
    float previewTime = self.skimStepper.value;
    /*self.timecodeLabel.text = [NSString stringWithFormat:@"%2.1fs", previewTime];*/
    if (self.contentEditingInput.mediaType == PHAssetMediaTypeVideo) {
        self.inputImage = [self imageForAVAsset:self.contentEditingInput.avAsset atTime:previewTime];
        [self updateFilter];
        [self updateFilterPreview];
    }
}

- (IBAction)adjustGamma:(UIStepper *)sender {
    self.gammaValueLabel.text = [NSString stringWithFormat:@"%2.2f", self.gammaStepper.value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)adjustEV:(UIStepper *)sender {
    self.exposureValueLabel.text = [NSString stringWithFormat:@"%2.2f", self.exposureStepper.value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)adjustContrast:(UIStepper *)sender {
    self.contrastValueLabel.text = [NSString stringWithFormat:@"%2.2f", self.contrastStepper.value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)adjustSaturation:(UIStepper *)sender {
    self.saturationValueLabel.text = [NSString stringWithFormat:@"%2.2f", self.saturationStepper.value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)adjustBrightness:(UIStepper *)sender {
    self.brightnessValueLabel.text = [NSString stringWithFormat:@"%2.2f", self.brightnessStepper.value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)controlColors:(UISegmentedControl *)sender {
    UISegmentedControl *control = sender;
    self.colorControlView.hidden = ( control.selectedSegmentIndex == 1 ) ? NO : YES;
    self.morphologyView.hidden = ( control.selectedSegmentIndex == 2 ) ? NO : YES;
    self.blendModeView.hidden = ( control.selectedSegmentIndex == 3 ) ? NO : YES;
    self.directionalMeanView.hidden = ( control.selectedSegmentIndex == 4 ) ? NO : YES;
    self.levelsView.hidden = ( control.selectedSegmentIndex == 5 ) ? NO : YES;
    self.edgeView.hidden = ( control.selectedSegmentIndex == 6 ) ? NO : YES;
    self.ToneView.hidden = ( control.selectedSegmentIndex == 7 ) ? NO : YES;
}
- (IBAction)toggleOpenClose:(UISegmentedControl *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)iterateErosion:(UIStepper *)sender {
    float iterations = sender.value;
    self.erodeIterationsLabel.text = [NSString stringWithFormat:@"%1.0f", iterations];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)iterateDilation:(UIStepper *)sender {
    float iterations = sender.value;
    self.dilateIterationsLabel.text = [NSString stringWithFormat:@"%1.0f", iterations];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)equalize:(UISwitch *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)stretch:(UISwitch *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)sRGB:(UISwitch *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}

- (IBAction)setErodeRadius:(UIStepper *)sender {
    float radius = sender.value;
    self.erodeRadiusLabel.text = [NSString stringWithFormat:@"%1.0fx%1.0f", radius, radius];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)setDilateRadius:(UIStepper *)sender {
    float radius = sender.value;
    self.dilateRadiusLabel.text = [NSString stringWithFormat:@"%1.0fx%1.0f", radius, radius];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)activateMorphology:(UISwitch *)sender {
    if (self.morphologySwitch.on)
    {
        // enable components
    } else {
        // disable components
    }
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)setMorphologyBlendMode:(UISegmentedControl *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)chooseErodeShape:(UISegmentedControl *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)chooseDilateShape:(UISegmentedControl *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)subtract:(UISwitch *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)difference:(UISwitch *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)overlay:(UISwitch *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)invert:(UISwitch *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)multiply:(UISwitch *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)screen:(UISwitch *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)setNorthRadius:(UIStepper *)sender {
    if ([self.neighborhoodOperatorPickerView selectedRowInComponent:0] != 0)
    {
        float northRadius = sender.value;
        self.northLabel.text = [NSString stringWithFormat:@"%1.0f", northRadius];
        [self updateFilter];
        [self updateFilterPreview];
    }
}

- (IBAction)setEastRadius:(UIStepper *)sender {
    if ([self.neighborhoodOperatorPickerView selectedRowInComponent:0] != 0)
    {
        float eastRadius = sender.value;
        self.eastLabel.text = [NSString stringWithFormat:@"%1.0f", eastRadius];
        [self updateFilter];
        [self updateFilterPreview];
    }
}

- (IBAction)setSouthRadius:(UIStepper *)sender {
    if ([self.neighborhoodOperatorPickerView selectedRowInComponent:0] != 0)
    {
        float southRadius = sender.value;
        self.southLabel.text = [NSString stringWithFormat:@"%1.0f", southRadius];
        [self updateFilter];
        [self updateFilterPreview];
    }
}

- (IBAction)setWestRadius:(UIStepper *)sender {
    if ([self.neighborhoodOperatorPickerView selectedRowInComponent:0] != 0)
    {
        float westRadius = sender.value;
        self.westLabel.text = [NSString stringWithFormat:@"%1.0f", westRadius];
        [self updateFilter];
        [self updateFilterPreview];
    }
}
- (IBAction)setInputMin:(UISlider *)sender {
    float labelValue = sender.value;
    self.inputMinLabel.text = [NSString stringWithFormat:@"Input Min: %1.2f", labelValue];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)setGamma:(UISlider *)sender {
    float labelValue = sender.value;
    self.gammaLabel.text = [NSString stringWithFormat:@"Gamma: %1.2f", labelValue];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)setInputMax:(UISlider *)sender {
    float labelValue = sender.value;
    self.inputMaxLabel.text = [NSString stringWithFormat:@"Input Max: %1.2f", labelValue];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)setOutputMin:(UISlider *)sender {
    float labelValue = sender.value;
    self.outputMinLabel.text = [NSString stringWithFormat:@"Output Min: %1.2f", labelValue];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)setOutputMax:(UISlider *)sender {
    float labelValue = sender.value;
    self.outputMaxLabel.text = [NSString stringWithFormat:@"Output Max: %1.2f", labelValue];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)resetLevels:(UIButton *)sender {
    [self.inputMinSlider setValue:0 animated:TRUE];
    self.inputMinLabel.text = [NSString stringWithFormat:@"Input Min: 0.0"];
    [self.gammaSlider setValue:1 animated:TRUE];
    self.gammaLabel.text = [NSString stringWithFormat:@"Gamma: 1.0"];
    [self.inputMaxSlider setValue:1 animated:TRUE];
    self.inputMaxLabel.text = [NSString stringWithFormat:@"Input Max: 1.0"];
    [self.outputMinSlider setValue:0 animated:TRUE];
    self.outputMinLabel.text = [NSString stringWithFormat:@"Output Min: 0.0"];
    [self.outputMaxSlider setValue:1 animated:TRUE];
    self.outputMaxLabel.text = [NSString stringWithFormat:@"Output Max: 1.0"];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)resetColorControls:(UIButton *)sender {
    self.saturationStepper.value = 1.0;
    self.saturationValueLabel.text = [NSString stringWithFormat:@"%2.2f", self.saturationStepper.value];
    self.brightnessStepper.value = 0.0;
    self.brightnessValueLabel.text = [NSString stringWithFormat:@"%2.2f", self.brightnessStepper.value];
    self.contrastStepper.value = 1.0;
    self.contrastValueLabel.text = [NSString stringWithFormat:@"%2.2f", self.contrastStepper.value];
    self.gammaStepper.value = 0.75;
    self.gammaValueLabel.text = [NSString stringWithFormat:@"%2.2f", self.gammaStepper.value];
    self.exposureStepper.value = 0.0;
    self.exposureValueLabel.text = [NSString stringWithFormat:@"%2.2f", self.exposureStepper.value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self updateFilter];
    [self updateFilterPreview];
}

// UITextField/Hide Keyboard code added here
- (BOOL)textFieldShouldReturn:(nonnull UITextField *)textField
{
    [self updateFilter];
    [self updateFilterPreview];
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)toggleEdge:(UISwitch *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)iterateANDWP:(UIStepper *)sender {
    float iterations = sender.value;
    self.andwpIterationsLabel.text = [NSString stringWithFormat:@"%1.0f", iterations];
    [self updateFilter];
    [self updateFilterPreview];
}

- (IBAction)setCompassGradient:(UISegmentedControl *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)setUnits:(UISegmentedControl *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)resetToneCurve:(UIButton *)sender {
    self.X1.value = 0.0;
    self.Y1.value = 0.0;
    self.X2.value = 0.25;
    self.Y2.value = 0.25;
    self.X3.value = 0.5;
    self.Y3.value = 0.5;
    self.X4.value = 0.75;
    self.Y4.value = 0.75;
    self.X5.value = 1.0;
    self.Y5.value = 1.0;
    self.X1Label.text = [NSString stringWithFormat:@"%3.2f", 0.0];
    self.Y1Label.text = [NSString stringWithFormat:@"%3.2f", 0.0];
    self.X2Label.text = [NSString stringWithFormat:@"%3.2f", 0.25];
    self.Y2Label.text = [NSString stringWithFormat:@"%3.2f", 0.25];
    self.X3Label.text = [NSString stringWithFormat:@"%3.2f", 0.5];
    self.Y3Label.text = [NSString stringWithFormat:@"%3.2f", 0.5];
    self.X4Label.text = [NSString stringWithFormat:@"%3.2f", 0.75];
    self.Y4Label.text = [NSString stringWithFormat:@"%3.2f", 0.75];
    self.X5Label.text = [NSString stringWithFormat:@"%3.2f", 1.0];
    self.Y5Label.text = [NSString stringWithFormat:@"%3.2f", 1.0];
    [self updateFilter];
    [self updateFilterPreview];    
}

- (IBAction)curveTones:(UISwitch *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)X1set:(UIStepper *)sender {
    float value = sender.value;
    self.X1Label.text = [NSString stringWithFormat:@"%3.2f", value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)Y1set:(UIStepper *)sender {
    float value = sender.value;
    self.Y1Label.text = [NSString stringWithFormat:@"%3.2f", value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)X2set:(UIStepper *)sender {
    float value = sender.value;
    self.X2Label.text = [NSString stringWithFormat:@"%3.2f", value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)Y2set:(UIStepper *)sender {
    float value = sender.value;
    self.Y2Label.text = [NSString stringWithFormat:@"%3.2f", value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)X3set:(UIStepper *)sender {
    float value = sender.value;
    self.X3Label.text = [NSString stringWithFormat:@"%3.2f", value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)Y3set:(UIStepper *)sender {
    float value = sender.value;
    self.Y3Label.text = [NSString stringWithFormat:@"%3.2f", value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)X4set:(UIStepper *)sender {
    float value = sender.value;
    self.X4Label.text = [NSString stringWithFormat:@"%3.2f", value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)Y4set:(UIStepper *)sender {
    float value = sender.value;
    self.Y4Label.text = [NSString stringWithFormat:@"%3.2f", value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)X5set:(UIStepper *)sender {
    float value = sender.value;
    self.X5Label.text = [NSString stringWithFormat:@"%3.2f", value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)Y5set:(UIStepper *)sender {
    float value = sender.value;
    self.Y5Label.text = [NSString stringWithFormat:@"%3.2f", value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)addition:(UISwitch *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)blendOriginal:(UISwitch *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)blur:(UISlider *)sender {
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)setUpperCurve:(UISlider *)sender {
    float value = sender.value;
    self.maxValueContrastLabel.text = [NSString stringWithFormat:@"%1.1f", value];
    [self updateFilter];
    [self updateFilterPreview];
}
- (IBAction)setLowerCurve:(UISlider *)sender {
    float value = sender.value;
    self.minValueContrastLabel.text = [NSString stringWithFormat:@"%1.1f", value];
    [self updateFilter];
    [self updateFilterPreview];
}

-(void)drawHistogram
{
    // Draw histogram image
    int orientation = [self orientationFromImageOrientation:self.inputImage.imageOrientation];
    
    sharedCIImage.ciImage = [CIImage imageWithCGImage:[self transformedImage:self.inputImage withOrientation:orientation usingFilter:self.ciFilter].CGImage];
    sharedCIImage.ciImage = [sharedCIImage.ciImage imageByApplyingOrientation:orientation];
    sharedCIImage.ciImage = [CIFilter filterWithName:@"CIHistogramDisplayFilter" keysAndValues:kCIInputImageKey, sharedCIImage.ciImage, @"inputHeight", @100.0, @"inputHighLimit", @1.0, @"inputLowLimit", @0.0, nil].outputImage;
    
    if (cgImage2 != nil)
        cgImage2 = nil;
    cgImage2 = [sharedContext.ciContext createCGImage:sharedCIImage.ciImage fromRect:sharedCIImage.ciImage.extent];
    
    UIImage *histogramImage = [UIImage imageWithCGImage:cgImage2];
    self.histogramView.image = histogramImage;
    
    sharedCIImage.ciImage = [CIImage imageWithCGImage:self.inputImage.CGImage];
    sharedCIImage.ciImage = [sharedCIImage.ciImage imageByApplyingOrientation:orientation];
    sharedCIImage.ciImage = [CIFilter filterWithName:@"CIHistogramDisplayFilter" keysAndValues:kCIInputImageKey, sharedCIImage.ciImage, @"inputHeight", @100.0, @"inputHighLimit", @1.0, @"inputLowLimit", @0.0, nil].outputImage;
    
    if (cgImage2 != nil)
        cgImage2 = nil;
    cgImage2 = [sharedContext.ciContext createCGImage:sharedCIImage.ciImage fromRect:sharedCIImage.ciImage.extent];
    UIImage *originalHistogramImage = [UIImage imageWithCGImage:cgImage2];
    self.originalHistogramView.image = originalHistogramImage;
    
    CGImageRelease(cgImage2);
}

- (void)showHoverView:(BOOL)show
{
    // Clear any pending actions.
    [self.viewInactiveTimer invalidate];
    self.viewInactiveTimer = nil;
    
    [UIView animateWithDuration:0.40 animations:^{
        
        if (show)
        {
            [self drawHistogram];
            
            // Fade the view into view by affecting its alpha.
            self.myView.alpha = 1.0f;
            
            // Start the timeout timer for automatically hiding HoverView
            self.viewInactiveTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                                           target:self
                                                                         selector:@selector(timerFired:)
                                                                         userInfo:nil
                                                                          repeats:NO];
        }
        else
        {
            // Fade the view out of view by affecting its alpha.
            self.myView.alpha = 0.0f;
        }
        
    }];
}

// -------------------------------------------------------------------------------
//	timerFired:
//  Called when the viewInactiveTimer fires.
// -------------------------------------------------------------------------------
- (void)timerFired:(NSTimer *)timer
{
    // Time has passed, hide the HoverView.
    [self showHoverView: NO];
}

// -------------------------------------------------------------------------------
//	touchesEnded:withEvent:
//  Called when the user touches our view.
// -------------------------------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[touches anyObject] tapCount] == 1)
        [self showHoverView:(self.myView.alpha != 1.0)];
}

// -------------------------------------------------------------------------------
//	leftAction:
//  IBAction for the pause button.
// -------------------------------------------------------------------------------
/*
- (IBAction)leftAction:(id)sender
{
    // user touched the left button in HoverView
    [self showHoverView:NO];
}

// -------------------------------------------------------------------------------
//	rightAction:
//  IBAction for the play button.
// -------------------------------------------------------------------------------
- (IBAction)rightAction:(id)sender
{
    [self showHoverView:NO];
}
*/

- (IBAction)equalizeHistogram:(UISwitch *)sender {
    if (self.equalizeHistogramSwitch.on) {
        //[self.inputImage equalize:TRUE];
        [self updateFilter];
        [self updateFilterPreview];
        //[self showHoverView:(self.myView.alpha != 1.0)];
    }
}
- (IBAction)stretchContrast:(UISwitch *)sender {
    if (self.stretchContrastSwitch.on) {
        //[self.inputImage stretchContrast:TRUE];
        [self updateFilter];
        [self updateFilterPreview];
        //[self showHoverView:(self.myView.alpha != 1.0)];
    }
}
@end
