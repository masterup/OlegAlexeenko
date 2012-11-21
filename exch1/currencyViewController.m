//
//  currencyViewController.m
//  exch1
//
//  Created by Администратор on 18.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "currencyViewController.h"
#import <CoreData/CoreData.h>
#import "Currency.h"

@interface currencyViewController ()

@end

@implementation currencyViewController
@synthesize news;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURL *url = [NSURL URLWithString:
                  @"https://privat24.privatbank.ua/p24/accountorder?oper=prp&PUREXML&apicour&country=&full"];
    self.news = [NSMutableArray array];
    NSXMLParser *rssParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    rssParser.delegate = self;
    [rssParser parse];
    
    model  = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Currency.sqlite"];
    //NSLog(@"%@", filePath);
    store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSError *error;
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:filePath] options:nil error:&error];
    context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:store];
    [context save:&error];
    /*  NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                           timeoutInterval:60];
                           
                           NSURLConnection*theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
                           if (theConnection) {
                           self.rssData = [NSMutableData data];
                           } else {
                           NSLog(@"`````Connection failed");
                           }
                           
                           [theConnection release];  */
}
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

/*- (NSFetchedResultsController *)fetchedResultsController
  {
  if (_fetchedResultsController != nil) {
  return _fetchedResultsController;
  }
  
  // Create and configure a fetch request with the Book entity.
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext:cont];
  [fetchRequest setEntity:entity];
  NSLog(@",,%@", entity);
  
  // Create the sort descriptors array.
  NSSortDescriptor *authorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"currency" ascending:YES];
  
  NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:authorDescriptor, nil];
  [fetchRequest setSortDescriptors:sortDescriptors];
  
  // Create and initialize the fetch results controller.
  _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:cont sectionNameKeyPath:@"currency" cacheName:nil];
  _fetchedResultsController.delegate = self;
  
  // Memory management.
  
  return _fetchedResultsController;
  }*/

/*- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
 [rssData appendData:data];
 NSLog(@"+++++rssData");
 }
 
 - (void)connectionDidFinishLoading:(NSURLConnection *)connection {
 NSString *result = [[NSString alloc] initWithData:rssData encoding:NSUTF8StringEncoding];
 NSLog(@"-----%@",result);
 [result release];
 
 self.news = [NSMutableArray array];
 NSXMLParser *rssParser = [[NSXMLParser alloc] initWithData:rssData];
 rssParser.delegate = self;
 [rssParser parse];
 
 [rssParser release];
 }
 
 - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
 NSLog(@"%@", error);
 }
 
 - (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
 NSLog(@"%@", parseError);
 }*/
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict  {
    
    fullName = [attributeDict objectForKey:@"ccy_name_ru"];
    NSString *date = [attributeDict objectForKey:@"date"];
    shortName =[attributeDict objectForKey:@"ccy"];
    value = [NSNumber numberWithFloat:[[attributeDict objectForKey:@"buy"]
                                       floatValue]/(10000*[[attributeDict objectForKey:@"unit"] floatValue])];
    
    NSDictionary *newsItem =[NSDictionary dictionaryWithObjectsAndKeys:fullName, @"2", shortName, @"1", value, @"3", nil];
    [news addObject:newsItem];
    self.navigationController.navigationBar.tintColor = [UIColor blueColor];
    self.tableView.separatorColor =  [UIColor yellowColor];
    self.tableView.rowHeight = 38;
    NSString *myTitle = [NSString stringWithFormat:@"Курс гривны на %@" ,date];
    self.title = myTitle;
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [news count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
    }
    
    Currency *curency = [NSEntityDescription insertNewObjectForEntityForName:@"Currency" inManagedObjectContext:context];
    curency.currency =[NSString stringWithFormat:@"%@" ,[[news objectAtIndex:indexPath.row] objectForKey:@"2"]];
    curency.value = [NSString stringWithFormat:@"1 %@ = %@ грв" ,
                     [[news objectAtIndex:indexPath.row] objectForKey:@"1"],
                     [[news objectAtIndex:indexPath.row] objectForKey:@"3"]] ;
    //NSLog(@"--%@", curr);
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSError *error;
    NSArray *array= [context executeFetchRequest:request error:&error];
    Currency *currency = [array objectAtIndex:indexPath.row];
    //NSLog(@",,%@", ccc.value);
    cell.textLabel.text =currency.currency;
    //[NSString stringWithFormat:@"%@" ,[[news objectAtIndex:indexPath.row] objectForKey:@"2"]];
    cell.detailTextLabel.text=currency.value;
    /*[NSString stringWithFormat:@"1 %@ = %@ грв" ,
     [[news objectAtIndex:indexPath.row] objectForKey:@"1"],
     [[news objectAtIndex:indexPath.row] objectForKey:@"3"]] ;*/
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = [UIColor blueColor];
    cell.textLabel.textColor = [UIColor blackColor];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
