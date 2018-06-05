/**
 * Created by aby.wang on 2017/11/28.
 */


import React, { Component } from 'react';
import PropTyps from 'prop-types';
import {
    StyleSheet,
    View,
    Text,
    TouchableOpacity,
    Image,
    FlatList,
    TextInput,
} from 'react-native';
import { observer } from 'mobx-react/native';
import {observable, action, runInAction, toJS} from 'mobx';
import Constants from '../global/Constants/index';
import { W750, MSG_ELEM } from '../global/Constants/Dimensions';
import CabinResultItem from './CabinResultItem';
import { FilterBtn, SelectBtn, IncreaseBtn } from '../component';

const paddingH = W750(40);

const jsonData = [
    {
        id: 1,
        name: '标准套房',
        price: '￥11888/人 起',
        belong_to: '多瑙河之旅',
    },
    {
        id: 2,
        name: '浪漫法式露台房',
        price: '￥14355/人 起',
        belong_to: '多瑙河之旅',
    },
    {
        id: 3,
        name: '精致阳台房',
        price: '￥16905/人 起',
        belong_to: '多瑙河之旅',
    },
    {
        id: 4,
        name: '豪华阳台套房',
        price: '￥27105/人 起',
        belong_to: '多瑙河之旅',
    },
    {
        id: 5,
        name: '奢享家套房',
        price: '￥35605/人 起',
        belong_to: '多瑙河之旅',
    },
]

export const CabinFilterRowStyle = StyleSheet.create({
    container: {
        flex: 0,
        justifyContent: 'flex-start',
        backgroundColor: '#fff',
    },
    filterTitleView: {
        flex: 0,
        height: W750(80),
        paddingHorizontal: paddingH,
        alignItems: 'center',
        flexDirection: 'row',
        backgroundColor: '#f5f5f5',
        justifyContent: 'space-between',
    },
    filterImage: {
        flex: 0,
        height: W750(28),
        width: W750(28),
    },
    filterContentView: {
        flex: 0,
        minHeight: W750(100),
        paddingHorizontal: paddingH,
        paddingBottom: W750(50),
    },
    contentItemStyle: {
        flex: 0,
        minHeight: W750(160),
        justifyContent: 'center',
        alignItems: 'flex-start',
    },
    contentItemTitle: {
        fontSize: 16,
        marginTop: W750(40),
        marginBottom: W750(30),
    },
    contentItemBtnGroup: {
        flex: 0,
        height: W750(60),
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
    },
    filterBtn: {
        flex: 0,
        width: W750(170),
        height: W750(60),
    },
    selectDateBtn: {
        flex: 0,
        width: W750(210),
        height: W750(60),
        borderWidth: 1,
        borderColor: '#2dade6',
        borderRadius: 4,
        // justifyContent: 'center',
        justifyContent: 'space-between',
        alignItems: 'center',
        flexDirection: 'row',
    },
    filterResultView: {
        flex: 1,
        paddingBottom: W750(80),
        backgroundColor: '#fff',
    },
    filterResultTitle: {
        flex: 0,
        height: W750(80),
        paddingHorizontal: paddingH,
        justifyContent: 'space-between',
        backgroundColor: '#f5f5f5',
        alignItems: 'center',
        flexDirection: 'row',
    },
    sendBtn: {
        flex: 0,
        height: W750(80),
        backgroundColor: '#0084bf',
        position: 'absolute',
        bottom: 0,
        left:0,
        alignItems: 'center',
        justifyContent: 'center',
    },
});

class CabinFilterModel {
    constructor() {
        this.resultArr = toJS(jsonData);
    }
    @observable cabinArr = ['双人房', '三人房', '四人房'];
    @observable lowPrice = 0;
    @observable highPrice = 10;
    @observable allSelected = false;
    @observable resultArr = [];
    resultArrSelectedStatusArr = new Set();
    cabinSelectedSet = new Set();
    onCabinPressAction = (selected, index) => {
        if (selected) {
            this.cabinSelectedSet.add(index);
        } else {
            this.cabinSelectedSet.delete(index);
        }
        this.filterComplete();
    };
    @action onLowPriceChange = (upOrDown) => {
        let low = this.lowPrice;
        if (upOrDown) {
            low += 1;
            if (low >= this.highPrice) {
                return;
            }
        } else {
            low = low === 0 ? low : low - 1;
        }
        this.lowPrice = low;
        this.filterComplete();
    };
    @action onHighPriceChange = (upOrDown) => {
        let high = this.highPrice;
        if (upOrDown) {
            high += 1;
        } else {
            high = high === 0 ? high : high - 1;
            if (high <= this.lowPrice) {
                return;
            }
        }
        this.highPrice = high;
        this.filterComplete();
    };
    @action filterComplete = () => {
        this.resultArrSelectedStatusArr.clear();
        this.allSelected = false;
        const arr = toJS(jsonData);
        const tempArr = [];
        if (this.cabinSelectedSet.size === 0) {
            if (this.lowPrice <= 3 && this.highPrice >= 4) {
                tempArr.push(arr[4]);
            }
            if (this.lowPrice <= 2 && this.highPrice >= 3) {
                tempArr.push(arr[3]);
            }
            if (this.lowPrice <= 1 && this.highPrice >= 2) {
                tempArr.push(arr[0], arr[1], arr[2]);
            }
        } else {
            if (this.cabinSelectedSet.has(2)) {
                if (this.lowPrice <= 3 && this.highPrice >= 4 ) {
                    tempArr.push(arr[4]);
                }
            }
            if (this.cabinSelectedSet.has(1)) {
                if (this.lowPrice <= 2 && this.highPrice >= 3 ) {
                    tempArr.push(arr[3]);
                }
            }
            if (this.cabinSelectedSet.has(0)) {
                if (this.lowPrice <= 1 && this.highPrice >= 2) {
                    tempArr.push(arr[0], arr[1], arr[2]);
                }
            }
        }
        this.resultArr = tempArr;
    };
    @action selectedAllAction = (allSelected) => {
        this.allSelected = allSelected;
        try {
            if (this.allSelected) {
                for (let i = 0; i < this.resultArr.length; i += 1) {
                    this.resultArrSelectedStatusArr.add(this.resultArr[i].id);
                }
            } else {
                this.resultArrSelectedStatusArr.clear();
            }
        } catch (e) {
            console.log(e);
        }
    };
    @action sendAction = () => {
        if (this.resultArrSelectedStatusArr.size === 0){
            return undefined;
        }
        const _text = '您已经向用户发送了舱位信息。';
        return {
            elemType: MSG_ELEM.PRODUCT_CABIN_ELEM,
            content: {
                id: [...this.resultArrSelectedStatusArr],
            },
            text: _text,
        };
    };
    @action selectedResultArr = (item, selected, index) => {
        if (selected) {
            this.resultArrSelectedStatusArr.add(item.id);
        } else {
            this.resultArrSelectedStatusArr.delete(item.id);
        }
        if (this.resultArr.length === this.resultArrSelectedStatusArr.size) {
            this.allSelected = true;
        } else {
            this.allSelected = false;
        }
    }
}


@observer
class CabinFilterRow extends Component {
    static propTypes = {
        width: PropTyps.number,
        height: PropTyps.number,
    };
    static defaultProps = {
        width: 0,
        height: 0,
    };
    constructor(props){
        super(props);
        this.model = new CabinFilterModel();
    }
    model: CabinFilterModel = null;
    keyExtractor = (item, index) => {
        return `result@${index}`;
    };

    @action checkSelectedStatus = (itemId) => {
        return this.model.resultArrSelectedStatusArr.has(itemId);
    };

    renderFilterContent = () => {
        const _width = this.props.width;
        const itemRowStyle = [CabinFilterRowStyle.contentItemStyle, { width: _width - (2 * paddingH) }];
        const itemContentStyle = [CabinFilterRowStyle.contentItemBtnGroup, { width: _width - (2 * paddingH) }];
        const voyageArr = toJS(this.model.cabinArr);
        return (
            <View style={[CabinFilterRowStyle.filterContentView, { width: _width }]}>
                <View style={itemRowStyle}>
                    <Text style={CabinFilterRowStyle.contentItemTitle}>房间人数</Text>
                    <View style={itemContentStyle}>
                        {voyageArr.map((value, index, arr) => {
                            return (
                                <FilterBtn
                                    key={`cabin@${index}`}
                                    style={CabinFilterRowStyle.filterBtn}
                                    onPressAction={(selected) => {
                                        this.model.onCabinPressAction(selected, index);
                                    }}
                                >{`${value}`}</FilterBtn>
                            );
                        })}
                    </View>
                </View>
                <View style={itemRowStyle}>
                    <Text style={CabinFilterRowStyle.contentItemTitle}>价格区间（万元/人）</Text>
                    <View style={itemContentStyle}>
                        <View style={CabinFilterRowStyle.selectDateBtn}>
                            <IncreaseBtn
                                disabled={false}
                                onPress={() => {
                                    this.model.onLowPriceChange(false);
                                }}
                                isIncrease={false}
                            />
                            <Text style={{ fontSize: 14, textAlign: 'center', padding: 0, flex: 1 }}>{`${this.model.lowPrice}`}</Text>
                            <IncreaseBtn
                                disabled={false}
                                onPress={() => {
                                    this.model.onLowPriceChange(true);
                                }}
                                isIncrease={true}
                            />
                            {/*<TextInput*/}
                                {/*style={{ width: W750(210), fontSize: 14, textAlign: 'center', padding: 0, flex: 1 }}*/}
                                {/*autoCapitalize={'none'}*/}
                                {/*keyboardType={'numeric'}*/}
                                {/*placeholderTextColor={'#999999'}*/}
                                {/*placeholder={'最低价格'}*/}
                                {/*value={this.model.lowPrice}*/}
                                {/*onChangeText={this.model.onLowPriceChange}*/}
                                {/*underlineColorAndroid={'transparent'}*/}
                            {/*/>*/}
                        </View>
                        <View style={{ height: 2, width: W750(24), backgroundColor: '#2dade6' }} />
                        <View style={CabinFilterRowStyle.selectDateBtn}>
                            <IncreaseBtn
                                disabled={false}
                                onPress={() => {
                                    this.model.onHighPriceChange(false);
                                }}
                                isIncrease={false}
                            />
                            <Text style={{ fontSize: 14, textAlign: 'center', padding: 0, flex: 1 }}>{`${this.model.highPrice}`}</Text>
                            <IncreaseBtn
                                disabled={false}
                                onPress={() => {
                                    this.model.onHighPriceChange(true);
                                }}
                                isIncrease={true}
                            />
                            {/*<TextInput*/}
                                {/*style={{ width: W750(210), fontSize: 14, textAlign: 'center', padding: 0, flex: 1 }}*/}
                                {/*autoCapitalize={'none'}*/}
                                {/*keyboardType={'numeric'}*/}
                                {/*placeholderTextColor={'#999999'}*/}
                                {/*placeholder={'最高价格'}*/}
                                {/*value={this.model.highPrice}*/}
                                {/*onChangeText={this.model.onHighPriceChange}*/}
                                {/*underlineColorAndroid={'transparent'}*/}
                            {/*/>*/}
                        </View>
                    </View>
                </View>
            </View>
        );
    };
    renderFilterTitle = () => {
        const _width = this.props.width;
        return (
            <View style={[CabinFilterRowStyle.filterTitleView, { width: _width }]}>
                <View style={{ flexDirection: 'row' }}>
                    <Image source={Constants.Images.CHAT_PRODUCT_FILTER} resizeMode={'contain'} style={CabinFilterRowStyle.filterImage} />
                    <Text style={{ marginLeft: 5, color: '#666' }}>筛选</Text>
                </View>
                {/*<TouchableOpacity onPress={this.model.filterComplete}>*/}
                    {/*<Text style={{ color: '#2dade6', textDecorationLine: 'underline' }}>完成</Text>*/}
                {/*</TouchableOpacity>*/}
            </View>
        );
    };
    renderResultFlatListItem = ({item, index}) => {
        return (
            <CabinResultItem
                item={toJS(item)}
                selected={this.checkSelectedStatus(item.id)}
                pressItemAction={(_item, selected) => {
                    this.model.selectedResultArr(toJS(item), selected, index);
                }}
            />
        );
    };
    renderFilterResultList = () => {
        const _width = this.props.width;
        return (
            <FlatList
                style={{ flex: 1, width: _width }}
                data={this.model.resultArr}
                renderItem={this.renderResultFlatListItem}
                keyExtractor={this.keyExtractor}
                extraData={this.model.allSelected}
            />
        );
    };
    renderSelectBtnsGroup = () => {
        const _width = this.props.width;
        return (
            <View style={{ flex: 0, height: W750(83), width: _width, flexDirection: 'row', alignItems: 'center', paddingHorizontal: paddingH }}>
                <SelectBtn style={{ width: 52, height: 16 }} selected={this.model.allSelected} onPressAction={this.model.selectedAllAction}>全选</SelectBtn>
                {/*<SelectBtn style={{ marginLeft: 14, width: 52, height: 16 }}>反选</SelectBtn>*/}
            </View>
        );
    };
    renderFilterResult = () => {
        const _width = this.props.width;
        return (
            <View style={CabinFilterRowStyle.filterResultView}>
                <View style={CabinFilterRowStyle.filterResultTitle}>
                    <View style={{ flexDirection: 'row' }}>
                        <Image
                            style={[CabinFilterRowStyle.filterImage, { tintColor: '#666666' }]}
                            resizeMode={'contain'}
                            source={Constants.Images.CHAT_PRODUCT_VOYAGE}
                        />
                        <Text style={{ marginLeft: 5, color: '#666' }}>舱位</Text>
                    </View>
                    <Text style={{ color: '#666' }}>共{toJS(this.model.resultArr).length}条</Text>
                </View>
                {this.renderSelectBtnsGroup()}
                {this.renderFilterResultList()}
            </View>
        );
    };
    sendAction = () => {
        const msg = this.model.sendAction();
        if (msg === undefined) return;
        if (this.props.sendAction) {
            this.props.sendAction(msg);
        }
    };
    render() {
        const _width = this.props.width;
        return (
            <View style={[CabinFilterRowStyle.container, { width: _width, height: this.props.height }]}>
                {this.renderFilterTitle()}
                {this.renderFilterContent()}
                {this.renderFilterResult()}
                <TouchableOpacity
                    style={[CabinFilterRowStyle.sendBtn, { width: _width }]}
                    onPress={this.sendAction}
                >
                    <Text style={{ color: '#fff', fontSize: 18 }}>发送</Text>
                </TouchableOpacity>
            </View>
        );
    }
}

export default CabinFilterRow;
