/**
 * Created by aby.wang on 2017/11/29.
 */
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {
    View,
    Text,
    TouchableOpacity,
    StyleSheet,
} from 'react-native';
import { observer } from 'mobx-react/native';
import { observable, action, runInAction } from 'mobx';
import Constants from '../global/Constants/index';
import { W750 } from '../global/Constants/Dimensions';
import { SelectedHookBtn } from '../component';

const paddingH = W750(40);

const ResultItemStyle = StyleSheet.create({
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
        alignItems: 'center',
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

@observer
class ResultItem extends Component {
    static propTypes = {
        selected: PropTypes.bool,
        pressItemAction: PropTypes.func,
        item: PropTypes.any.isRequired,
        feeColor: PropTypes.string,
        margin: PropTypes.number,
    };
    static defaultProps = {
        selected: false,
        pressItemAction: null,
        feeColor: '#999999',
        margin: 0,
    };
    @observable isSelected = false;
    constructor(props) {
        super(props);
        this.isSelected = this.props.selected;
    }

    componentWillReceiveProps(nextProps, nextContent) {
        runInAction(() => {
            this.isSelected = nextProps.selected;
        });
    }
    @action pressItem = (item) => {
        this.isSelected = !this.isSelected;
        if (this.props.pressItemAction) {
            this.props.pressItemAction(item, this.isSelected);
        }
    };
    @action pressBtn = (selected) => {
        this.isSelected = selected;
        if (this.props.pressItemAction) {
            this.props.pressItemAction(this.props.item, this.isSelected);
        }
    };
    render() {
        const item = this.props.item;
        let containStyle = {};
        const tmpMargin = this.props.margin;
        if (tmpMargin === 0) {
            containStyle = ResultItemStyle.filterResultItemStyle;
        } else {
            containStyle = [ResultItemStyle.filterResultItemStyle, { marginTop: tmpMargin, marginBottom: tmpMargin / 2 }];
        }
        return (
            <TouchableOpacity
                style={containStyle}
                onPress={() => {
                    this.pressItem(item);
                }}
            >
                <View style={ResultItemStyle.filterResultItemTitle}>
                    <SelectedHookBtn height={W750(32)} width={W750(32)} selected={this.isSelected} onPressAction={this.pressBtn} disabled={true} />
                    <Text style={{ fontSize: 16, marginLeft: W750(16) }}>
                        {`${item.name}`}
                    </Text>
                </View>
                <View style={ResultItemStyle.filterResultItemSubTitle}>
                    <Text style={[ResultItemStyle.filterResultItemSubText, { marginLeft: W750(32) }]}>
                        {`${item.description}`}
                    </Text>
                    <Text style={[ResultItemStyle.filterResultItemSubText, { color: this.props.feeColor }]}>
                        {`${item.price}`}
                    </Text>
                </View>
            </TouchableOpacity>
        );
    }
}

export default ResultItem;
