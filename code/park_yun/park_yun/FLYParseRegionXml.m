//
//  FLYParseRegionXml.m
//  park_yun
//
//  Created by chen on 14-8-6.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYParseRegionXml.h"
#import "FLYRegionModel.h"

@implementation FLYParseRegionXml

- (NSMutableArray *)parseRegionData{
    _regionList = [[NSMutableArray alloc] initWithCapacity:1000];
    
    NSString *xmlFilePath = [[NSBundle mainBundle]pathForResource:@"region" ofType:@"xml"];
    NSData *data = [[NSData alloc]initWithContentsOfFile:xmlFilePath];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
    
    return _regionList;
}

#pragma mark - NSXMLParserDelegate delegate
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    //判断是否是ROW
    if ([elementName isEqualToString:@"ROW"]) {
        FLYRegionModel *regionModel = [[FLYRegionModel alloc] init];
        [_regionList addObject:regionModel];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
     //去掉空格与换行符
    _tempElement = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    FLYRegionModel *regionModel = _regionList[[_regionList count] - 1];
    if ([elementName isEqualToString:@"REGION_ID"]) {
        regionModel.regionId = _tempElement;
    }
    else if ([elementName isEqualToString:@"REGION_CODE"]) {
        regionModel.regionCode = _tempElement;
    }
    else if ([elementName isEqualToString:@"REGION_PARENTID"]) {
        regionModel.regionParentid = _tempElement;
    }
    else if ([elementName isEqualToString:@"REGION_NAME"]) {
        regionModel.regionName = _tempElement;
    }
    else if ([elementName isEqualToString:@"REGION_SORT"]) {
        regionModel.regionSort = _tempElement;
    }
    else if ([elementName isEqualToString:@"REGION_LNG"]) {
        regionModel.regionLng = _tempElement;
    }
    else if ([elementName isEqualToString:@"REGION_LAT"]) {
        regionModel.regionLat = _tempElement;
    }
}


@end
