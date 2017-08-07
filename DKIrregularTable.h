//  DKIrregularTableView
/**
 不规则列表,
 竖列列表,
 支持多行多列,
 支持刷新,
 已做重用处理优化.
  */


#import <UIKit/UIKit.h>


typedef void(^CompleteLoadCellBlock)(UIView * cell,CGFloat cellHeight);

/**DKIrregularTableScroll*/
typedef enum : NSUInteger {
    DKIrregularTableScrollToTop,//滑动cell到顶部
    DKIrregularTableScrollToMiddle,//滑动cell到中间
    DKIrregularTableScrollToBottom,//滑动cell到下面
} DKIrregularTableScroll;



/**
    table interface
 */

@class DKIrregularTable;

@protocol DKIrregularTableDelegate <NSObject>
@required

/**table number of cell*/
-(NSInteger)irregularTableNumberOfCellWithTable:(DKIrregularTable*)irregularTable;

/**table number of cell*/
-(NSInteger)irregularTableNumberOfSectionWithTable:(DKIrregularTable*)irregularTable;

/**table cell*/
-(void)irregularTableWithTable:(DKIrregularTable*)irregularTable cellViewWithIndex:(int)index complete:(CompleteLoadCellBlock)complete;


@optional
/**table head view*/
-(UIView*)irregularTableHeadViewWithTable:(DKIrregularTable*)irregularTable;

/**table refresh View*/
-(UIView*)irregularTableRefreshViewWithTable:(DKIrregularTable*)irregularTable;

-(void)loadMoreData;

-(void)irregularTableReloadData;

@end

/**
    table class DKIrregularTable head interface
 */
@interface DKIrregularTable : UIView<UIScrollViewDelegate>

@property (nonatomic) CGFloat edgeH;
@property (nonatomic) CGFloat edgeV;

@property (nonatomic) NSInteger numberOfSections;
@property (nonatomic) NSInteger numberOfCells;
@property (nonatomic) CGFloat cellWidth;

@property (nonatomic,strong) NSMutableArray * cells;


@property (nonatomic,strong) id<DKIrregularTableDelegate> delegate;

@property (nonatomic,strong) UIView * headView;
@property (nonatomic,strong) UIView * refreshView;
@property (nonatomic,strong) UIScrollView * scrollView;

@property (nonatomic) BOOL animation;

/**初始化init with delegate*/
+(DKIrregularTable*)irregularTableWithFrame:(CGRect)frame delegate:(id)delegate;

/**创建with delegate*/
-(instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate;

/**重新加载data*/
-(void)reloadData;

//-(void)startRefreshData;
-(void)moveToCellWithIndex:(NSInteger)index;

@end
