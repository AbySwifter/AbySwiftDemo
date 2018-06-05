/**
 * Created by aby.wang on 2017/11/29.
 */

import React, { Component } from 'react';
import propTypes from 'prop-types';
import { ART, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { observer } from 'mobx-react/native';
import { action, observable, runInAction } from 'mobx';

const selectColor = '#c8c8c8';
const normalColor = '#ffffff';

const { Surface, Shape, Path, Group } = ART;

const SelectedHookStyle = StyleSheet.create({
    container: {
        flex: 0,
        justifyContent: 'center',
        alignItems: 'center',
        flexDirection: 'row',
        minWidth: 8,
    },
    rightIcon: {
        flex: 1,
        borderWidth: 1,
        borderColor: '#c8c8c8',
        borderRadius: 2,
        justifyContent: 'center',
        alignItems: 'center',
    },
});

@observer
class SelectedHookBtn extends Component {
    static propTypes = {
        onPressAction: propTypes.func,
        style: propTypes.any,
        selected: propTypes.bool,
        height: propTypes.number,
        width: propTypes.number,
    }
    static defaultProps = {
        onPressAction: () => {},
        style: {
            width: 18,
            height: 18,
        },
        width: 16,
        height: 16,
        selected: false,
    }
    constructor(props){
        super(props);
        this.selected = props.selected;
    }

    componentWillReceiveProps(nextProps, nextContent) {
        if (nextProps.selected !== this.selected) {
            runInAction(() => {
               this.selected = nextProps.selected;
            });
        }
    }
    @observable selected = false;
    @action onPressBtn = () => {
        this.selected = !this.selected;
        if (this.props.onPressAction) {
            this.props.onPressAction(this.selected);
        }
    }
    renderART = () => {
        const x = this.props.height - 2;
        const padding = x / 4;
        const path_selected = new Path()
            .moveTo(padding - (padding / 2), x / 2)
            .lineTo((x / 2) - (padding / 2), x - padding)
            .lineTo(x - (padding / 2), padding);
        const path_normal = new Path();
        const path = this.selected ? path_selected : path_normal;
        return (
            <Surface
                width={this.props.height - 2}
                height={this.props.height - 2}
            >
                <Group>
                    <Shape d={path} stroke={selectColor} strokeWidth={1} />
                </Group>
            </Surface>
        );
    }
    render() {
        return (
            <TouchableOpacity
                style={[SelectedHookStyle.container, { height: this.props.height, width: this.props.width }]}
                onPress={this.onPressBtn}
                disabled={this.props.disabled}
            >
                <View style={SelectedHookStyle.rightIcon}>
                    {this.renderART()}
                </View>
            </TouchableOpacity>
        );
    }
}

export default SelectedHookBtn;
