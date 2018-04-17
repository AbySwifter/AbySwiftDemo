/**
 * Created by aby.wang on 2018/4/13.
 */

/**
 * Created by aby.wang on 2017/11/16.
 * 选择好的日期为两个，从this.model.selectDateArr中取，小的在前，大的在后，为时间戳
 */
import React, { Component } from 'react';
import {
    View,
    Text,
    StyleSheet,
    TouchableOpacity,
    FlatList,
} from 'react-native';
import { persist } from 'mobx-persist';
import { observer } from 'mobx-react/native';
import { observable, action, runInAction, toJS, autoRun, computed } from 'mobx';
import D, { W } from './Demissions';
import CalendarItemView from './CalendarItemView';
import CalendarManager from './Calendar';
import CalendarDataStore from './CalendarDataStore';

const _MarginHor = 15;
const _MarginTop = 22.5;
const _ContainerBackgroundColor = '#f5f5f5';

const SelectedDateStyle = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'flex-start',
        alignItems: 'center',
        backgroundColor: _ContainerBackgroundColor,
    },
    headerStyle: {
        flex: 0,
        marginHorizontal: _MarginHor,
        marginTop: _MarginTop,
        height: W(150),
        width: D.ScreenW - (2 * _MarginHor),
        backgroundColor: '#fff',
        // alignItems: 'center',
    },
    selectTitleViewStyle: {
        flex: 0,
        height: W(90),
        width: D.ScreenW - (2 * _MarginHor),
        justifyContent: 'center',
        alignItems: 'center',
        paddingHorizontal: 15,
    },
    selectTitle: {
        flex: 0,
        fontSize: 16,
        fontWeight: '500',
        color: '#000',
    },
    dayTitleViewStyle: {
        flex: 0,
        width: D.ScreenW - (4 * _MarginHor),
        height: W(60),
        flexDirection: 'row',
        justifyContent: 'space-between',
        // paddingHorizontal: _MarginHor,
        alignItems: 'center',
        borderTopWidth: W('minPix') * 2,
        borderTopColor: '#f0f0f0',
        alignSelf: 'center',
    },
    cancelBtnStyle: {
        flex: 0,
        height: W(90),
        minWidth: W(90),
        position: 'absolute',
        top: 0,
        left: 0,
        justifyContent: 'center',
        alignItems: 'center',
        paddingHorizontal: _MarginHor,
    },
    cancelText: {
        fontSize: 16,
        color: '#000',
    },
    flatListStyle: {
        flex: 1,
    },
});

/**
 * 处理选择页面的数据逻辑
 */
class SelectedDateModel {
    constructor() {
        this.calendarManager = new CalendarManager();
    }
    calendarManager: CalendarManager = null;
    @observable years;
    @observable calendarDataArr = [];
    @observable selectDateArr = [];
    @computed get selectedOK() {
        return this.selectDateArr >= 2;
    }
    @action createData = () => {
        if (CalendarDataStore.calendarDataArr.length !== 0 && CalendarDataStore.calendarDataArr[11].month === this.calendarManager.month) {
            this.originDataArr = toJS(CalendarDataStore.calendarDataArr);
            this.calendarDataArr = toJS(CalendarDataStore.calendarDataArr);
            return;
        }
        // 生成当年的数据
        for (let i = 11; i >= 0; i -= 1) {
            // 年、月的计算，push顺序
            let _month = this.calendarManager.month - i;
            if (_month <= 0) {
                _month = 12 - _month;
            }
            const tempObj = {
                month: _month,
                year: this.calendarManager.month - i - 1 < 0 ? this.calendarManager.year - 1 : this.calendarManager.year,
                isSelectedAll: false,
                startDate: -1,
                endDate: -1,
            };
            this.calendarDataArr.push(tempObj);
        }
        this.originDataArr = toJS(this.calendarDataArr);
        CalendarDataStore.calendarDataArr = this.calendarDataArr;
    }
    originDataArr = [];
    @action onItemPress = (dateInfo) => {
        this.selectedDate(dateInfo.year, dateInfo.month, dateInfo.date);
    }
    @action selectedDate = (year, month, day) => {
        const time = new Date(year, month - 1, day);
        if (this.selectDateArr.length >= 2) {
            this.pressCancel();
        }
        if (this.selectDateArr.length === 0) {
            this.selectDateArr.push(time.valueOf());
        } else if (time.valueOf() !== this.selectDateArr[0]) {
            this.selectDateArr.push(time.valueOf());
            // console.log(toJS(this.selectDateArr));
            this.selectDateArr = toJS(this.selectDateArr).sort(function (a, b) {
                return a - b;
            }); // 排序
            // console.log(toJS(this.selectDateArr));
        }
        this.changeUI();
    }
    @action changeUI = () => {
        if (this.calendarDataArr.length === 0) return;
        let tepStart = null;
        let startMonth = -1;
        let startYear = -1;
        let startDay = -1;
        if (this.selectDateArr.length === 1) {
            tepStart = this.selectDateArr[0];
            if (tepStart) {
                const startDate = new Date(tepStart);
                startMonth = startDate.getMonth() + 1;
                startYear = startDate.getFullYear();
                startDay = startDate.getDate();
                const tempObj = {
                    month: startMonth,
                    year: startYear,
                    isSelectedAll: false,
                    startDate: startDay,
                    endDate: -1,
                };
                const monthNum = this.calendarManager.month - startMonth;
                const tempArr = toJS(this.calendarDataArr);
                if (monthNum >= 0) {
                    tempArr[11 - monthNum] = tempObj;
                } else {
                    tempArr[-monthNum - 1] = tempObj;
                }
                this.calendarDataArr = toJS(tempArr);
            }
        } else if (this.selectDateArr.length === 2) {
            let tepStart = this.selectDateArr[0];
            let startMonth = -1;
            let startYear = -1;
            let startDay = -1;
            let tepEnd = this.selectDateArr[1];
            let endMonth = -1;
            let endYear = -1;
            let endDay = -1;
            if (tepStart) {
                const startDate = new Date(tepStart);
                startMonth = startDate.getMonth() + 1;
                startYear = startDate.getFullYear();
                startDay = startDate.getDate();
            }
            if (tepEnd) {
                const endDate = new Date(tepEnd);
                endMonth = endDate.getMonth() + 1;
                endDay = endDate.getDate();
                endYear = endDate.getFullYear();
            }
            if (endMonth === startMonth) {
                const tempObj = {
                    month: startMonth,
                    year: startYear,
                    isSelectedAll: false,
                    startDate: startDay,
                    endDate: endDay,
                };
                const monthNum = this.calendarManager.month - startMonth;
                const tempArr = toJS(this.calendarDataArr);
                const month_index = monthNum >= 0 ? 11 - monthNum : -monthNum - 1;
                tempArr[month_index] = tempObj;
                this.calendarDataArr = toJS(tempArr);
            } else {
                const tempObj_start = {
                    month: startMonth,
                    year: startYear,
                    isSelectedAll: false,
                    startDate: startDay,
                    endDate: -1,
                };
                const tempObj_end = {
                    month: endMonth,
                    year: endYear,
                    isSelectedAll: false,
                    startDate: -1,
                    endDate: endDay,
                };
                const start_monthNum = this.calendarManager.month - startMonth;
                const end_monthNum = this.calendarManager.month - endMonth;
                const tempArr = toJS(this.calendarDataArr);
                const start_index = start_monthNum >= 0 ? 11 - start_monthNum : -start_monthNum - 1;
                const end_index = end_monthNum >= 0 ? 11 - end_monthNum : -end_monthNum - 1;
                tempArr[start_index] = tempObj_start;
                tempArr[end_index] = tempObj_end;
                if (Math.abs(start_monthNum - end_monthNum) > 1) {
                    for (let i = start_index + 1; i < end_index; i += 1) {
                        tempArr[i] = {
                            month: tempArr[i].month,
                            year: tempArr[i].year,
                            isSelectedAll: true,
                            startDate: -1,
                            endDate: -1,
                        };
                    }
                }
                this.calendarDataArr = toJS(tempArr);
            }
        }
    }
    @action pressCancel = () => {
        this.selectDateArr = [];
        if (this.originDataArr.length !== 0) {
            this.calendarDataArr = this.originDataArr;
        }
    }
}

@observer
class SelectedDatePage extends Component {
    static navigatorStyle = {
        tabBarHidden: true,
    };
    model: ?SelectedDateModel = null;
    @observable showFlatList = false;
    constructor(props) {
        super(props);
        this.model = new SelectedDateModel();
    }
    componentDidMount() {
        // 延迟创建，（Android端的渲染有点问题，需要进一步处理下）
        this.model.createData();
        runInAction(() => {
            this.showFlatList = true;
        });
    }
    keyExtractor = (item, index) => {
        return `calendarKey@${index}`;
    }
    /**
     * 返回ListItem
     */
    renderItem = (row) => {
        const item = row.item;
        return (
            <CalendarItemView
                year={item.year}
                month={item.month}
                startDate={item.startDate}
                endDate={item.endDate}
                allSelect={item.isSelectedAll}
                selectedOk={this.model.selectedOK}
                onRowItemPress={this.model.onItemPress}
            />
        );
    }
    /**
     * 返回日期头部视图
     * @returns {*}
     */
    renderHeaderView = () => {
        const titleArr = ['日', '一', '二', '三', '四', '五', '六'];
        const listCom = [];
        titleArr.forEach((obj, index) => {
            listCom.push(
                <Text
                    key={`key@${obj}`}
                    style={{ flex: 0, textAlign: 'center', width: W(40), fontSize: 14 }}
                >
                    {obj}
                </Text>
            );
        });
        return (
            <View style={SelectedDateStyle.headerStyle}>
                <View style={SelectedDateStyle.selectTitleViewStyle}>
                    <TouchableOpacity style={SelectedDateStyle.cancelBtnStyle} onPress={this.model.pressCancel}>
                        <Text style={SelectedDateStyle.cancelText}>取消</Text>
                    </TouchableOpacity>
                    <Text style={SelectedDateStyle.selectTitle}>选择日期</Text>
                </View>
                <View style={SelectedDateStyle.dayTitleViewStyle}>
                    {listCom}
                </View>
            </View>
        );
    }

    renderFlatList = () => {
        return (
            <FlatList
                style={SelectedDateStyle.flatListStyle}
                data={toJS(this.model.calendarDataArr)}
                renderItem={this.renderItem}
                keyExtractor={this.keyExtractor}
                extraData={[this.model.selectDateArr, this.model.selectedOK]}
            />
        );
    }
    render() {
        return (
            <View style={SelectedDateStyle.container}>
                {this.renderHeaderView()}
                {this.renderFlatList()}
            </View>
        );
    }
}

export default SelectedDatePage;
