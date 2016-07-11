//
//  SearchViewController.m
//  Tako
//
//  Created by 熊海涛 on 16/4/6.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import "SearchViewController.h"
#import "UIHelper.h"
#import "MyLayout.h"
#import "TestViewController.h"
#import "ResultViewDelegate.h"
#import "App.h"
#import "Server.h"

@interface SearchViewController ()<UITableViewDataSource,UITableViewDelegate>
//@property (weak, nonatomic) IBOutlet MyFlowLayout *flowLayout;
@property (strong, nonatomic) NSMutableArray* favorateList;
@property (strong, nonatomic) NSMutableArray* historyList;
@property (strong, nonatomic) NSMutableArray* suggestList;
@property (strong, nonatomic) NSMutableArray* resultList;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet MyFlowLayout *contentView;
@property (strong, nonatomic) UITableView *historyView;
@property (strong, nonatomic) UITableView *suggestView;
@property (strong, nonatomic) UITableView *resultView;
@property (strong, nonatomic) ResultViewDelegate* resultViewDelegate;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.favorateList  = [NSMutableArray arrayWithObjects:@"剑侠世界",@"剑侠口袋版",@"灵域",@"安居客",@"枪魂",nil];
    self.historyList = [NSMutableArray arrayWithObjects:@"历史记录1+剑侠情缘",@"历史记录2+口袋版",@"历史记录3+消消乐",@"历史记录4+好大夫",nil];
    self.suggestList = [NSMutableArray arrayWithObjects:@"建议搜索1+剑侠",@"建议搜索2+口袋",@"建议搜索3+消",@"建议搜索4+夫",nil];
    
    self.resultList = [NSMutableArray new];
    for (int i=0; i<4; i++) {
        TakoApp* app = [TakoApp new];
        app.appname = [NSString stringWithFormat:@"剑侠%d",i];
        app.versionname = [NSString stringWithFormat:@"1.3.%d",i];
        app.size = [NSString stringWithFormat:@"2%d MB",i];
        app.releasetime = @"2015-03-19";
        [self.resultList addObject:app];
    }
        
    
    self.resultViewDelegate = [[ResultViewDelegate alloc] init];
    
    // 重设颜色
    self.titleView.backgroundColor = [XHTUIHelper navigateColor];
    
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchDown];
    
    self.searchBar.delegate = self;
    self.searchBar.layer.cornerRadius = 10;
    self.searchBar.layer.masksToBounds = YES;
    [self.searchBar becomeFirstResponder];
    
//    searchBar.keyboardType = UIKeyboardAppearanceDefault;
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.backgroundImage = [UIImage new];
    self.searchBar.placeholder  = @"搜索您的应用...";
    self.searchBar.keyboardType = UIKeyboardAppearanceDefault;
    
    // 加载热门词汇
    [self layoutFavorateLabels];
    
    // 加载搜索历史
    [self layoutHistoryLabels];
    
    // 加载推荐词汇
    [self layoutSuggestview];

    // 加载搜索结果
    [self layoutResultview];
    
    // 添加segment事件
    [ self.segment addTarget: self action: @selector(controlPressed:) forControlEvents: UIControlEventValueChanged];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -- layout subview
-(void)layoutFavorateLabels{
    
    for (NSString* temp in self.favorateList) {
        [self createTagButton:temp superView:self.contentView];
    }
}


-(void)layoutSuggestview{
    CGSize mainSize = [UIScreen mainScreen].bounds.size;
    self.suggestView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchBar.frame), mainSize.width, mainSize.height - CGRectGetMaxY(self.searchBar.frame))];
    
    [self.view addSubview:self.suggestView];
    self.suggestView.delegate = self;
    self.suggestView.dataSource = self;
    [XHTUIHelper setExtraCellLineHidden:self.suggestView];
    // 初始化时隐藏
    [self.suggestView setHidden:YES];
}


-(void)layoutResultview{
    CGSize mainSize = [UIScreen mainScreen].bounds.size;
    self.resultView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchBar.frame), mainSize.width, mainSize.height - CGRectGetMaxY(self.searchBar.frame))];
 
//    self.resultView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.resultView];
    [XHTUIHelper setExtraCellLineHidden:self.resultView];
    [self.resultView setHidden:YES];
    self.resultViewDelegate.resultList = self.resultList;
    self.resultView.delegate = self.resultViewDelegate;
    self.resultView.dataSource = self.resultViewDelegate;
    
}

-(void)layoutHistoryLabels{

    CGSize mainSize = [UIScreen mainScreen].bounds.size;
    CGPoint origin = self.contentView.frame.origin;
    self.historyView = [[UITableView alloc] initWithFrame:CGRectMake(0, origin.y, mainSize.width, mainSize.height - CGRectGetMaxY(self.segment.frame)-8)];
    self.historyView.delegate = self;
    self.historyView.dataSource = self;
    
//    historyView。
    float btWith = 250;
     UIButton* clearButton = [[UIButton alloc] initWithFrame:CGRectMake(mainSize.width-btWith-(mainSize.width-btWith)/2, 8, btWith, 30)];
    [clearButton setTitle:@"清空搜索历史" forState:UIControlStateNormal];
    clearButton.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [XHTUIHelper addBorderonButton:clearButton cornerSize:8 borderWith:0];
    clearButton.backgroundColor = [UIColor redColor];
    UIView* footer = [[UIView alloc] init];
    [footer addSubview:clearButton];

    self.historyView.tableFooterView = footer;
    [self.view addSubview:self.historyView];
    
    [self.historyView setHidden:YES];

}

- (void)cancelSearch{
    NSLog(@"will dismiss search view...");
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)createTagButton:(NSString*)text superView:(UIView*) superview
{
    UIButton *tagButton = [UIButton new];
    [tagButton setTitle:text forState:UIControlStateNormal];
    tagButton.layer.cornerRadius = 10;
   UIColor* newColor = [UIColor colorWithRed:random()%256 / 255.0 green:random()%256 / 255.0 blue:random()%256 / 255.0 alpha:0.5];
    tagButton.backgroundColor = newColor;
    
    // 根据颜色深浅，重新设置字体颜色
    if ([XHTUIHelper isDarkColor:newColor]) {
        [tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [tagButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    tagButton.heightDime.equalTo(@(30));
    tagButton.widthDime.min(45);
    tagButton.myLeftMargin = 20;
    tagButton.myTopMargin = 8;
    tagButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [tagButton sizeToFit];
    [tagButton addTarget:self action:@selector(handleClicked:) forControlEvents:UIControlEventTouchUpInside];
    [superview addSubview:tagButton];
    
}



-(void)handleClicked:(UIButton*)sender{
    NSLog(@"button %@ clicked...",sender.titleLabel.text);
    
    [self showSearchResult];
}


#pragma mark segment delegate

- (void) controlPressed:(id)sender {
    int selectedIndex = (int)self.segment.selectedSegmentIndex;
    NSLog(@"selected index is:%d",selectedIndex);
    
    // 视图切换
    if (selectedIndex == 0) {
        [self.contentView setHidden:NO];
        [self.historyView setHidden:YES];
    }else if (selectedIndex == 1){
        [self.contentView setHidden:YES];
        [self.historyView setHidden:NO];
    }
}



#pragma mark tableview的delegate

/*cell高度*/
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 40;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == self.historyView){
    return [self.historyList count];
    }
    else {
    return [self.suggestList count];
    }
}



// 点击单元格
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    NSLog(@"clicked index is:%@",indexPath);

    if(tableView == self.historyView){
    [self showSearchResult];
    }else{
        [self showSearchResult];
    }
}

-(void)showSearchResult{
    // todo: 搜索大厅应用
//    self.resultList = [TakoServer searchApp];
//    [self.resultView reloadData];
    [self.resultView setHidden:NO];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    // 系统原生的cell
    static NSString *CellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    // 强制cell分割线左移
    [XHTUIHelper forceCellToLeft:cell];
    
    
    // 数据填充
    if(tableView == self.historyView){
        cell.textLabel.text = [self.historyList objectAtIndex:indexPath.row];
    }else{
        cell.textLabel.text = [self.suggestList objectAtIndex:indexPath.row];
    }
    return cell;
}

# pragma mark
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"search text change...%@",searchText);
   [self.resultView setHidden:YES];
    if([searchText isEqualToString:@""]){
    [self.suggestView setHidden:YES];
    }else{
        // todo: 实时获取app
//       self.suggestList = [TakoServer searchApp:searchText];
//        [self.suggestView reloadData];
        [self.suggestView setHidden:NO];
    }
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [TalkingData trackPageBegin:DATA_PAGE_SERACH];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [TalkingData trackPageEnd:DATA_PAGE_SERACH];
}


@end
