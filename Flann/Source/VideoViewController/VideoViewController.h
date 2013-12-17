//
//  VideoViewController.h
//  Flann
//
//  Created by Pham Duc Giam on 06/12/13.
//  Copyright (c) 2013 Pham Duc Giam. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __cplusplus
#include <opencv2/opencv.hpp>
#endif

#import <opencv2/highgui/cap_ios.h>

@class VideoViewController;

@protocol VideoViewControllerDelegate <NSObject>

#ifdef __cplusplus
- (void)videoViewController:(VideoViewController *)videoViewController didGetImage:(cv::Mat)image;
#endif

- (void)videoViewControllerDidCancel:(VideoViewController *)videoViewController;

@end

@interface VideoViewController : UIViewController<CvVideoCameraDelegate>
{
    IBOutlet UIImageView *_imageView;
    UIBarButtonItem *_bbiCancel;
    
    CvVideoCamera *_videoCamera;
}

@property (nonatomic, weak) id<VideoViewControllerDelegate> delegate;
@property (nonatomic, readwrite) double minContourArea;

@end
