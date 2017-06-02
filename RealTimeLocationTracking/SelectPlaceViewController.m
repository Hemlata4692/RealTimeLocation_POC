//
//  SelectPlaceViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "SelectPlaceViewController.h"
#import "SelectPlacesViewCell.h"

@interface SelectPlaceViewController ()<GetAutocompleteResultDelegate> {
    NSArray *searchResultArray;
    NSArray *locationArray;
    BOOL isSearch;
}

@property (weak, nonatomic) IBOutlet UITextField *enterLocationTextField;
@property (weak, nonatomic) IBOutlet UITableView *locationTableView;

@end

@implementation SelectPlaceViewController
@synthesize mapViewObj;
@synthesize directionViewObj;
@synthesize locationManager;
@synthesize isDirectionView;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"Select Place";
    locationArray=[[NSArray alloc]init];
    searchResultArray=[[NSArray alloc]init];
    locationManager = [[LocationObject alloc]init];
    [self addBackButton];
    //Remove extra separators
    [[UITableView appearance] setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - end

#pragma mark - Textfield delegate method
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //Fetch result from entred location
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - end

#pragma mark - Table view delegate and datasource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //Data fetched from autocomplete search
    return searchResultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"placesCell"];
    SelectPlacesViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //Display data fetched from autocomplete search
    [cell displaySearchAutocompleteData:[searchResultArray objectAtIndex:indexPath.row] rectSize:self.locationTableView.frame.size];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Fetch lat,long from selected address
    NSDictionary *autocompleteDict=[searchResultArray objectAtIndex:indexPath.row];
    NSString *descriptionString =autocompleteDict[@"description"];
    [self fetchLatitudeLongitudeFromAddress:descriptionString];
}
#pragma mark - end

#pragma mark - Fetch and display autocomplete results
//Fetch location coordinate from address
- (void) fetchLatitudeLongitudeFromAddress: (NSString *) descriptionString {
    locationManager.delegate = self;
    [locationManager fetchLatitudeLongitudeFromAddress:descriptionString];
}

//Fetch results from autocomplete API
- (void) fetchAutocompleteResult: (NSString *) searchKey {
    locationManager.delegate = self;
    [locationManager fetchAutocompleteResult:searchKey];
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
    if (isDirectionView) {
        directionViewObj.latitude=latLongDict[@"lat"];
        directionViewObj.longitude=latLongDict[@"lng"];
        directionViewObj.autoCompleteLocation=@"2";
        [self.navigationController popToViewController:[array objectAtIndex:0] animated:YES];
    } else {
        mapViewObj.latitude=latLongDict[@"lat"];
        mapViewObj.longitude=latLongDict[@"lng"];
        mapViewObj.otherLocation=@"1";
        [self.navigationController popToViewController:[array objectAtIndex:0] animated:YES];
    }
}
#pragma mark - end

@end
