//
//  VideoViewController.m
//  Flann
//
//  Created by Pham Duc Giam on 06/12/13.
//  Copyright (c) 2013 Pham Duc Giam. All rights reserved.
//

#import "VideoViewController.h"

double const kMinContourArea = 2500.0;

@interface VideoViewController ()

- (void)cancelClicked:(UIBarButtonItem *)sender;

@end

@implementation VideoViewController

#pragma mark - constructor/destructor

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _minContourArea = kMinContourArea;
    }
    return self;
}

#pragma mark - class methods

#pragma mark - override/overload

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Video";
    
    _bbiCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClicked:)];
    self.navigationItem.rightBarButtonItem = _bbiCancel;
    
    _videoCamera = [[CvVideoCamera alloc] initWithParentView:_imageView];
    _videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    _videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    _videoCamera.defaultFPS = 30;
    _videoCamera.grayscaleMode = NO;
    _videoCamera.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_videoCamera start];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_videoCamera stop];
}

#pragma mark - instance methods

#pragma mark - get/set methods

#pragma mark - action methods

- (void)cancelClicked:(UIBarButtonItem *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoViewControllerDidCancel:)]) {
        [self.delegate videoViewControllerDidCancel:self];
    }
}

#pragma mark - delegate methods

#pragma mark - CvVideoCameraDelegate

- (void)processImage:(cv::Mat&)image
{
    cv::Mat grayImage;
    cv::cvtColor(image, grayImage, CV_BGR2GRAY);
    cv::Canny(grayImage, grayImage, 100.0, 200.0);
    cv::vector<cv::vector<cv::Point>> contours;
    cv::findContours(grayImage, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    cv::Mat mask = cv::Mat::zeros(image.rows, image.cols, image.type());
    
    cv::vector<double> areas(contours.size());
    for (int i=0; i<contours.size(); i++) {
        areas[i] = cv::contourArea(contours[i]);
    }
    double max;
    cv::Point maxPosition;
    cv::minMaxLoc(cv::Mat(areas), 0, &max, 0, &maxPosition);
    if (max>=self.minContourArea) {
        cv::drawContours(mask, contours, maxPosition.y, cv::Scalar(255,0,0), 5);
        image += mask;
        
        if (maxPosition.y>=0 && maxPosition.y<contours.size()) {
            cv::Rect rect = cv::boundingRect(contours[maxPosition.y]);
            cv::Mat result = image(rect);
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoViewController:didGetImage:)]) {
                [self.delegate videoViewController:self didGetImage:result];
            }
        }
    }
}

@end
