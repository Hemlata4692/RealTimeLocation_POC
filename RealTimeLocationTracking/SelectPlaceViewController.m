//
//  SelectPlaceViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "SelectPlaceViewController.h"
#import "SelectPlacesViewCell.h"

@interface SelectPlaceViewController ()<getAutocompleteResultDelegate> {
    NSArray *searchResultArray;
    NSArray *locationArray;
    BOOL isSearch;
}
@property (weak, nonatomic) IBOutlet UITextField *enterLocationTextField;
@property (weak, nonatomic) IBOutlet UITableView *locationTableView;
@end

@implementation SelectPlaceViewController
@synthesize MapViewObj;
@synthesize DirectionViewObj;

#pragma mark - Life cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.title=@"Select Place";
    locationArray=[[NSArray alloc]init];
    searchResultArray=[[NSArray alloc]init];
    _locationManager = [[LocationObject alloc]init];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Textfield delegate method
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //fetch result from entred location
    NSString *searchKey;
    if([string isEqualToString:@"\n"]) {
        searchKey = textField.text;
    }
    else if(string.length) {
        isSearch = YES;
        searchKey = [textField.text stringByAppendingString:string];
        [self fetchAutocompleteResult:searchKey];
    }
    else if((textField.text.length-1)!=0) {
        searchKey = [textField.text substringWithRange:NSMakeRange(0, textField.text.length-1)];
        [self fetchAutocompleteResult:searchKey];
    }
    else {
        searchKey = @"";
        isSearch = NO;
        [self.locationTableView reloadData];
    }
    return YES;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
    
}
#pragma mark - end

#pragma mark - Table view delegate and datasource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //data fetched from autocomplete search
    return searchResultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"placesCell"];
    SelectPlacesViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //display data fetched from autocomplete search
    [cell displaySearchAutocompleteData:[searchResultArray objectAtIndex:indexPath.row] rectSize:self.locationTableView.frame.size];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //fetch lat,long from selected address
    NSDictionary *autocompleteDict=[searchResultArray objectAtIndex:indexPath.row];
    NSString *descriptionString =autocompleteDict[@"description"];
    [self fetchLatitudeLongitudeFromAddress:descriptionString];
    
}
#pragma mark - end

#pragma mark - Fetch and display autocomplete results
//Fetch location coordinate from address
- (void) fetchLatitudeLongitudeFromAddress: (NSString *) descriptionString {
    
    _locationManager.delegate = self;
    [_locationManager fetchLatitudeLongitudeFromAddress:descriptionString];
}

//Fetch results from autocomplete API
- (void) fetchAutocompleteResult: (NSString *) searchKey {
    
    _locationManager.delegate = self;
    [_locationManager fetchAutocompleteResult:searchKey];
    
}

//Display autocomplete results
- (void)returnAutocompleteSearchResults:(NSDictionary *)jsonResult isSearchValue:(BOOL)isSearchValue {
    
    if (isSearchValue) {
        searchResultArray = [jsonResult objectForKey:@"predictions"];
        [self.locationTableView reloadData];
        
    } else {
        locationArray = [jsonResult objectForKey:@"results"];
        [self parseLatLongFromArray:[locationArray objectAtIndex:0]];
    }
    
}

//Pop to map view woth search results
- (void)parseLatLongFromArray:(NSDictionary *)locationDict {
    
    NSDictionary *tempDict=locationDict[@"geometry"];
    NSDictionary * latLongDict =tempDict[@"location"];
    
    NSArray *array = [self.navigationController viewControllers];
    
    if (_isDirectionView) {
        DirectionViewObj.latitude=latLongDict[@"lat"];
        DirectionViewObj.longitude=latLongDict[@"lng"];
        DirectionViewObj.autoCompleteLocation=@"2";
        [self.navigationController popToViewController:[array objectAtIndex:2] animated:YES];
    } else {
        MapViewObj.latitude=latLongDict[@"lat"];
        MapViewObj.longitude=latLongDict[@"lng"];
        MapViewObj.otherLocation=@"1";
        [self.navigationController popToViewController:[array objectAtIndex:1] animated:YES];
    }
}
#pragma mark - end

@end
