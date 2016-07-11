@interface LSApplicationWorkspace : NSObject  {
    
}

+ (id)defaultWorkspace;

- (id)allApplications;
- (BOOL)applicationIsInstalled:(id)arg1;

@end
