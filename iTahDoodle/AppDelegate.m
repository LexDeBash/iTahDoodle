//
//  AppDelegate.m
//  iTahDoodle
//
//  Created by Alexey Efimov on 03.05.16.
//  Copyright © 2016 Alexey Efimov. All rights reserved.
//

#import "AppDelegate.h"

// Вспомогательная функция для получения пути к списку задач, хранящемуся на диске
NSString *docPath() {
    NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[pathList objectAtIndex:0] stringByAppendingPathComponent:@"data.td"];
}

@implementation AppDelegate

#pragma mark - Application delegate callbacks

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Попытка загрузки существующего списка задач из массива, хранящегося на диске.
    NSArray *plist = [NSArray arrayWithContentsOfFile:docPath()];
    if (plist) {
        // Если набор данных существует, он коприруется в переменную экземпляра.
        self.tasks = [plist mutableCopy];
    } else {
        // В противном случае просто создаем пустой исходный набор.
        self.tasks = [NSMutableArray array];
    }
    
    // Создание и настройка экзмемпляра UIWindow
    // Структура CGRect представляет прямоуголник с базовой точкой (x, y) и размерами (width, height)
    CGRect winFrame = [[UIScreen mainScreen] bounds];
    UIWindow *theWindow = [[UIWindow alloc] initWithFrame:winFrame];
    self.window = theWindow;
    self.window.rootViewController = [[UIViewController alloc] init];

    
    // Определение граничных прямоуголников для трех элементов пользовательского интерфейса.
    // CGRectMake() создает экземпляр CGRect по данным (x, y, width, height)
    CGRect tableFrame = CGRectMake(0, 80, winFrame.size.width, winFrame.size.height-100);
    CGRect fieldFrame = CGRectMake(20, 40, 200, 31);
    CGRect buttonFrame = CGRectMake(228, 40, 72, 31);
    
    // Создание и настройка табличного представления
    self.taskTable = [[UITableView alloc] initWithFrame:tableFrame
                                             style:UITableViewStylePlain];
    self.taskTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Назначение текущего объетка источником данных табличного представления
    self.taskTable.dataSource = self;
    
    // Tell the tableview which class to instantiate whenever it needs to create a new cell
    [self.taskTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    // Создание и настройка текстовго поля для создания новых задач
    self.taskField = [[UITextField alloc] initWithFrame:fieldFrame];
    self.taskField.borderStyle = UITextBorderStyleRoundedRect;
    self.taskField.placeholder = @"Type a task, tap insert";
    
    // Для запуска клавиатуры
    [self.taskField becomeFirstResponder];
    
    //Создание и настройка кнопки Insert в виде прямоуголника с закругленными углами
    self.insertButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.insertButton.frame = buttonFrame;
    
    // Опеределение надписи на кнопке
    [self.insertButton setTitle:@"Insert"
                  forState:UIControlStateNormal];
    
    // Работа кнопок снована на механзие обратного вызова типа "приемник/действие". Действие кнопки Insert настраивается на вызов метода -addTask: текущего объекта
    [self.insertButton addTarget:self
                          action:@selector(addTask:)
                forControlEvents:UIControlEventTouchUpInside];
    
    //Включение трех элементов пользовательского интерфейса в окно
    [self.window.rootViewController.view addSubview:self.insertButton];
    
    [self.window.rootViewController.view addSubview:self.taskTable];
    [self.window.rootViewController.view addSubview:self.taskField];
    
    // Заверешение настройки окна и отображение его на экране
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Этот метод вызывается только в iOS 4.0+
    // Сохраниение массива tasks на диске
    [self.tasks writeToFile:docPath()
                 atomically:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Table View management

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    // Так как данное табличное представление содержит только одну секцию, колчиство строк в ней равно количесту элементов массива tasks
    return [self.tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Для улучшения быстродействия мы заново используем ячейки, вышедшие за пределы экрана, и возвращаем их с новым содержимым вместо того, чтобы всегда создавть новые ячейки. Сначала мы проверяем, имеется ли ячейка, досупная для повторного использования.
    UITableViewCell *cell = [self.taskTable dequeueReusableCellWithIdentifier:@"Cell"];
    
    // (Re)Configure the cell based on the model object (tasks array)
    NSString *item = [self.tasks objectAtIndex:indexPath.row];
    cell.textLabel.text = item;
    
    return cell;
}

#pragma mark - Actions

- (void)addTask:(id)sender {
    
    // Получение задачи
    NSString *text = [self.taskField text];
    
    // Выход, если поле taskField пусто
    if ([text length] == 0) {
        return;
    }
    
    // Включение задачи в рабочий массив
    [self.tasks addObject:text];
    
    // Обновление таблицы, чтобы в ней отображался новый элемент
    [self.taskTable reloadData];
    
    //Очистка текстового поля
    [self.taskField setText:@""];
    
    // Клавиатура убирается с экрана
    [self.taskField resignFirstResponder];
}

@end
