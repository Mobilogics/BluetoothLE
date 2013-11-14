//
//  ViewController.m
//  BLEBarcodeDisplayPeripheral
//
//  Created by Evan Wu on 13/10/14.
//  Copyright (c) 2013年 Evan Wu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
  CBPeripheralManager     *manager;
  CBMutableService        *customizeService;
  CBMutableService        *buttonService;
  CBMutableCharacteristic *customizeNotifyCharacteristic;
  CBMutableCharacteristic *customizeWrittenCharacteristic;
}

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.barcodeStrings = [[NSMutableArray alloc] initWithCapacity:30];
	manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.barcodeStrings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
  }
  
  Barcode *barcode = self.barcodeStrings[indexPath.row];
  
  [cell.textLabel setText:barcode.barcode];
  [cell.detailTextLabel setText:barcode.date.description];
  
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
  NSLog(@"peripheralManagerDidUpdateState %d (%@)", (int)peripheral.state, [self peripheralManagerStateToString:peripheral.state]);
  
  if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
    [self setupService];
  }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict {
  NSLog(@"peripheralManagerWillRestoreState");
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
  NSLog(@"peripheralManagerDidStartAdvertising");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
  NSLog(@"peripheralManagerDidAddService %@", [self CBUUIDToString:service.UUID]);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
  NSLog(@"%@ didSubscribeToCharacteristic %@ update value %d", [central.identifier UUIDString], [self CBUUIDToString:characteristic.UUID], characteristic.isNotifying);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
  NSLog(@"didUnsubscribeFromCharacteristic %@ update value %d", [self CBUUIDToString:characteristic.UUID], characteristic.isNotifying);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
  NSLog(@"didReceiveReadRequest");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
  NSLog(@"didReceiveWriteRequests");
  
  CBATTRequest *req = (CBATTRequest *)[requests objectAtIndex:0];
  [manager respondToRequest:req withResult:CBATTErrorSuccess];
  
  Barcode *barcode = [[Barcode alloc] init];
  barcode.barcode = [[NSString alloc] initWithData:req.value encoding:NSUTF8StringEncoding];
  barcode.date = [NSDate date];
  [self.barcodeStrings insertObject:barcode atIndex:0];
  [self.tableView reloadData];
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
  NSLog(@"peripheralManagerIsReadyToUpdateSubscribers");
}

#pragma mark - private

- (NSString *)peripheralManagerStateToString:(int)state {
  switch (state) {
    case CBPeripheralManagerStateUnknown:
      return @"CBPeripheralManagerStateUnknown";
      
    case CBPeripheralManagerStateResetting:
      return @"CBPeripheralManagerStateResetting";
      
    case CBPeripheralManagerStateUnsupported:
      return @"CBPeripheralManagerStateUnsupported";
      
    case CBPeripheralManagerStateUnauthorized:
      return @"CBPeripheralManagerStateUnauthorized";
      
    case CBPeripheralManagerStatePoweredOff:
      return @"CBPeripheralManagerStatePoweredOff";
      
    case CBPeripheralManagerStatePoweredOn:
      return @"CBPeripheralManagerStatePoweredOn";
      
    default:
      return @"Unknown state";
  }
  return @"Unknown state";
}

#pragma mark - init service and adv

- (void)setupService {
  customizeWrittenCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"FFE1"] properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:2];
  
  customizeNotifyCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"FFE2"] properties:CBCharacteristicPropertyNotify value:nil permissions:0];
  
  customizeService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:@"FFE0"] primary:YES];
  customizeService.characteristics = @[customizeWrittenCharacteristic, customizeNotifyCharacteristic];
  [manager addService:customizeService];
  
  
  if (manager.isAdvertising) {
    return;
  }
  
  NSArray       *services = @[[CBUUID UUIDWithString:@"FFE0"]];
  NSDictionary  *dict = @{CBAdvertisementDataLocalNameKey : @"Peripheral", CBAdvertisementDataServiceUUIDsKey : services};
  
  [manager startAdvertising:dict];
}

#pragma mark - CBUUID

- (NSString *)UUIDToString:(CFUUIDRef)UUID {
  return (UUID) ? (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, UUID)) : @"";
}

- (NSString *)CBUUIDToString:(CBUUID *)UUID {
  return [NSString stringWithFormat:@"%s", [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]];
}

@end

@implementation Barcode

- (id)init {
	self = [super init];
	if (self) {

	}
	return self;
}

@end