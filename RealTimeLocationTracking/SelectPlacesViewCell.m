//
//  SelectPlacesViewCell.m
//  MyTake
//
//  Created by Hema on 23/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "SelectPlacesViewCell.h"

@implementation SelectPlacesViewCell

@synthesize placeName;
@synthesize placeAddress;

#pragma mark - Load nib
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
#pragma mark - end

#pragma mark - display data from autocomplete api
- (void)displaySearchAutocompleteData:(NSDictionary*)autocompleteDict rectSize:(CGSize)rectSize {
    placeName.translatesAutoresizingMaskIntoConstraints=YES;
    placeAddress.translatesAutoresizingMaskIntoConstraints=YES;
    placeName.frame =CGRectMake(38, 15, rectSize.width-50, placeName.frame.size.height);
    placeAddress.frame =CGRectMake(38, placeName.frame.origin.y+placeName.frame.size.height+4, rectSize.width-50, placeAddress.frame.size.height);
    NSString *descriptionString =autocompleteDict[@"description"];
    NSArray *searchArray = [descriptionString componentsSeparatedByString:@","];
    //set dynamic height according to text
    CGSize size = CGSizeMake(rectSize.width-50,45);
    CGRect textRect = [[searchArray objectAtIndex:0]
                       boundingRectWithSize:size
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:17.0]}
                       context:nil];
    placeName.numberOfLines = 0;
    placeName.frame = textRect;
    placeName.frame =CGRectMake(38, 15, rectSize.width-50, textRect.size.height+2);
    placeName.text=[searchArray objectAtIndex:0];
    NSMutableString* resultString = [[NSMutableString alloc] init];
    NSString *addressString;
    if ([searchArray count]>1) {
        for (int i=1; i <[searchArray count]; i++)  {
                [resultString appendString:[searchArray objectAtIndex:i]];
                [resultString appendString:@","];
            addressString = [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSCharacterSet* charsToTrim = [NSCharacterSet characterSetWithCharactersInString:@","];
            addressString = [addressString stringByTrimmingCharactersInSet:charsToTrim];
        }
    }
    else {
        addressString =[searchArray objectAtIndex:0];
    }
    CGSize size1 = CGSizeMake(rectSize.width-50,45);
    CGRect textRect1 = [addressString
                        boundingRectWithSize:size1
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:15.0]}
                        context:nil];
    placeAddress.numberOfLines = 0;
    placeAddress.frame = textRect1;
    placeAddress.frame =CGRectMake(38, placeName.frame.origin.y+placeName.frame.size.height+4, rectSize.width-50, textRect1.size.height+2);
    placeAddress.text=addressString;
}
#pragma mark - end
@end
