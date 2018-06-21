/**
 * Created by phoobobo on 2017/11/28.
 * Dragon Trail Interactive All Rights Reserved.
 */
import React, { Component } from 'react';
import {
    StyleSheet,
    View,
    Image,
    Text,
    ScrollView,
    TouchableOpacity,
    Picker,
    Platform,
} from 'react-native';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react/native';
import { observable, action, runInAction, toJS } from 'mobx';
import Constants from '../global/Constants';
import { W750, MSG_ELEM } from '../global/Constants/Dimensions';
import { CabinFilterRowStyle } from './CabinFilterRow';
import { DatePicker, SelectedHookBtn, FilterBtn, IncreaseBtn } from '../component';

const paddingH = W750(40);

const OrderFilterRowStyle = StyleSheet.create({
    container: {
        flex: 0,
        justifyContent: 'flex-start',
        backgroundColor: '#fff',
        paddingBottom: W750(80),
    },
    selectDateBtn: {
        flex: 0,
        width: W750(471),
        height: W750(60),
        borderWidth: 1,
        borderColor: '#2dade6',
        borderRadius: 4,
        justifyContent: 'center',
        alignItems: 'center',
    },
    selectVoyageBtn: {
        flex: 0,
        height: W750(60),
        borderWidth: 1,
        borderColor: '#2dade6',
        borderRadius: 4,
        justifyContent: 'flex-start',
        alignItems: 'center',
        flexDirection: 'row',
        paddingHorizontal: W750(30),
    },
    cabinItemRow: {
        flex: 1,
        flexDirection: 'row',
        height: W750(65),
        justifyContent: 'flex-start',
        alignItems: 'center',
    },
    cabinNameText: {
        color: '#333333',
        fontSize: 16,
        marginHorizontal: W750(15),
    },
    buttonDecrease: {
        height: W750(65),
        width: W750(58),
        justifyContent: 'center',
        alignItems: 'center',
    },
    buttonDecreaseImage: {
        height: W750(33),
        width: W750(38),
    },
});

class OrderFilterModel {
    @observable date = '';
    @observable showDatePicker = false;
    @observable voyageList = [
        { id: 1, title: '11日 莱茵河浪漫之旅 阿姆斯特丹-巴塞尔' },
        { id: 2, title: '8日 多瑙河之旅 布达佩斯-维也纳' },
        { id: 3, title: '15日 欧洲全景之旅 巴塞尔-维也纳' },
    ];
    @observable voyageIndex = 0;
    @observable showVoyagePicker = false;

    @observable cabinList = [
        { id: 1, name: '标准套房', count: 0, chosen: false },
        { id: 2, name: '奢享家套房', count: 0, chosen: false },
        { id: 3, name: '奢华阳台套房', count: 0, chosen: false },
        { id: 4, name: '精致阳台房', count: 0, chosen: false },
        { id: 5, name: '浪漫法式露台房', count: 0, chosen: false },
    ];

    @observable moreServices = [
        { id: 1, name: '机票服务', chosen: false },
        { id: 2, name: '签证服务', chosen: false },
        { id: 3, name: '保险服务', chosen: false },
    ];

    @action toggleServiceChosen = (index, chosen) => {
        this.moreServices[index].chosen = chosen;
    };

    @action onSelectCabin = (index) => {
        this.cabinList[index].chosen = !this.cabinList[index].chosen;
        if (!this.cabinList[index].chosen) {
            this.cabinList[index].count = 0;
        }
    };
    @action onIncreaseCabinCount = (index) => {
        this.cabinList[index].count++;
        this.cabinList[index].chosen = true;
    };
    @action onDecreaseCabinCount = (index) => {
        if (this.cabinList[index].count === 0) {
            this.cabinList[index].chosen = false;
            return;
        }
        this.cabinList[index].count--;
    };

    @action toggleVoyagePickerShowing = () => {
        this.showVoyagePicker = !this.showVoyagePicker;
    };

    @action onVoyageSelected = (index) => {
        this.voyageIndex = index;
        this.showVoyagePicker = false;
    };

    @action onSelectDate = () => {
        this.showDatePicker = true;
    };
    @action handleDatePicked = (date) => {
        this.showDatePicker = false;
        if (date === undefined) return;
        this.showDatePicker = false;
        // console.log(date);
        this.date = `${date.getFullYear()}-${date.getMonth() + 1}-${date.getUTCDate()}`;
    };
    sendAction = () => {
        const cabinSelectedList = this.cabinList.filter(item => item.chosen);
        const moreServicesList = this.moreServices.filter(item => item.chosen);
        if (this.date === '' || cabinSelectedList.length === 0 || moreServicesList === 0) {
            return undefined;
        }
        const result = {
            start_date: this.date,
            voyage: this.voyageList[this.voyageIndex].id,
            space: cabinSelectedList,
            service: moreServicesList,
        };
        return {
            elemType: MSG_ELEM.PRODUCT_ORDER_ELEM,
            content: result,
            text: '您已向客户发送订单信息',
        };
    }
}

@observer
export default class OrderFilterRow extends Component {
    static propTypes = {
        width: PropTypes.number,
        height: PropTypes.number,
        sendAction: PropTypes.func,
    };
    static defaultProps = {
        width: 0,
        height: 0,
        sendAction: () => {},
    };
    constructor(props) {
        super(props);
        this.model = new OrderFilterModel();
    }
    model = null;
    sendAction = () => {
        const msg = this.model.sendAction();
        if (msg === undefined) return;
        if (this.props.sendAction) {
            this.props.sendAction(msg);
        }
    };
    renderFilterTitle() {
        const _width = this.props.width;
        return (
            <View style={[CabinFilterRowStyle.filterTitleView, { width: _width }]}>
                <View style={{ flexDirection: 'row' }}>
                    <Image source={Constants.Images.CHAT_PRODUCT_ORDER} resizeMode={'contain'} style={CabinFilterRowStyle.filterImage} />
                    <Text style={{ marginLeft: 5, color: '#666' }}>创建订单</Text>
                </View>
            </View>
        );
    }
    renderCabinItem(index) {
        const item = this.model.cabinList[index];
        const cannotDecrease = item.count === 0;
        return (
            <View style={OrderFilterRowStyle.cabinItemRow} key={index}>
                <SelectedHookBtn
                    selected={item.chosen}
                    onPressAction={() => this.model.onSelectCabin(index)}
                    width={W750(32)}
                    height={W750(32)}
                />
                <TouchableOpacity onPress={() => this.model.onSelectCabin(index)}>
                    <Text style={OrderFilterRowStyle.cabinNameText}>{item.name}</Text>
                </TouchableOpacity>
                <View style={{ flex: 1 }} />
                <IncreaseBtn
                    disabled={cannotDecrease}
                    onPress={() => this.model.onDecreaseCabinCount(index)}
                    isIncrease={false}
                />
                <Text style={OrderFilterRowStyle.cabinNameText}>{item.count}</Text>
                <IncreaseBtn
                    disabled={false}
                    onPress={() => this.model.onIncreaseCabinCount(index)}
                    isIncrease={true}
                />
            </View>
        );
    }
    renderContent() {
        const _width = this.props.width;
        const itemRowStyle = [CabinFilterRowStyle.contentItemStyle, { width: _width - (2 * paddingH) }];
        const itemContentStyle = [CabinFilterRowStyle.contentItemBtnGroup, { width: _width - (2 * paddingH) }];
        const moreServices = ['机票服务', '签证服务', '保险服务'];
        const voyagePickerItems = [];
        const voyageList = toJS(this.model.voyageList);
        for (const index in voyageList) {
            voyagePickerItems.push(
                <Picker.Item label={voyageList[index].title} value={index} key={index} />
            );
        }
        const cabinListView = [];
        for (const index in toJS(this.model.cabinList)) {
            cabinListView.push(this.renderCabinItem(index));
        }
        return (
            <ScrollView
                style={[CabinFilterRowStyle.filterContentView, { width: _width, paddingBottom: W750(130) }]}
                showsVerticalScrollIndicator={false}
            >
                <View style={itemRowStyle}>
                    <Text style={CabinFilterRowStyle.contentItemTitle}>选择船期</Text>
                    <View style={itemContentStyle}>
                        <TouchableOpacity style={OrderFilterRowStyle.selectDateBtn} onPress={this.model.onSelectDate}>
                            <Text style={{ fontSize: 14, color: this.model.date ? '#333333' : '#999999' }}>{this.model.date || '选择船期'}</Text>
                        </TouchableOpacity>
                        <Image
                            style={{ height: W750(58), width: W750(58), tintColor: '#2dade6' }}
                            source={Constants.Images.CHAT_PRODUCT_DATE}
                            resizeMode={'contain'}
                        />
                    </View>
                </View>
                <View style={itemRowStyle}>
                    <Text style={CabinFilterRowStyle.contentItemTitle}>选择航线</Text>
                    {Platform.OS === 'android' ?
                        <View
                            style={[OrderFilterRowStyle.selectVoyageBtn, { width: _width - (2 * paddingH) }]}
                        >
                            <Picker
                                selectedValue={this.model.voyageIndex}
                                onValueChange={this.model.onVoyageSelected}
                                mode={'dropdown'}
                                style={{ flex: 1 }}
                            >
                                {voyagePickerItems}
                            </Picker>
                        </View> : <TouchableOpacity
                            style={[OrderFilterRowStyle.selectVoyageBtn, { width: _width - (2 * paddingH) }]}
                            onPress={this.model.toggleVoyagePickerShowing}
                        >
                            <Text style={{ fontSize: 14, color: '#333333', maxWidth: W750(420) }} numberOfLines={1}>
                                {this.model.voyageList[this.model.voyageIndex].title}
                            </Text>
                            <View style={{ flex: 1 }} />
                            <Image
                                source={Constants.Images.UPSIDE_DOWN_TRIANGLE}
                                style={{ width: W750(25), height: W750(14) }}
                            />
                        </TouchableOpacity>
                    }

                    {this.model.showVoyagePicker && Platform.OS === 'ios' ?
                        <View style={{ position: 'absolute', bottom: 0, left: 0, right: 0, flex: 0, backgroundColor: 'white' }}>
                            <Picker
                                selectedValue={this.model.voyageIndex}
                                onValueChange={this.model.onVoyageSelected}
                                mode={'dropdown'}
                            >
                                {voyagePickerItems}
                            </Picker>
                        </View> : <View />}
                </View>
                <View style={itemRowStyle}>
                    <Text style={CabinFilterRowStyle.contentItemTitle}>选择舱位</Text>
                    {cabinListView}
                </View>
                <View style={[itemRowStyle, {marginBottom: W750(20)}]}>
                    <Text style={CabinFilterRowStyle.contentItemTitle}>附加服务</Text>
                    <View style={itemContentStyle}>
                        {moreServices.map((value, index, arr) => {
                            return (
                                <FilterBtn
                                    style={CabinFilterRowStyle.filterBtn}
                                    onPressAction={chosen => this.model.toggleServiceChosen(index, chosen)}
                                >{`${value}`}
                                </FilterBtn>
                            );
                        })}
                    </View>
                </View>
            </ScrollView>
        );
    }
    render() {
        const _width = this.props.width;
        return (
            <View style={[OrderFilterRowStyle.container, { width: _width, height: this.props.height }]}>
                {this.renderFilterTitle()}
                {this.renderContent()}
                <TouchableOpacity
                    style={[CabinFilterRowStyle.sendBtn, { width: _width }]}
                    onPress={this.sendAction}
                >
                    <Text style={{ color: '#fff', fontSize: 18 }}>发送</Text>
                </TouchableOpacity>
                <DatePicker handleDatePicked={this.model.handleDatePicked} show={this.model.showDatePicker} />
            </View>
        );
    }
}