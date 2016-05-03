//
//  AppDelegate.h
//  iTahDoodle
//
//  Created by Alexey Efimov on 03.05.16.
//  Copyright © 2016 Alexey Efimov. All rights reserved.
//

#import <UIKit/UIKit.h>

// Объявление вспомогательной функции для получения пути к каталогу на диске, который будет использоваться для сохранения списка задач
NSString *docPath(void);

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) UITableView *taskTable;
@property (nonatomic) UITextField *taskField;
@property (nonatomic) UIButton *insertButton;

@property (nonatomic) NSMutableArray *tasks;

- (void)addTask: (id)sender;

@end

