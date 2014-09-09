//
//  CDKNetworkGlobals.h
//  CDKLibrary
//
//  Created by Mike Neill on 8/19/14.
//  Copyright (c) 2014 Cardinal Solutions. All rights reserved.
//

#ifndef CDKLibrary_CDKNetworkGlobals_h
#define CDKLibrary_CDKNetworkGlobals_h

typedef NS_ENUM(NSUInteger, CDKNetworkMethod)
{
    CDKNetworkMethodGET = 0,
    CDKNetworkMethodPOST = 1,
    CDKNetworkMethodDELETE = 2,
    CDKNetworkMethodHEAD = 3,
    CDKNetworkMethodMERGE = 4
};

typedef NS_ENUM(NSUInteger, CDKNetworkSerializationType)
{
    CDKNetworkSerializationTypeNone,
    CDKNetworkSerializationTypeJSON
};

typedef NS_ENUM(NSUInteger, CDKNetworkError)
{
    CDKNetworkErrorNoConnection = 2001,
    CDKNetworkErrorUnknownError = 2002,
    CDKNetworkErrorJSONSerializationError = 2003
};

enum CDKNetworkHTTPStatusCode
{
    CDKNetworkHTTPStatusCodeInformational = 100,
    CDKNetworkHTTPStatusCodeSuccessful = 200,
    CDKNetworkHTTPStatusCodeCreated = 201,
    CDKNetworkHTTPStatusCodeAccepted = 202,
    CDKNetworkHTTPStatusCodeRedirection = 300,
    CDKNetworkHTTPStatusCodeNotModified = 304,
    CDKNetworkHTTPStatusCodeClientError = 400,
    CDKNetworkHTTPStatusCodeClientUnauthorized = 401,
    CDKNetworkHTTPStatusCodePaymentRequired = 402,
    CDKNetworkHTTPStatusCodeNotFound = 404,
    CDKNetworkHTTPStatusCodeMethodNotAllowed = 405,
    CDKNetworkHTTPStatusCodeServerError = 500,
    CDKNetworkHTTPStatusCodeNotImplemented = 501,
};

#define CDKNetworkErrorDomain @"CDKNetworkErrorDomain"
#define CDKNetworkDefaultTimeInterval 45

#endif
