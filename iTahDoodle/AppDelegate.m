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

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Application delegate callbacks

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Попытка загрузки существующего списка задач из массива, хранящегося на диске.
    NSArray *plist = [NSArray arrayWithContentsOfFile:docPath()];
    if (plist) {
        // Если набор данных существует, он коприруется в переменную экземпляра.
        tasks = [plist mutableCopy];
    } else {
        // В противном случае просто создаем пустой исходный набор.
        tasks = [[NSMutableArray alloc] init];
    }
    
    // Массив tasks пуст?
    if ([tasks count] == 0) {
        // Put some sstrings in it
        [tasks addObject:@"Wolk the dog"];
        [tasks addObject:@"Feed the hogs"];
        [tasks addObject:@"Chop the logs"];
    }
    
    // Создание и настройка экзмемпляра UIWindow
    // Структура CGRect представляет прямоуголник с базовой точкой (x, y) и размерами (width, height)
    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    UIWindow *theWindow = [[UIWindow alloc] initWithFrame:windowFrame];
    UIViewController *vc = [[UIViewController alloc]initWithNibName:nil bundle:nil];
    theWindow.rootViewController = vc;
    self.window = theWindow;
    
    // Определение граничных прямоуголников для трех элементов пользовательского интерфейса.
    // CGRectMake() создает экземпляр CGRect по данным (x, y, width, height)
    CGRect tableFrame = CGRectMake(0, 80, 320, 380);
    CGRect fieldFrame = CGRectMake(20, 40, 200, 31);
    CGRect buttonFrame = CGRectMake(228, 40, 72, 31);
    
    // Создание и настройка табличного представления
    taskTable = [[UITableView alloc] initWithFrame:tableFrame
                                             style:UITableViewStylePlain];
    [taskTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // Назначение текущего объетка источником данных табличного представления
    [taskTable setDataSource:self];
    
    // Создание и настройка текстовго поля для создания новых задач
    taskField = [[UITextField alloc] initWithFrame:fieldFrame];
    [taskField setBorderStyle:UITextBorderStyleRoundedRect];
    [taskField setPlaceholder:@"Type a task, tap Insert"];
    
    //Создание и настройка кнопки Insert в виде прямоуголника с закругленными углами
    insertButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [insertButton setFrame:buttonFrame];
    
    // Работа кнопок снована на механзие обратного вызова типа "приемник/действие". Действие кнопки Insert настраивается на вызов метода -addTask: текущего объекта
    [insertButton addTarget:self
                     action:@selector(addTask:)
           forControlEvents:UIControlEventTouchUpInside];
    
    // Опеределение надписи на кнопке
    [insertButton setTitle:@"Insert"
                  forState:UIControlStateNormal];
    
    //Включение трех элементов пользовательского интерфейса в окно
    [[self window] addSubview:taskTable];
    [[self window] addSubview:taskField];
    [[self window] addSubview:insertButton];
    
    // Заверешение настройки окна и отображение его на экране
    [[self window] setBackgroundColor:[UIColor whiteColor]];
    [[self window] makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
    return [tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Для улучшения быстродействия мы заново используем ячейки, вышедшие за пределы экрана, и возвращаем их с новым содержимым вместо того, чтобы всегда создавть новые ячейки. Сначала мы проверяем, имеется ли ячейка, досупная для повторного использования.
    UITableViewCell *c = [taskTable dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!c) {
        // ... и создаем новую ячейку только в том случае, если доступных ячеек нет.
        c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:@"Cell"];
    }
    
    // Затем ячейка настраивется в соответствии с информацией объекта модели (в нашем случае это массив todoItems)
    NSString *item = [tasks objectAtIndex:[indexPath row]];
    [[c textLabel] setText:item];
    
    return c;
}

- (void)addTask:(id)sender {
    // Получение задачи
    NSString *t = [taskField text];
    // Выход, если поле taskField пусто
    if ([t isEqualToString:@""]) {
        return;
    }
    
    // Включение задачи в рабочий массив
    [tasks addObject:t];
    // Обновление таблицы, чтобы в ней отображался новый элемент
    [taskTable reloadData];
    //Очистка текстового поля
    [taskField setText:@""];
    // Клавиатура убирается с экрана
    [taskField resignFirstResponder];
}

@end
