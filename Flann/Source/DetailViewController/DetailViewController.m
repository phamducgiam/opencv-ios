//
//  DetailViewController.m
//  Flann
//
//  Created by Pham Duc Giam on 06/12/13.
//  Copyright (c) 2013 Pham Duc Giam. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - constructor/destructor

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - class methods

#pragma mark - override/overload

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _imageView.image = [UIImage imageNamed:self.filename];//[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", self.index]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - instance methods

#pragma mark - get/set methods

#pragma mark - action methods

#pragma mark - delegate methods

@end
