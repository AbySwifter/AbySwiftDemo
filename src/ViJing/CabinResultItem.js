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
import { W750 } from '../global/Constants/Dimensions';
import { SelectedHookBtn } from '../component';

const paddingH = W750(40);

const CabinResultItemStyle = StyleSheet.create({
    filterResultItemStyle: {
        flex: 0,
        minHeight: W750(40),
        backgroundColor: '#ffff',
        paddingHorizontal: paddingH,
        justifyContent: 'flex-start',
        marginTop: W750(20),
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
class CabinResultItem extends Component {
    static propTypes = {
        selected: PropTypes.bool,
        pressItemAction: PropTypes.func,
        item: PropTypes.any.isRequired,
    }
    static defaultProps = {
        selected: false,
        pressItemAction: null,
    }
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
    }
    render() {
        const item = this.props.item;
        return (
            <TouchableOpacity
                style={[CabinResultItemStyle.filterResultItemStyle, { width: this.props.width }]}
                onPress={() => {
                    this.pressItem(item);
                }}
            >
                <View style={CabinResultItemStyle.filterResultItemSubTitle}>
                    <View style={CabinResultItemStyle.filterResultItemTitle}>
                        <SelectedHookBtn height={W750(32)} width={W750(32)} selected={this.isSelected} disabled={true} />
                        <Text style={{ fontSize: 16, marginLeft: W750(16) }}>
                            {`${item.name}`}
                        </Text>
                    </View>
                    <Text style={CabinResultItemStyle.filterResultItemSubText}>
                        {`${item.price}`}
                    </Text>
                </View>
            </TouchableOpacity>
        );
    }
}

export default CabinResultItem;
