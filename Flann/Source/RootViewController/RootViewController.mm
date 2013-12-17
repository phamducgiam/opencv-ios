//
//  RootViewController.m
//  Flann
//
//  Created by Pham Duc Giam on 06/12/13.
//  Copyright (c) 2013 Pham Duc Giam. All rights reserved.
//

#import "RootViewController.h"
#import <vector>
#include <opencv2/core/core.hpp>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#import "UIImage+Resize.h"
#import "DetailViewController.h"

NSInteger const kImageCount = 18;

@interface RootViewController ()
{
    std::vector<int> _indexes;
    std::vector<std::string> _filenames;
    cv::Mat _features;
    cv::flann::Index _kdtree;
    NSMutableArray *_files;
    
    MBProgressHUD *_HUD;
}

- (void)cameraClicked:(UIBarButtonItem *)sender;

@end

@implementation RootViewController

#pragma mark - constructor/destructor

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        NSString *_imageQueueDescription = [NSString stringWithFormat:@"%@ image queue", self];
        _imageQueue = dispatch_queue_create([_imageQueueDescription UTF8String], NULL);
        _queryingImage = false;
    }
    return self;
}

- (void)dealloc
{
}

#pragma mark - class methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _bbiCamera  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraClicked:)];
    self.navigationItem.leftBarButtonItem = _bbiCamera;
    
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_HUD];
    _HUD.labelText = @"Initializing...";
    [_HUD show:YES];
    
    dispatch_async(_imageQueue, ^{
        
        /*int minHessian = 400;
        cv::SurfFeatureDetector detector(minHessian);
        cv::SurfDescriptorExtractor extractor;
        cv::vector<cv::KeyPoint> keypoints;
        //UIImage *image;
        cv::Mat mat;
        cv::Mat descriptors;
        //cv::Mat features;
        
        int i, k = 0;
        for(i=1;i<=kImageCount;i++) {
            //image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i]];
            //mat = [self cvMatGrayFromUIImage:image];
            
            detector.detect(mat, keypoints);
            extractor.compute(mat, keypoints, descriptors);
            _features.push_back(descriptors);
            _indexes.push_back(k);
            k += descriptors.rows;
        }*/
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"output" ofType:@"yml"];
        cv::FileStorage fs([path UTF8String], cv::FileStorage::READ);
        fs["features"] >> _features;
        fs["filenames"] >> _filenames;
        fs["indexes"] >> _indexes;
        fs.release();
        
        cv::flann::KDTreeIndexParams indexParams(5);
        _kdtree.build(_features, indexParams);
        
        _files = [NSMutableArray arrayWithCapacity:_filenames.size()];
        for (int i=0; i<_filenames.size(); i++) {
            NSString *file = [NSString stringWithUTF8String:_filenames[i].c_str()];
            [_files addObject:file];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_HUD hide:YES];
            
            [_tableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - override/overload

#pragma mark - instance methods

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    cv::Mat grayMat;
    
    cv::cvtColor(cvMat, grayMat, CV_BGR2GRAY);
    
    return grayMat;
}

- (void)compareWithImage:(UIImage *)image
{
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_HUD];
    _HUD.labelText = @"Comparing...";
    [_HUD show:YES];
    
    dispatch_async(_imageQueue, ^{
        int minHessian = 400;
        cv::SurfFeatureDetector detector(minHessian);
        cv::SurfDescriptorExtractor extractor;
        cv::vector<cv::KeyPoint> keypoints;
        cv::Mat mat;
        cv::Mat descriptors;//, descriptors1;
        
        mat = [self cvMatGrayFromUIImage:image];
        
        detector.detect(mat, keypoints);
        extractor.compute(mat, keypoints, descriptors);
        
        NSLog(@"descriptors - %d, %d", descriptors.rows, descriptors.cols);
        
        /*cv::FlannBasedMatcher matcher;
        std::vector<cv::DMatch> matches;
        int i,j,k,n;
        float ratio = 0.0;
        
        for (i=1; i<kImageCount; i++) {
            
            float minDist = 100000.0;
            for (j=0; j<matches.size(); j++) {
                float dist = matches[j].distance;
                if (dist<minDist) {
                    minDist = dist;
                }
            }
            
            k = 0;
            minDist *= 2.0f;
            for (j=0; j<matches.size(); j++) {
                if (matches[j].distance<minDist) {
                    k++;
                }
            }
            
            if (matches.size()>0) {
                float r = 1.0f * k / matches.size();
                NSLog(@"i = %d, minDist = %f, k = %d, ration = %f", i, minDist, k, r);
                if (r>ratio) {
                    n = i;
                    ratio = r;
                }
            }
        }
        
        NSLog(@"Best match - %d, ratio = %f", n, ratio);*/
        
        cv::Mat indices;
        cv::Mat dists;
        
        cv::flann::KDTreeIndexParams indexParams(5);
        cv::flann::Index kdtree(_features, indexParams);
        
        kdtree.knnSearch(descriptors, indices, dists, 2, cv::flann::SearchParams(64));
        
        std::vector<int> matchPoints(kImageCount, 0);
        std::vector<int>::iterator begin = _indexes.begin();
        std::vector<int>::iterator end = _indexes.end();
        std::vector<int>::iterator iter;
        
        int i,j,k;
        for (i=0; i<indices.rows; i++) {
            if (dists.at<float>(i, 0) < 0.6f * dists.at<float>(i, 1)) {
                k = indices.at<int>(i, 0);
                iter = std::upper_bound(begin, end, k);
                if (iter!=end) {
                    j = (int)(iter - begin) - 1;
                    matchPoints[j]++;
                }
                /*else {
                    //matchPoints[kImageCount-1]++;
                }*/
            }
        }
        
        k = 0;
        for (i=0; i<matchPoints.size(); i++) {
            if (matchPoints[i]>k) {
                k = matchPoints[i];
                j = i;
            }
        }
        
        NSLog(@"match image - %d, number of match points - %d", j, k);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_HUD hide:YES];
            
            [self didCompareWithMatchImageIndex:j numberMatchPoints:k];
        });
    });
}

- (void)compareWithCvImage:(cv::Mat)image
{
    cv::Mat *pImage = new cv::Mat(image.rows, image.cols, image.type());
    cv::cvtColor(image, *pImage, CV_BGR2GRAY);
    
    dispatch_async(_imageQueue, ^{
        
        if (!_queryingImage) {
            return;
        }
        
        /*int minHessian = 400;
        cv::SurfFeatureDetector detector(minHessian);
        cv::SurfDescriptorExtractor extractor;*/
        cv::SiftFeatureDetector detector;
        cv::SiftDescriptorExtractor extractor;
        cv::vector<cv::KeyPoint> keypoints;
        cv::Mat descriptors;
        
        detector.detect(*pImage, keypoints);
        extractor.compute(*pImage, keypoints, descriptors);
        delete pImage;
        
        cv::Mat indices;
        cv::Mat dists;
        
        NSLog(@"type - %d", descriptors.type());
        if (descriptors.type()!=_features.type()) {
            return;
        }
        _kdtree.knnSearch(descriptors, indices, dists, 2, cv::flann::SearchParams(64));
        
        std::vector<int> matchPoints(_indexes.size(), 0);
        std::vector<int>::iterator begin = _indexes.begin();
        std::vector<int>::iterator end = _indexes.end();
        std::vector<int>::iterator iter;
        
        int i,j,k;
        for (i=0; i<indices.rows; i++) {
            if (dists.at<float>(i, 0) < 0.6f * dists.at<float>(i, 1)) {
                k = indices.at<int>(i, 0);
                iter = std::lower_bound(begin, end, k);
                if (iter!=end) {
                    j = (int)(iter - begin) - 1;
                    matchPoints[j]++;
                }
                else {
                    matchPoints[_indexes.size()-1]++;
                }
            }
        }
        
        k = 0;
        for (i=0; i<matchPoints.size(); i++) {
            if (matchPoints[i]>k) {
                k = matchPoints[i];
                j = i;
            }
        }
        
        NSLog(@"match image - %d, number of match points - %d", j, k);
        
        if (k>=5 && j>=0 && j<_filenames.size()) {
            std::string filename = _filenames[j];
            NSString *file = [NSString stringWithUTF8String:filename.c_str()];
            NSLog(@"filename - %@", file);
            _queryingImage = false;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self didFindImage:file];
            });
        }
    });
}

- (void)didCompareWithMatchImageIndex:(NSInteger)index numberMatchPoints:(NSInteger)number
{
    if (number>10) {
        DetailViewController *viewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        std::string filename = _filenames[index];
        NSString *file = [NSString stringWithUTF8String:filename.c_str()];
        NSLog(@"filename - %@", file);
        viewController.filename = file;
        //viewController.index = index;
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Could not find similar image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)didFindImage:(NSString *)filename
{
    [self dismissModalViewControllerAnimated:NO];
    
    DetailViewController *viewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    viewController.filename = filename;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - get/set methods

#pragma mark - action methods

- (void)cameraClicked:(UIBarButtonItem *)sender
{
    /*UIImagePickerController *viewController = [[UIImagePickerController alloc] init];
    viewController.sourceType = UIImagePickerControllerSourceTypeCamera;
    viewController.delegate = self;*/
    
    _queryingImage = true;
    VideoViewController *viewController = [[VideoViewController alloc] initWithNibName:@"VideoViewController" bundle:nil];
    viewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self presentModalViewController:navigationController animated:YES];
}

#pragma mark - delegate methods

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        if (_files) {
            return [_files count];
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *file = _files[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:file];
    cell.textLabel.text = file;
    
    return cell;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        CGFloat width = 320.0f;
        CGFloat height = roundf(width * image.size.height / image.size.width);
        image = [image resizedImageToSize:CGSizeMake(width, height)];
        
        [self compareWithImage:image];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if (hud==_HUD) {
        [_HUD removeFromSuperview];
        _HUD = nil;
    }
}

#pragma mark - VideoViewControllerDelegate

- (void)videoViewController:(VideoViewController *)videoViewController didGetImage:(cv::Mat)image
{
    [self compareWithCvImage:image];
}

- (void)videoViewControllerDidCancel:(VideoViewController *)videoViewController
{
    _queryingImage = false;
    [self dismissModalViewControllerAnimated:YES];
}

@end
