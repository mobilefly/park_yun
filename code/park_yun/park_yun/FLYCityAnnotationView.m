//
//  FLYCityAnnotationView.m
//  park_yun
//
//  Created by chen on 14-8-4.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYCityAnnotationView.h"

@implementation FLYCityAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithAnnotation:(id <BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil) {
        [self initView];
    }
    return self;
}

- (void)initView{
    self.image = [UIImage imageNamed:@"nearby_map_content.png"];
    
    regionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, 165 - 40, 20)];
    regionLabel.font = [UIFont systemFontOfSize:12.0];
    regionLabel.textColor = [UIColor whiteColor];
    regionLabel.backgroundColor = [UIColor clearColor];
    regionLabel.textAlignment = NSTextAlignmentCenter;
    
    subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, regionLabel.bottom, 165 - 15 * 2, 20)];
    subTitleLabel.font = [UIFont systemFontOfSize:12.0];
    subTitleLabel.textColor = [UIColor whiteColor];
    subTitleLabel.backgroundColor = [UIColor clearColor];
    subTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:regionLabel];
    [self addSubview:subTitleLabel];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    regionLabel.text = self.regionModel.regionName;
    subTitleLabel.text = [NSString stringWithFormat:@"停车场:%@ 总车位:%@", self.regionModel.count,self.regionModel.capacity];
}

@end
