/**
 * Created by phoobobo on 2017/11/30.
 * Dragon Trail Interactive All Rights Reserved.
 */
import React, { Component } from 'react';
import { View, ART, TouchableOpacity, StyleSheet } from 'react-native';
import PropTypes from 'prop-types';
import { observable, action } from 'mobx';
import { observer } from 'mobx-react/native';

const { Surface, Shape, Path, Group } = ART;
const IncreaseBtnStyle = StyleSheet.create({
    touchableRange: {
        width: 32,
        height: 24,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: 'transparent',
    },
    container: {
        backgroundColor: '#c9c9c9',
        width: 16,
        height: 16,
        justifyContent: 'center',
        alignItems: 'center',
        borderRadius: 2,
    },
});

@observer
export default class IncreaseBtn extends Component {
    static propTypes = {
        isIncrease: PropTypes.bool,
        onPress: PropTypes.func,
        disabled: PropTypes.bool,
    };
    static defaultProps = {
        isIncrease: true,
        onPress: () => {},
        disabled: false,
    };
    constructor(props) {
        super(props);
        this.disabled = props.disabled;
    }
    @action
    componentWillReceiveProps(newProps) {
        this.disabled = newProps.disabled;
    }
    @observable disabled = false;
    renderART = () => {
        const plusPath = new Path().moveTo(4, 0).lineTo(4, 8).moveTo(0, 4).lineTo(8, 4);
        const minusPath = new Path().moveTo(0, 4).lineTo(8, 4);
        return (
            <Surface width={8} height={8}>
                <Group>
                    <Shape d={this.props.isIncrease ? plusPath : minusPath} stroke={'white'} strokeWidth={2} />
                </Group>
            </Surface>
        );
    };
    render() {
        return (
            <TouchableOpacity
                {...this.props}
                style={IncreaseBtnStyle.touchableRange}
                onPress={this.props.onPress}
            >
                <View style={[IncreaseBtnStyle.container, this.disabled ? { backgroundColor: '#e6e6e6' } : {}]}>
                    {this.renderART()}
                </View>
            </TouchableOpacity>
        )
    }
}