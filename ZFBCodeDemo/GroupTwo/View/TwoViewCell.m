//
//  TwoViewCell.m
//  TESTDEMO
//
//  Created by 张涛 on 2020/10/27.
//

#import "TwoViewCell.h"
#import "Masonry.h"

@interface TwoViewCell ()

@end

@implementation TwoViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configCustomCodeCellUI];
    }
    return self;
}

-(void)configCustomCodeCellUI {
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16);
    }];
    
    [self.contentView addSubview:self.lineLabel];
    [self.lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.height.mas_equalTo(@1);
    }];
}


#pragma mark - loadlazy
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"暂无文字描述";
        _titleLabel.textColor = UIColorFromRGB(0x333333);
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    }
    return _titleLabel;;
}

- (UILabel *)lineLabel {
    if (_lineLabel == nil) {
        _lineLabel = [[UILabel alloc] init];
        _lineLabel.text = @"";
        _lineLabel.backgroundColor = UIColorFromRGB(0xEDEFF2);
    }
    return _lineLabel;;
}

@end
