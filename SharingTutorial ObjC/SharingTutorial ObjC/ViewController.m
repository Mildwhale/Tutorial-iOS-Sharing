//
//  ViewController.m
//  SharingTutorial ObjC
//
//  Created by KyuJin Kim on 2017. 2. 21..
//  Copyright (c) 2017년 KyuJin Kim. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (NSArray *)items
{
    return @[@"Video sample resource.", [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"mp4sample" ofType:@"mp4"]]];
}

- (NSArray *)excluded
{
    return nil;
}

- (UIActivityViewController *)avc
{
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:[self items] applicationActivities:nil];
    vc.excludedActivityTypes = [self excluded];
    
    return vc;
}

- (BOOL)isIpad
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

- (BOOL)isSupportedPopoverPresentationController
{
    if ([UIPopoverPresentationController class]) {
        return YES;
    }
    
    return NO;
}

- (UIViewController *)topViewController
{
    UIViewController* rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    if (nil == rootViewController) {
        return nil;
    }
    
    UIViewController* topMostViewController = rootViewController;
    
    while (topMostViewController.presentedViewController) {
        topMostViewController = topMostViewController.presentedViewController;
    }
    
    if([UIAlertController class] != nil) { // UIAlertController class supported on iOS 8.
        if([topMostViewController isKindOfClass:[UIAlertController class]]) {
            topMostViewController = topMostViewController.presentingViewController;
        }
    }
    
    return topMostViewController;
}

#pragma mark - Event listener
- (IBAction)shareFromBarButton:(UIBarButtonItem *)sender
{
    UIActivityViewController *avc = [self avc];
    
    if ([self isIpad]) {
        if ([self isSupportedPopoverPresentationController]) {
            UIPopoverPresentationController *popoverController = avc.popoverPresentationController;
            popoverController.barButtonItem = sender;
            
            [[self topViewController] presentViewController:avc animated:YES completion:nil];
        }
        else {
            UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:avc];
            
            [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else {
        [[self topViewController] presentViewController:avc animated:YES completion:nil];
    }
}

- (IBAction)shareFromUIView:(UIView *)sender
{
    UIActivityViewController *avc = [self avc];
    
    if ([self isIpad]) {
        if ([self isSupportedPopoverPresentationController]) {
            UIPopoverPresentationController *popoverController = avc.popoverPresentationController;
            
            popoverController.sourceView = sender;
            popoverController.sourceRect = sender.bounds;
            
            [[self topViewController] presentViewController:avc animated:YES completion:nil];
        }
        else {
            UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:avc];
            
            [popoverController presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else {
        [[self topViewController] presentViewController:avc animated:YES completion:nil];
    }
}
@end
