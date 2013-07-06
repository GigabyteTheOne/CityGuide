//
//  PlaceTableViewCell.m
//  CityGuide
//
//  Created by Konstantin Simakov on 30.06.13.
//
//

#import "PlaceTableViewCell.h"

@implementation PlaceTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_nameLabel release];
    [_placeImage release];
    [super dealloc];
}
@end
