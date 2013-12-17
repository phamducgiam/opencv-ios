//
//  RootViewController.h
//  Flann
//
//  Created by Pham Duc Giam on 06/12/13.
//  Copyright (c) 2013 Pham Duc Giam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "VideoViewController.h"

@interface RootViewController : UIViewController<UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MBProgressHUDDelegate, VideoViewControllerDelegate>
{
    IBOutlet UITableView *_tableView;
    
    UIBarButtonItem *_bbiCamera;
    dispatch_queue_t _imageQueue;
    bool _queryingImage;
}

@end
