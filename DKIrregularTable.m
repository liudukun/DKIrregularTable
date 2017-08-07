//
//  DKIrregularTable.m
//  DKIrregularTableView
//
//  Created by kun on 15/9/13.
//  Copyright (c) 2015年 kun. All rights reserved.
//

#import "DKIrregularTable.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width



@interface DKIrregularTable ()
{
    BOOL isDrag;
    NSMutableArray * heightCountArr;
}
@end

@implementation DKIrregularTable


//-(void)setNeedsUpdateConstraints{
//    return;
//}

/**初始化init with frame*/
-(instancetype)initWithFrame:(CGRect)frame{
    
    if ([super initWithFrame:frame]) {
        self.autoresizesSubviews = NO;
        self.scrollView.autoresizesSubviews = NO;
        self.cells = [NSMutableArray array];
        self.edgeH = 8;
        self.edgeV = 8;
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate{
    self = [self initWithFrame:frame];
    self.animation = NO;
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.scrollView.backgroundColor = [UIColor greenColor];
    self.delegate = delegate;
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.dk_w, self.scrollView.dk_h + 100);
    [self addSubview:self.scrollView];
    
    return self;
}

/**初始化init with delegate*/
+(DKIrregularTable*)irregularTableWithFrame:(CGRect)frame delegate:(id)delegate{
    return [[DKIrregularTable alloc]initWithFrame:frame delegate:delegate];
}

/**重新加载data*/
-(void)reloadData{
    [self clearContent];
    heightCountArr = [NSMutableArray array];
    self.cells = [NSMutableArray array];
    
    //number section
    self.numberOfSections = [self.delegate irregularTableNumberOfSectionWithTable:self];
    
    //横排cell宽度
    CGFloat cellsTotalWidth = self.scrollView.frame.size.width - (self.edgeH * (self.numberOfSections+1));
    //单个cell宽度
    self.cellWidth = cellsTotalWidth/self.numberOfSections;
    
    self.numberOfCells = [self.delegate irregularTableNumberOfCellWithTable:self];
    
    [self loadRefreshView];
    [self loadHeadView];
    
    if (self.numberOfCells==0) {
        NSLog(@"无数据");
        return;
    }
    
    [self loadCells];
    
    
}


-(void)loadRefreshView{
    if([self.delegate respondsToSelector:@selector(irregularTableRefreshViewWithTable:)]){
        self.refreshView = [self.delegate irregularTableRefreshViewWithTable:self];
        CGRect rectRefresh = self.refreshView.frame;
        rectRefresh.origin.x = 0;
        rectRefresh.size.width = self.scrollView.frame.size.width;
        rectRefresh.origin.y = - rectRefresh.size.height;
        self.refreshView.frame = rectRefresh;
        [self.scrollView addSubview:self.refreshView];
    }
    
    
}

-(void)loadHeadView{
    if([self.delegate respondsToSelector:@selector(irregularTableHeadViewWithTable:)]){
        self.headView = [self.delegate irregularTableHeadViewWithTable:self];
        CGRect rectHeadView = self.headView.frame;
        rectHeadView.origin.y = 0;
        self.headView.frame = rectHeadView;
        [self.scrollView addSubview:self.headView];
        self.headView.center = CGPointMake(self.scrollView.frame.size.width/2, self.headView.center.y);
    }
    
    
}

-(void)loadCells{
    
    
    //header height
    CGFloat headViewHeight = self.headView.frame.size.height;
    
    //first set heightcount
    for (int i=0; i<self.numberOfSections; i++) {
        [heightCountArr addObject:@(headViewHeight+10)];
    }
    
    
    //加载cell
    for (int i =0; i<self.numberOfCells; i++) {
        [self.delegate irregularTableWithTable:self cellViewWithIndex:i complete:^(UIView * cell,CGFloat cellHeight) {
            //cell frame set
            NSInteger  shouldPutIndex = [self getMinHeightCountIndexWithArr:heightCountArr];
            //orginX
            CGFloat orginX = self.edgeH + ( shouldPutIndex * (self.edgeH + self.cellWidth));
            //orginY
            CGFloat orginY = [heightCountArr[shouldPutIndex] floatValue];
            //            NSLog(@"%f",orginY);
            
            
            [self.scrollView addSubview:cell];
            if (self.animation) {
                cell.alpha = 0.3;
                cell.center = CGPointMake(orginX+self.cellWidth/2, orginY+cellHeight/2);
                [UIView animateWithDuration:1 animations:^{
                    cell.alpha = 1;
                    cell.frame = CGRectMake(orginX, orginY, self.cellWidth, cellHeight);
                    
                }];
            }else{
                cell.frame = CGRectMake(orginX, orginY, self.cellWidth, cellHeight);

            }
         
            
            
            //reset heightcount
            heightCountArr[shouldPutIndex] = @(orginY + cellHeight + self.edgeV);
            if (i==self.numberOfCells-1) {
                NSInteger  maxHeight = [self getMaxHeightCount:heightCountArr];
                self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, maxHeight);
                if(maxHeight < self.scrollView.dk_h+100){
                    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.dk_h+100);
                }
                
            }
            [self.cells addObject:cell];
        }];
        
        
    }
    
}

//获取应该放的index
-(NSInteger)getMinHeightCountIndexWithArr:(NSArray*)arr{
    //    NSLog(@"%@",arr);
    CGFloat min = [arr[0] floatValue];
    int minIndex = 0;
    for (int i =0;i<arr.count;i++) {
        CGFloat number = [arr[i] floatValue];
        if (number < min) {
            min = number;
            minIndex = i;
        }
    }
    //    NSLog(@"%i",minIndex);
    return minIndex;
}

//获取应该放的index
-(CGFloat)getMaxHeightCount:(NSArray*)arr{
    CGFloat max = [arr[0] floatValue];
    for (int i =0;i<arr.count;i++) {
        CGFloat number = [arr[i] floatValue];
        if (number > max) {
            max = number;
        }
    }
    return max;
}

-(void)clearContent{
    for (UIView *view in self.cells) {
        [view removeFromSuperview];
    }
    [self.cells removeAllObjects];
}


//判断rect 是否在可视范围
-(BOOL)isVisibleCell:(UIView*)view{
    if (self.scrollView.contentOffset.y>view.frame.size.height+view.frame.origin.y || self.scrollView.contentOffset.y+self.scrollView.frame.size.height < view.frame.origin.y) {
        return NO;
    }else{
        return YES;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    for (int i =0; i< _cells.count; i++) {
        UIView * view = _cells[i];
        if (![self isVisibleCell:view]) {
            [view removeFromSuperview];
        }else{
            [scrollView addSubview:view];
        }
    }
    
    
    CGFloat distance = scrollView.contentSize.height - scrollView.contentOffset.y- scrollView.frame.size.height;
    if (distance <= 0 && !isDrag) {
        [self.delegate loadMoreData];
        isDrag = YES;
    }
}



-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y<=-60)
    {
        //        scrollView.contentOffset = CGPointMake(0, -60);
        [self.delegate irregularTableReloadData];
        scrollView.delegate = nil;
        scrollView.contentInset=UIEdgeInsetsMake(60, 0, 0, 0);
        [self performSelector:@selector(backPositon) withObject:nil afterDelay:1];
    }
    
}

-(void)backPositon{
    self.scrollView.delegate = self;
    self.scrollView.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    isDrag = NO;
    
}


-(void)moveToCellWithIndex:(NSInteger)index{
    CGFloat record = self.edgeV;
    for (int i = 0; i<self.cells.count;i++) {
        UIView * view = self.cells[i];
        record =  view.dk_h + self.edgeV + record;
        if (i ==index-1) {
            //            [UIView animateWithDuration:1 animations:^{
            [self.scrollView setContentOffset:CGPointMake(0, record)];
            
            //            }];
            return;
        }
    }
}





@end
