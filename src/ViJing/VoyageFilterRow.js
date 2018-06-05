/**
 * Created by aby.wang on 2017/11/27.
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
} from 'react-native';
import { observer } from 'mobx-react/native';
import { observable, action, runInAction, toJS, computed } from 'mobx';
import Constants from '../global/Constants';
import { W750, MSG_ELEM } from '../global/Constants/Dimensions';
import { FilterBtn, SelectBtn, DatePicker  } from '../component';
import ResultItem from './ResultItem';

const paddingH = W750(40);

const VoyageFilterRowStyle = StyleSheet.create({
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
        justifyContent: 'center',
        alignItems: 'center',
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
    filterResultItemStyle: {
        flex: 0,
        minHeight: W750(90),
        backgroundColor: '#ffff',
        paddingHorizontal: paddingH,
        justifyContent: 'flex-start',
        marginBottom: W750(60),
    },
    filterResultItemTitle: {
        flexDirection: 'row',
        flex: 1,
        justifyContent: 'flex-start',
    },
    filterResultItemSubTitle: {
        flexDirection: 'row',
        flex: 1,
        justifyContent: 'space-between',
    },
    filterResultItemSubText: {
        fontSize: 14,
        color: '#999999',
    },
});

const jsonData = [
    {
        id: 3,
        description: 'XX年XX月XX日',
        price: '￥18888/人 起',
        departure_place: '阿姆斯特朗',
        destination: '巴塞尔',
        name: '莱茵河之旅 阿姆斯特朗-巴塞尔',
        days: 11,
    },
    {
        id: 4,
        description: 'XX年XX月XX日',
        price: '￥18888/人 起',
        departure_place: '阿姆斯特朗',
        destination: '巴塞尔',
        name: '多瑙河 阿姆斯特朗-巴塞尔',
        days: 11,
    },
    {
        id: 5,
        description: 'XX年XX月XX日',
        price: '￥18888/人 起',
        departure_place: '阿姆斯特朗',
        destination: '巴塞尔',
        name: '欧洲之旅 阿姆斯特朗-巴塞尔',
        days: 11,
    },
];

class VoyageFilterModel {
    constructor() {
        this.resultArr = toJS(jsonData);
    }
    @observable voyageArr = ['莱茵河', '多瑙河', '欧洲全景'];
    @observable dayArr = ['8日', '11日', '15日'];
    @observable startDate = '';
    @observable endDate = '';
    @observable allSelected = false;
    @observable showDate = false;
    @observable dateKey = '';
    @observable resultArr = [];
    resultArrSelectedStatusArr = new Set();
    voyageSelectedSet = [false, false, false];
    daysSelectedSet = [false, false, false];
    onVoyagePressAction = (selected, index) => {
        this.voyageSelectedSet[index] = selected;
        this.filterComplete();
    }
    onDaysPressAction = (selected, index) => {
        this.daysSelectedSet[index] = selected;
        this.filterComplete();
    }
    @action selectedStartDay = () => {
        this.showDate = true;
        this.dateKey = 'start';
    }
    @action selectedEndDay = () => {
        this.showDate = true;
        this.dateKey = 'end';
    }
    @action filterComplete = () => {
        this.resultArrSelectedStatusArr.clear();
        this.allSelected = false;
        const arr = toJS(jsonData);
        const voyageS = this.voyageSelectedSet;
        const daysS = this.daysSelectedSet;
        let needVoyage = true;
        let needDays = true;
        if (!(voyageS[0] || voyageS[1] || voyageS[2])){
            // 航线无需筛选
            needVoyage = false;
        }
        if (!(daysS[0] || daysS[1] || daysS[2])){
            // 天数无需筛选
            needDays = false;
        }
        if (!needDays && !needVoyage ) {
            this.resultArr = arr;
            return;
        }
        let tempArr = [];
        for (let i = 0;i < 3; i += 1) {
            if ((!needVoyage||voyageS[i]) && (!needDays || daysS[i])){
                tempArr.push(arr[i]);
            }
        }
        this.resultArr = tempArr;
    }
    @action selectedAllAction = (allSelected) => {
        this.allSelected = allSelected;
        if (this.allSelected) {
            for (let i = 0; i < this.resultArr.length; i += 1) {
                this.resultArrSelectedStatusArr.add(this.resultArr[i].id);
            }
        } else {
            this.resultArrSelectedStatusArr.clear();
        }
    }
    @action sendAction = () => {
        if (this.resultArrSelectedStatusArr.size === 0) {
            return undefined;
        }
        let text = '您已经向客户发送了:';
        let index = 0;
        try {
            for (const i of this.resultArrSelectedStatusArr) {
                text += ` ${this.voyageArr[i - 3]} `;
                index++;
            }
        } catch (e) {
            console.log(e);
        }
        text += '航线信息';
        return {
            elemType: MSG_ELEM.PRODUCT_VOYAGE_ELEM,
            content: {
                id: [...this.resultArrSelectedStatusArr],
            },
            text: text,
        };
    }
    @action handleDate = (date:? Date, key) => {
        this.showDate = false;
        if (date === undefined) {
            return;
        }
        if (key === 'start') {
            this.startDate = `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
        } else if (key === 'end') {
            this.endDate = `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
        }
    }
    // 选择相应的航线函数
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
class VoyageFilterRow extends Component {
    static propTypes = {
        width: PropTyps.number,
        height: PropTyps.number,
        sendAction: PropTyps.func,
    };
    static defaultProps = {
        width: 0,
        height: 0,
        sendAction: () => {},
    };
    constructor(props) {
        super(props);
        this.model = new VoyageFilterModel();
    }
    model:? VoyageFilterModel = null;
    keyExtractor = (item, index) => `result@${index}`;

    @action checkSelectedStatus = (itemId) => {
        return this.model.resultArrSelectedStatusArr.has(itemId);
    };

    renderFilterContent = () => {
        const _width = this.props.width;
        const itemRowStyle = [VoyageFilterRowStyle.contentItemStyle, { width: _width - (2 * paddingH) }];
        const itemContentStyle = [VoyageFilterRowStyle.contentItemBtnGroup, { width: _width - (2 * paddingH) }];
        const voyageArr = this.model.voyageArr;
        const dayArr = this.model.dayArr;
        return (
            <View style={[VoyageFilterRowStyle.filterContentView, { width: _width }]}>
                <View style={itemRowStyle}>
                    <Text style={VoyageFilterRowStyle.contentItemTitle}>航线</Text>
                    <View style={itemContentStyle}>
                        {voyageArr.map((value, index, arr) => (
                                <FilterBtn
                                    key={`VoyageSelected${index}`}
                                    style={VoyageFilterRowStyle.filterBtn}
                                    onPressAction={(selected) => {
                                        this.model.onVoyagePressAction(selected, index);
                                    }}
                                >
                                    {`${value}`}
                                </FilterBtn>
                            ))}
                    </View>
                </View>
                <View style={itemRowStyle}>
                    <Text style={VoyageFilterRowStyle.contentItemTitle}>天数</Text>
                    <View style={itemContentStyle}>
                        {dayArr.map((value, index, arr) => (
                                <FilterBtn
                                    key={`DaysSelected${index}`}
                                    style={VoyageFilterRowStyle.filterBtn}
                                    onPressAction={(selected) => {
                                        this.model.onDaysPressAction(selected, index);
                                    }}
                                >
                                    {`${value}`}
                                </FilterBtn>
                            ))}
                    </View>
                </View>
                <View style={itemRowStyle}>
                    <Text style={VoyageFilterRowStyle.contentItemTitle}>日期</Text>
                    <View style={itemContentStyle}>
                        <TouchableOpacity style={VoyageFilterRowStyle.selectDateBtn} onPress={this.model.selectedStartDay}>
                            <Text style={{ fontSize: 14, color: '#999999' }}>{this.model.startDate || '最早出发'}</Text>
                        </TouchableOpacity>
                        <View style={{ height: 2, width: W750(24), backgroundColor: '#2dade6' }} />
                        <TouchableOpacity style={VoyageFilterRowStyle.selectDateBtn} onPress={this.model.selectedEndDay}>
                            <Text style={{ fontSize: 14, color: '#999999' }}>{this.model.endDate || '最晚出发'}</Text>
                        </TouchableOpacity>
                        <Image
                            style={{ height: W750(58), width: W750(58), tintColor: '#2dade6' }}
                            source={Constants.Images.CHAT_PRODUCT_DATE}
                            resizeMode={'contain'}
                        />
                    </View>
                </View>
            </View>
        );
    };
    renderFilterTitle = () => {
        const _width = this.props.width;
        return (
            <View style={[VoyageFilterRowStyle.filterTitleView, { width: _width }]}>
                <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                    <Image source={Constants.Images.CHAT_PRODUCT_FILTER} resizeMode={'contain'} style={VoyageFilterRowStyle.filterImage} />
                    <Text style={{ marginLeft: 5, color: '#666' }}>筛选</Text>
                </View>
                {/*<TouchableOpacity onPress={this.model.filterComplete}>*/}
                    {/*<Text style={{ color: '#2dade6', textDecorationLine: 'underline' }}>完成</Text>*/}
                {/*</TouchableOpacity>*/}
            </View>
        );
    };
    renderResultFlatListItem = ({ item, index }) => {
        return (
            <ResultItem 
                item={toJS(item)}
                pressItemAction={(_item, selected) => {
                    this.model.selectedResultArr(toJS(item), selected, index);
                }}
                selected={this.checkSelectedStatus(item.id)}
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
                // listHeaderComponent={}
            />
        );
    };
    renderSelectBtnsGroup = () => {
        const _width = this.props.width;
        return (
            <View style={{ flex: 0, height: W750(83), width: _width, flexDirection: 'row', alignItems: 'center', paddingHorizontal: paddingH }}>
                <SelectBtn style={{ width: 52, height: 16 }} selected={this.model.allSelected} onPressAction={this.model.selectedAllAction}>全选</SelectBtn>
                {/* <SelectBtn style={{ marginLeft: 14, width: 52, height: 16 }} seleted={this.model.deselected}>反选</SelectBtn> */}
            </View>
        );
    };
    renderFilterResultTitle= () => (
            <View style={VoyageFilterRowStyle.filterResultTitle}>
                <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                    <Image
                        style={[VoyageFilterRowStyle.filterImage, { tintColor: '#666666' }]}
                        resizeMode={'contain'}
                        source={Constants.Images.CHAT_PRODUCT_VOYAGE}
                    />
                    <Text style={{ marginLeft: 5, color: '#666' }}>航次</Text>
                </View>
                <Text style={{ color: '#666' }}>共{toJS(this.model.resultArr).length}条</Text>
            </View>
        );
    renderFilterResult = () => (
            <View style={VoyageFilterRowStyle.filterResultView}>
                {this.renderFilterResultTitle()}
                {this.renderSelectBtnsGroup()}
                {this.renderFilterResultList()}
            </View>
        );
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
            <View style={[VoyageFilterRowStyle.container, { width: _width, height: this.props.height }]}>
                {this.renderFilterTitle()}
                {this.renderFilterContent()}
                {this.renderFilterResult()}
                <TouchableOpacity style={[VoyageFilterRowStyle.sendBtn, { width: _width }]} onPress={this.sendAction}>
                    <Text style={{ color: '#fff', fontSize: 18 }}>发送</Text>
                </TouchableOpacity>
                <DatePicker handleDatePicked={this.model.handleDate} show={this.model.showDate} dateID={this.model.dateKey} />
            </View>
        );
    }
}

export default VoyageFilterRow;
