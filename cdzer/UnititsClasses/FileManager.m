//
//  FileManager.m
//  cdzer
//
//  Created by KEns0n on 2/10/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "FileManager.h"
#import "ExifContainer.h"
#import "UIImage+Exif.h"

#define fmDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define fmCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
#define fmTemporaryPath NSTemporaryDirectory()

@implementation FileManager

+ (NSString *)getRootFolder:(FMRootFolderType)type {
    NSString * rootPath = nil;
    switch (type) {
        case FMRootFolderTypeOfDocument:
            rootPath = fmDocumentPath;
            break;
        case FMRootFolderTypeOfCache:
            rootPath = fmCachePath;
            break;
        case FMRootFolderTypeOfTemporary:
            rootPath = fmTemporaryPath;
            break;
        case FMRootFolderTypeOfBundle:
            rootPath = [[NSBundle mainBundle] resourcePath];
            break;
        default:
            rootPath = nil;
            break;
    }
    return rootPath;
}

+ (NSString *)convertImageNameByScale:(NSString *)fileName{
    @autoreleasepool {
        BOOL isTriple = [SupportingClass isTripleSizeRetinaScreen];
        BOOL isTwice = [SupportingClass isTwiceSizeRetinaScreen];
        fileName = [fileName stringByAppendingString:isTriple?@"@3x":(isTwice?@"@2x":@"")];
        return fileName;
    }
}

+ (NSString *)getFileFullPathFromCacheWithRootFolder:(FMRootFolderType)type
                                            fileName:(NSString *)fileName
                                             extType:(NSString *)extType
                                           subFolder:(NSString *)subFolder
                                             isImage:(BOOL)isImage {
    @autoreleasepool {
        if (!fileName) {
            return nil;
        }
        if (!extType) {
            extType = @"";
        }
        NSString *fullString = [self getRootFolder:type];
        
        if (subFolder) {
            fullString = [fullString stringByAppendingPathComponent:subFolder];
        }
        NSString *newFileName = [fileName stringByAppendingPathExtension:extType];
        if (isImage) {
            newFileName = [[self convertImageNameByScale:fileName] stringByAppendingPathExtension:extType];
        }
        
        return [fullString stringByAppendingPathComponent:newFileName];
    }
}

+ (FMImageType)getImageTypeNumWithString:(NSString *)type {
    if ([type isEqualToString:@"png"]||[type isEqualToString:@"PNG"]) {
        return FMImageTypeOfPNG ;
    }else if ([type isEqualToString:@"JEPG"]||[type isEqualToString:@"jepg"]||[type isEqualToString:@"JPG"]||[type isEqualToString:@"jpg"]) {
        return FMImageTypeOfJPEG ;
    }
    return FMImageTypeOfPNG;
}
//数据存储方法
+ (unsigned long long)fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

+ (BOOL)checkFileIsExistWithtRootType:(FMRootFolderType)type subPath:(NSString *)subPath theFile:(NSString *)theFile extType:(NSString *)extType isDirectory:(BOOL *)isDirectory {
    @autoreleasepool {
        BOOL isExist = NO;
        
        if (theFile&&![theFile isEqualToString:@""]) {
            if (extType && ![extType isEqualToString:@""]) {
                theFile = [theFile stringByAppendingPathExtension:extType];
            }
            NSFileManager *manager = [NSFileManager defaultManager];
            NSString *rootPath = [self getRootFolder:type];
            NSString *finalPath = [rootPath stringByAppendingPathComponent:theFile];
            if (subPath&&![subPath isEqualToString:@""]) {
                finalPath = nil;
                finalPath = [[rootPath stringByAppendingPathComponent:subPath]stringByAppendingPathComponent:theFile];
            }
            BOOL aEmptyFile = ([self fileSizeAtPath:finalPath]==0);
            isExist = [manager fileExistsAtPath:finalPath isDirectory:isDirectory];
            if (isExist) {
                if (aEmptyFile) {
                    isExist = NO;
                }
            }
        }
        
        return isExist;
    }
}

+ (BOOL)createFolderToRootFolderWithType:(FMRootFolderType)type theFile:(NSString *)theFile {
    
    @autoreleasepool {
        BOOL isSuccess = NO;
        
        if (theFile || ![theFile isEqualToString:@""]) {
            NSFileManager *manager = [NSFileManager defaultManager];
            NSString *rootPath = [self getRootFolder:type];
            NSString *finalPath = [rootPath stringByAppendingPathComponent:theFile];
            NSError *error;
            isSuccess = [manager createDirectoryAtPath:finalPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                NSLog(@"ErrorMessageInCreateFolder:::%@\n",[error description]);
                NSLog(@"ErrorDebugMessageInCreateFolder:::%@\n",[error debugDescription]);
            }
        }
        
        return isSuccess;
    }
}

+ (BOOL)copyFileFromProjectToRootFolderWithType:(FMRootFolderType)type subPath:(NSString *)subPath theFile:(NSString *)theFile {
    @autoreleasepool {
        BOOL isSuccess = NO;
        
        if (theFile || ![theFile isEqualToString:@""]) {
            NSFileManager *manager = [NSFileManager defaultManager];
            NSString *rootPath = [self getRootFolder:type];
            NSString *finalPath = [rootPath stringByAppendingPathComponent:theFile];
            if (subPath || ![subPath isEqualToString:@""]) {
                BOOL isDirectory = NO;
                if (![self checkFileIsExistWithtRootType:type subPath:nil theFile:subPath extType:nil isDirectory:&isDirectory]) {
                    [self createFolderToRootFolderWithType:type theFile:subPath];
                }else if(!isDirectory) {
                    
                }
                finalPath = nil;
                finalPath = [[rootPath stringByAppendingPathComponent:subPath]stringByAppendingPathComponent:theFile];
            }
            NSError *error;
            isSuccess = [manager copyItemAtPath:[[NSBundle mainBundle] pathForResource:theFile ofType:nil] toPath:finalPath error:&error];
            if (error) {
                NSLog(@"ErrorMessageInCopyFile:::%@\n",[error description]);
                NSLog(@"ErrorDebugMessageInCopyFile:::%@\n",[error debugDescription]);
            }
        }
        
        return isSuccess;
    }
}

+ (BOOL)saveImageToFileWithImageType:(FMImageType)imageType
                            rootType:(FMRootFolderType)type
                             subPath:(NSString *)subPath
                             theFile:(NSString *)theFile
                               image:(UIImage *)image
                            exifData:(ExifContainer *)exifData {
    @autoreleasepool {
        BOOL isSuccess = NO;
        
        if (image) {
            NSFileManager *manager = [NSFileManager defaultManager];
            NSString *rootPath = [self getRootFolder:type];
            NSString *finalPath = [rootPath stringByAppendingPathComponent:theFile];
            if (subPath || ![subPath isEqualToString:@""]) {
                BOOL isDirectory = NO;
                if (![self checkFileIsExistWithtRootType:type subPath:nil theFile:subPath extType:nil isDirectory:nil]) {
                    [self createFolderToRootFolderWithType:type theFile:subPath];
                }else if(!isDirectory) {
                    [self createFolderToRootFolderWithType:type theFile:subPath];
                }

                finalPath = nil;
                finalPath = [[rootPath stringByAppendingPathComponent:subPath]stringByAppendingPathComponent:theFile];
            }
            NSData *imageData = nil;
            if (imageType==FMImageTypeOfPNG) {
                imageData = (!exifData)?UIImagePNGRepresentation(image):[image addExif:exifData toImageType:ExifImageTypeOfPNG];
            }else if (imageType==FMImageTypeOfJPEG) {
                imageData = (!exifData)?UIImageJPEGRepresentation(image, 1.0f):[image addExif:exifData toImageType:ExifmageTypeOfJPEG];
            }
            
            isSuccess = [manager createFileAtPath:finalPath contents:imageData attributes:nil];
        }
    
        
        return isSuccess;
    }
}

+ (BOOL)saveDataToFileWithData:(NSData *)data RootType:(FMRootFolderType)type subPath:(NSString *)subPath theFile:(NSString *)theFile extType:(NSString *)extType {
    BOOL folderExist = [self checkFileIsExistWithtRootType:type subPath:nil theFile:subPath extType:nil isDirectory:nil];
    if (!folderExist) {
        NSLog(@"Create Folder Success :: %d", [self createFolderToRootFolderWithType:type theFile:subPath]);
    }
    
    NSError *error = nil;
    NSString *path = [self getFileFullPathFromCacheWithRootFolder:type fileName:theFile extType:extType subFolder:subPath isImage:NO];
    BOOL saveSuccess = [data writeToFile:path options:NSDataWritingAtomic error:&error];
    NSLog(@"write error %@", error.debugDescription);
    return saveSuccess;
}

+ (BOOL)archiveObjectWithObject:(id)object andArchiveKey:(NSString *)archiveKey rootType:(FMRootFolderType)type subPath:(NSString *)subPath theFile:(NSString *)theFile extType:(NSString *)extType {
    @autoreleasepool {
        NSMutableData *mData = [[NSMutableData alloc] initWithCapacity:0];
        
        //NSKeyedArchiver, 压缩工具, 继承于NSCoder,主要用于编码
        NSKeyedArchiver *archiver= [[NSKeyedArchiver alloc] initForWritingWithMutableData:mData];
        //把P对象压到Data中
        if (!archiveKey||[archiveKey isEqualToString:@""]) {
            archiveKey = @"archiveKey";
        }
        [archiver encodeObject:object forKey:archiveKey];
        //完成压缩
        [archiver finishEncoding];
        NSLog(@"%@", mData);
        
        
        BOOL result = [self saveDataToFileWithData:mData RootType:FMRootFolderTypeOfCache subPath:kDataKeyedArchiverPath theFile:theFile extType:extType];

        if (result) {
            NSLog(@"写入成功");
        } else {
            NSLog(@"写入失败");
        }
        return  result;
    }
}

+ (id)unArchiveObjectWithArchiveKey:(NSString *)archiveKey rootType:(FMRootFolderType)type subPath:(NSString *)subPath theFile:(NSString *)theFile extType:(NSString *)extType {
    @autoreleasepool {
        BOOL isFolder = YES;
        BOOL fileExist = [self checkFileIsExistWithtRootType:type subPath:subPath theFile:theFile extType:extType isDirectory:&isFolder];
        if (!fileExist||isFolder) {
            NSLog(@"file was not exist OR file was a folder");
            return nil;
        }
        
        
        if (!archiveKey||[archiveKey isEqualToString:@""]) {
            NSLog(@"can not found the file, archiveKey was empty");
            return nil;
        }
        
        NSString *mDataPath = [self getFileFullPathFromCacheWithRootFolder:type fileName:theFile extType:extType subFolder:subPath isImage:NO];
        
        //反归档
        NSData *contentData = [[NSData alloc] initWithContentsOfFile:mDataPath];
        //NSKeyedUnarchiver解压工具, 继承于NSCoder
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:contentData];
        //通过key找到Object
        id object = [unarchiver decodeObjectForKey:archiveKey];
        NSLog(@"get object success :: %@", object);
        return object;
    }
}

@end
