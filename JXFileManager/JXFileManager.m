//
//  JXFileManager.m
//  JXFileManager
//
//  Created by Joe on 13-4-12.
//  Copyright (c) 2013年 Joe. All rights reserved.
//

#import "JXFileManager.h"
#import "PathHelper.h"
@implementation JXFileManager
static dispatch_queue_t _dispathQueue;
+ (dispatch_queue_t)defaultQueue
{
    if (!_dispathQueue) {
        _dispathQueue = dispatch_queue_create("JX.FileManager", NULL);
    }
    return _dispathQueue;
}
#pragma mark - 读取文件


+ (NSObject *)loadDataFromPath:(NSString *)path
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];;
}

+ (BOOL)asyncLoadDataFromPath:(NSString *)path callback:(void(^)(NSObject *data))callback
{
    BOOL fileExist = [self fileExistsAtPath:path];
    dispatch_async([self defaultQueue], ^{
        NSObject *data = [self loadDataFromPath:path];
        callback(data);
    });
    return fileExist;
}

#pragma mark - 存储数据
+ (BOOL)saveData:(NSObject *)data withPath:(NSString *)path
{
    if ([PathHelper createPathIfNecessary:[path stringByDeletingLastPathComponent]])
    {
        return [NSKeyedArchiver archiveRootObject:data toFile:path];
    }
    return NO;
}

+ (void)asyncSaveData:(NSObject *)data
             withPath:(NSString *)path
             callback:(void(^)(BOOL succeed))callback
{
    dispatch_async([self defaultQueue], ^{
        BOOL succeed = [self saveData:data withPath:path];
        callback(succeed);
    });
}

+ (BOOL)saveData:(NSObject *)data
        withPath:(NSString *)path
        fileName:(NSString *)fileName
{
    NSString *fullPath = [path stringByAppendingPathComponent:fileName];
    return [self saveData:data withPath:fullPath];
}

+ (void)asyncSaveData:(NSObject *)data
             withPath:(NSString *)path
             fileName:(NSString *)fileName
             callback:(void(^)(BOOL succeed))callback
{
    NSString *fullPath = [path stringByAppendingPathComponent:fileName];
    [self asyncSaveData:data withPath:fullPath callback:callback];
}

#pragma mark - 删除
+ (BOOL)removeFileAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL succeed = [fileManager removeItemAtPath:path error:&error];
    return succeed;
}

+ (void)removeFileAtPath:(NSString *)path condition:(BOOL (^)(NSDictionary *fileInfo))condition;
{
    NSFileManager *fm = [NSFileManager defaultManager];
	NSDirectoryEnumerator *enumerate = [fm enumeratorAtPath:path];
	for (NSString *fileName in enumerate)
    {
		NSString *filePath = [path stringByAppendingPathComponent:fileName];
		NSDictionary *fileInfo = [fm attributesOfItemAtPath:filePath error:nil];
        if (condition(fileInfo)) {
            [fm removeItemAtPath:filePath error:nil];
        }
	}
}

+ (void)asyncRemoveFileAtPath:(NSString *)path condition:(BOOL (^)(NSDictionary *fileInfo))condition;
{
    dispatch_async([self defaultQueue], ^{
        [self removeFileAtPath:path condition:condition];
    });
}

+ (BOOL)fileExistsAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}


@end
