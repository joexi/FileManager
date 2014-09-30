JXFileManager
=============

A local file manager helping reading an writing data, all apis are using G-C-D mode.

# Provides
 Loading/Writing file from local disk with asnc/async way
 
# Examples
``` objc
[JXFileManager asyncSaveData:dic withPath:path callback:^(BOOL succeed) {
        if (succeed) {
            NSLog(@"write success");
        }
        [JXFileManager asyncLoadDataFromPath:path
                                    callback:^(NSObject *data) {
                                        NSLog(@"data is %@",data);
                                    }];
        NSLog(@"start loading...");
    }];
```

