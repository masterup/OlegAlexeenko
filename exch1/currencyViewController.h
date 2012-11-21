//
//  currencyViewController.h
//  exch1
//
//  Created by Администратор on 18.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Currency.h"

@interface currencyViewController : UITableViewController{
    
    NSMutableData *rssData;
    NSMutableArray *news;
    NSMutableString *fullName;
    NSMutableString *shortName;
    NSNumber *value;
    NSMutableDictionary *dict;
    
    NSManagedObjectContext *context;
    NSPersistentStoreCoordinator *store;
    NSManagedObjectModel *model;
}
@property (nonatomic, retain) NSMutableArray *news;

@end


