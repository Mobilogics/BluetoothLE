//
//  ViewController.h
//  BLEBarcodeDisplayPeripheral
//
//  Created by Evan Wu on 13/10/14.
//  Copyright (c) 2013年 Evan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class Barcode;

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CBPeripheralManagerDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UILabel *barcodeLabe;
@property (nonatomic, retain) NSMutableArray *barcodeStrings;

@end

@interface Barcode : NSObject

@property (nonatomic, retain) NSString *barcode;
@property (nonatomic, retain) NSDate *date;

@end