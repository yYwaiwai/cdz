//
//  FileManager.h
//  cdzer
//
//  Created by KEns0n on 2/10/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>
@class ExifContainer;
typedef NS_ENUM(NSInteger, FMRootFolderType) {
    FMRootFolderTypeOfDocument = 1,
    FMRootFolderTypeOfCache = 2,
    FMRootFolderTypeOfTemporary = 3,
    FMRootFolderTypeOfBundle = 4
};

typedef NS_ENUM(NSInteger, FMImageType) {
    FMImageTypeOfPNG = 1,
    FMImageTypeOfJPEG = 2,
};


@interface FileManager : NSObject

+ (NSString *)getRootFolder:(FMRootFolderType)type;

+ (NSString *)convertImageNameByScale:(NSString *)fileName;

+ (NSString *)getFileFullPathFromCacheWithRootFolder:(FMRootFolderType)type
                                            fileName:(NSString *)fileName
                                             extType:(NSString *)extType
                                           subFolder:(NSString *)subFolder
                                             isImage:(BOOL)isImage;

+ (FMImageType)getImageTypeNumWithString:(NSString *)type;

+ (BOOL)createFolderToRootFolderWithType:(FMRootFolderType)type
                                 theFile:(NSString *)theFile;

+ (BOOL)checkFileIsExistWithtRootType:(FMRootFolderType)type
                              subPath:(NSString *)subPath
                              theFile:(NSString *)theFile
                              extType:(NSString *)extType
                          isDirectory:(BOOL *)isDirectory;

+ (BOOL)copyFileFromProjectToRootFolderWithType:(FMRootFolderType)type
                                        subPath:(NSString *)subPath
                                        theFile:(NSString *)theFile;

+ (BOOL)saveImageToFileWithImageType:(FMImageType)imageType
                            rootType:(FMRootFolderType)type
                             subPath:(NSString *)subPath
                             theFile:(NSString *)theFile
                               image:(UIImage *)image
                            exifData:(ExifContainer *)exifData;

+ (BOOL)archiveObjectWithObject:(id)object andArchiveKey:(NSString *)archiveKey rootType:(FMRootFolderType)type subPath:(NSString *)subPath theFile:(NSString *)theFile extType:(NSString *)extType;

+ (id)unArchiveObjectWithArchiveKey:(NSString *)archiveKey rootType:(FMRootFolderType)type subPath:(NSString *)subPath theFile:(NSString *)theFile extType:(NSString *)extType;

@end
