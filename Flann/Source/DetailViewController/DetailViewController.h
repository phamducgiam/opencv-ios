//
//  DetailViewController.h
//  Flann
//
//  Created by Pham Duc Giam on 06/12/13.
//  Copyright (c) 2013 Pham Duc Giam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
{
    IBOutlet UIImageView *_imageView;
}

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSString *filename;

@end
