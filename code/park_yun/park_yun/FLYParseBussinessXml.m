//
//  FLYParseBussinessXml.m
//  park_yun
//
//  Created by chen on 14-8-7.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYParseBussinessXml.h"
#import "FLYBussinessModel.h"

@implementation FLYParseBussinessXml

- (NSMutableArray *)parseBussinessData{
    _bussinessList = [[NSMutableArray alloc] initWithCapacity:1000];
    
    NSString *xmlFilePath = [[NSBundle mainBundle]pathForResource:@"bussiness" ofType:@"xml"];
    NSData *data = [[NSData alloc]initWithContentsOfFile:xmlFilePath];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
    
    return _bussinessList;
}

#pragma mark - NSXMLParserDelegate delegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    //判断是否是ROW
    if ([elementName isEqualToString:@"ROW"]) {
        FLYBussinessModel *bussinessModel = [[FLYBussinessModel alloc] init];
        [_bussinessList addObject:bussinessModel];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    _tempElement = string;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    FLYBussinessModel *bussinessModel = _bussinessList[[_bussinessList count] - 1];
    if ([elementName isEqualToString:@"BUSSINESS_ID"]) {
        bussinessModel.bussinessId = _tempElement;
    }
    else if ([elementName isEqualToString:@"BUSSINESS_REGIONID"]) {
        bussinessModel.bussinessRegionid = _tempElement;
    }
    else if ([elementName isEqualToString:@"BUSSINESS_NAME"]) {
        bussinessModel.bussinessName = _tempElement;
    }
    else if ([elementName isEqualToString:@"BUSSINESS_LNG"]) {
        bussinessModel.bussinessLng = _tempElement;
    }
    else if ([elementName isEqualToString:@"BUSSINESS_LAT"]) {
        bussinessModel.bussinessLat = _tempElement;
    }
    else if ([elementName isEqualToString:@"BUSSINESS_DESC"]) {
        bussinessModel.bussinessDesc = _tempElement;
    }
    else if ([elementName isEqualToString:@"BUSSINESS_SORT"]) {
        bussinessModel.bussinessSort = _tempElement;
    }
}

@end
