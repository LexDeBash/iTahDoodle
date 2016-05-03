//
//  AppDelegate.h
//  iTahDoodle
//
//  Created by Alexey Efimov on 03.05.16.
//  Copyright © 2016 Alexey Efimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

{
    UITableView *taskTable;
    UITextField *taskField;
    UIButton *insertButton;
    NSMutableArray *tasks;
}

- (void)addTask: (id)sender;

@property (strong, nonatomic) UIWindow *window;


@end

