/**
 * Created by aby.wang on 2018/4/13.
 */
import React, { Component } from 'react';
import PropType from 'prop-types';
import {
    View,
    Text,
    TouchableOpacity,
    StyleSheet,
    ART,
} from 'react-native';
import { observer } from 'mobx-react/native';
import { observable, runInAction } from 'mobx';
import CalenderManager from './Calendar';
import D, { W } from './Demissions';

const { Surface, Shape, Path } = ART;

const _MarginHor = 15;
const _titleHeight = W(60);
const _weekItemHeight = W(136);
const _itemBackground = '#f5f5f5';
const _itemRadius = W(35);

// row index text相关内容常量
const contentWidth = D.ScreenW - (2 * _MarginHor);
const dateView_B_Width = (_itemRadius * 2) + ((contentWidth - 15 - (14 * _itemRadius)) / 6);
const tempWidth = (_itemRadius * 2) + ((contentWidth - 15 - (14 * _itemRadius)) / 12); // 间隙的一半
const selectedStyle = { borderRadius: _itemRadius, backgroundColor: '#0084bf' };
const inSelectedStyle = { backgroundColor: '#cce6f2' };

const CalenderItemStyle = StyleSheet.create({
    container: {
        flex: 0,
        width: contentWidth,
        marginHorizontal: _MarginHor,
        minHeight: (_weekItemHeight * 4) + _titleHeight,
        // maxHeight: (_weekItemHeight * 5) + _titleHeight,
        // height: (_weekItemHeight * 5) + _titleHeight,
        backgroundColor: _itemBackground,
    },
    itemTitleView: {
        flex: 0,
        height: _titleHeight,
        backgroundColor: _itemBackground,
        justifyContent: 'center',
        alignItems: 'center',
    },
    weekItemView: {
        flex: 0,
        height: W(136),
        width: contentWidth,
        paddingHorizontal: 7.5, // 记得计算多余的宽度
        backgroundColor: '#fff',
        // borderTopColor: '#f0f0f0',
        // borderTopWidth: W('minPix') * 2,
        justifyContent: 'space-between',
        alignItems: 'center',
        flexDirection: 'row',
    },
    weekDayBackGroundView: {
        flex: 0,
        height: _itemRadius * 2,
        width: dateView_B_Width,
        backgroundColor: '#fff',
        // paddingHorizontal: 5,
        // width: _itemRadius * 2,
        justifyContent: 'center',
        alignItems: 'center',
    },
    weekDayView: {
        flex: 0,
        // marginHorizontal: 5,
        width: _itemRadius * 2,
        height: _itemRadius * 2,
        justifyContent: 'center',
        alignItems: 'center',
    },
    weekDayText: {
        textAlign: 'center',
        fontSize: 14,
    },
    SAndEBackView: {
        position: 'absolute',
        flex: 0,
        height: _itemRadius * 2,
        width: dateView_B_Width / 2,
        top: 0,
        backgroundColor: '#cce6f2',
    },
});

@observer
class CalendarItemView extends Component {
    static propTypes = {
        year: PropType.number.isRequired,
        month: PropType.number.isRequired,
        startDate: PropType.number,
        endDate: PropType.number,
        allSelect: PropType.bool,
        onRowItemPress: PropType.func,
        selectedOk: PropType.bool,
    }
    static defaultProps = {
        startDate: -1,
        endDate: -1,
        allSelect: false,
        onRowItemPress: (dateInfo) => {
            // console.log(`点击了${dateInfo.year}/${dateInfo.month}/${dateInfo.date}`);
        },
        selectedOk: false,
    }
    constructor(props) {
        super(props);
        this.calenderManager = new CalenderManager();
        // this.calenderData = this.calenderManager.calculateCalendarData(this.props.year, this.props.month);
        this.selectedOK = this.props.selectedOk;
    }
    componentWillReceiveProps(nextProps) {
        // if (nextProps.selectedOk !== this.props.selectedOk || nextProps.startDate !== this.props.startDate || nextProps.endDate !== this.props.endDate || nextProps.allSelect !== this.props.allSelect) {
        //     runInAction(() => {
        //         this.calenderData = this.calenderManager.calculateCalendarData(nextProps.year, nextProps.month);
        //         this.selectedOK = this.props.selectedOk;
        //     });
        // }
        runInAction(() => {
            this.calenderData = this.calenderManager.calculateCalendarData(nextProps.year, nextProps.month);
            this.selectedOK = this.props.selectedOk;
        });
    }

    shouldComponentUpdate(nextProps, nextState) {
        return (nextProps.selectedOk !== this.props.selectedOk || nextProps.startDate !== this.props.startDate || nextProps.endDate !== this.props.endDate || nextProps.allSelect !== this.props.allSelect);
    }
    calenderManager = null;
    @observable calenderData = null;
    @observable selectedOK = false;
    pressDateRowItem = (dateValue: number) => {

        if (this.props.onRowItemPress) {
            const dateInfo = {
                year: this.props.year,
                month: this.props.month,
                date: dateValue,
            };
            /**
             * 传回选择数据
             */
            this.props.onRowItemPress(dateInfo);
        }
    }

    renderTitle = () => {
        const year = this.calenderData ? this.calenderData.year : this.props.year;
        const month = this.calenderData ? this.calenderData.month : this.props.month;
        const title = `${year}-${month}`;
        return (
            <View style={CalenderItemStyle.itemTitleView}>
                <Text>{title}</Text>
            </View>
        );
    }
    /**
     * 计算每一个月份怎么显示
     * @param obj: 每一个月份的信息
     * @param index 当前周的星期数
     * @returns {*}
     */
    renderRowText = (obj, index) => {
        // 计算边界的宽度布局
        let frontierStyle = {};
        if (index === 0) {
            frontierStyle = {
                borderTopLeftRadius: _itemRadius,
                borderBottomLeftRadius: _itemRadius,
                width: tempWidth,
                alignItems: 'flex-start',
            };
        } else if (index === 6) {
            frontierStyle = {
                borderBottomRightRadius: _itemRadius,
                borderTopRightRadius: _itemRadius,
                width: tempWidth,
                alignItems: 'flex-end',
            };
        }
        // 如果不是当月的日子，直接返回空视图。
        if (obj.notCurrentMonth) {
            return (
                <View
                    key={`other_date@${this.props.month}-${obj.dateValue}`}
                    style={[CalenderItemStyle.weekDayBackGroundView, frontierStyle]}
                />
            );
        }
        let needFrontierBackView = false;
        let EAndSStyle = {};
        let _style = {};
        let _backgroundStyle = {};
        if (this.props.startDate === obj.dateValue || this.props.endDate === obj.dateValue) {
            _style = selectedStyle;
        }
        const isStartExist = this.props.startDate !== -1;
        const isEndExist = this.props.endDate !== -1;
        const isGreaterThanStart = (isStartExist && this.props.startDate < obj.dateValue);
        const isLessThanEnd = (isEndExist && this.props.endDate > obj.dateValue);
        if (this.props.allSelect) {
            _backgroundStyle = inSelectedStyle;
        } else if (!isEndExist && isGreaterThanStart) {
            _backgroundStyle = inSelectedStyle;
        } else if (!isStartExist && isLessThanEnd) {
            _backgroundStyle = inSelectedStyle;
        } else if (isGreaterThanStart && isLessThanEnd) {
            _backgroundStyle = inSelectedStyle;
        }
        if (obj.dateValue === this.props.startDate) {
            EAndSStyle = {
                right: 0,
            };
            needFrontierBackView = true;
        } else if (obj.dateValue === this.props.endDate) {
            EAndSStyle = {
                left: 0,
            };
            needFrontierBackView = true;
        }
        return (
            <TouchableOpacity
                key={`date@${this.props.month}-${obj.dateValue}`}
                style={[CalenderItemStyle.weekDayBackGroundView, this.selectedOK ? _backgroundStyle : null, frontierStyle]}
                onPress={() => { this.pressDateRowItem(obj.dateValue); }}
                activeOpacity={0.80}
            >
                {needFrontierBackView && this.selectedOK ? <View style={[CalenderItemStyle.SAndEBackView, EAndSStyle]} /> : null}
                <View style={[CalenderItemStyle.weekDayView, _style]}>
                    <Text style={CalenderItemStyle.weekDayText}>{obj.notCurrentMonth ? '' : obj.dateValue}</Text>
                </View>
            </TouchableOpacity>
        );
    }
    renderRow = (weekData: Array) => {
        if (typeof weekData === 'undefined' || weekData.length === 0) {
            return <View />;
        }
        const listCom = [];
        weekData.forEach((obj, index) => {
            listCom.push(this.renderRowText(obj, index));
        });
        const _width = D.ScreenW - (2 * _MarginHor);
        const path = new Path().moveTo(15, 0).lineTo(_width - 15, 0);
        return (
            <View style={CalenderItemStyle.weekItemView}>
                <Surface width={_width} height={1} style={{ position: 'absolute', top:0, left: 0 }}>
                    <Shape d={path} strokeWidth={1.5} stroke={'#f0f0f0'} />
                </Surface>
                {listCom}
            </View>
        );
    };
    renderCalendarContent = () => {
        if (!this.calenderData) { return <View/> }
        const firstWeek = this.renderRow(this.calenderData.firstWeek);
        const secondWeek = this.renderRow(this.calenderData.secondWeek);
        const thirdWeek = this.renderRow(this.calenderData.thirdWeek);
        const forthWeek = this.renderRow(this.calenderData.forthWeek);
        const fifthWeek = this.renderRow(this.calenderData.fifthWeek);
        const sixthWeek = this.renderRow(this.calenderData.sixthWeek);
        return (
            <View style={{ flex:1, backgroundColor: '#fff', alignItems: 'center' }}>
                {firstWeek}
                {secondWeek}
                {thirdWeek}
                {forthWeek}
                {fifthWeek}
                {sixthWeek}
            </View>
        );
    };
    render() {
        return (
            <View style={CalenderItemStyle.container}>
                {this.renderTitle()}
                {this.renderCalendarContent()}
            </View>
        );
    }
}

export default CalendarItemView;
