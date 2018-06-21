/**
 * Created by aby.wang on 2017/11/27.
 */
import React, { Component }from 'react';
import propTypes from 'prop-types';
import {
    StyleSheet,
    View,
    TouchableOpacity,
    Text,
    ART,
} from 'react-native';
import { observer } from 'mobx-react/native';
import { observable, action } from 'mobx';
import { W750 } from '../global/Constants/Dimensions';

const selectColor = '#2dade6';
const normalColor = '#ffffff';

const { Surface, Shape, Path } = ART;

const FilterStyle = StyleSheet.create({
    container: {
        flex: 0,
        borderRadius: 3,
        borderColor: selectColor,
        borderWidth: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
    rightIcon: {
        position: 'absolute',
        top: W750(8),
        right: W750(8),
    },
});

@observer
class FilterBtn extends Component {
    static propTypes = {
        onPressAction: propTypes.func,
        style: propTypes.any,
    }
    static defaultProps = {
        onPressAction: () => {},
        style: {
            width: 65,
            height: 30,
        },
    }
    @observable selected = false;
    @action onPressBtn = () => {
        this.selected = !this.selected;
        if (this.props.onPressAction) {
            this.props.onPressAction(this.selected);
        }
    }
    renderClose = () => {
        if (this.selected) {
            const path = new Path().moveTo(0, 0).lineTo(8, 8).moveTo(0, 8).lineTo(8, 0);
            return (
                <Surface
                    style={FilterStyle.rightIcon}
                    width={8}
                    height={8}
                >
                    <Shape d={path} stroke={'#fff'} strokeWidth={1} />
                </Surface>
            );
        } else {
            return (<View />);
        }
    }
    render() {
        const color = this.selected ? selectColor : normalColor;
        const textStyle = this.selected ? { color: '#fff' } : { color: '#000' };
        return (
            <TouchableOpacity
                style={[FilterStyle.container, this.props.style, { backgroundColor: color }]}
                onPress={this.onPressBtn}
            >
                {this.renderClose()}
                {this.props.children && typeof this.props.children === 'string' ? <Text style={[{ fontSize: 14 }, textStyle]}>{this.props.children}</Text> : null}
            </TouchableOpacity>
        );
    }
}

export default FilterBtn;
