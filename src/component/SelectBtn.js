/**
 * Created by aby.wang on 2017/11/28.
 */
/**
 * Created by aby.wang on 2017/11/27.
 */
import React, {Component} from 'react';
import propTypes from 'prop-types';
import { ART, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { observer } from 'mobx-react/native';
import { action, observable, runInAction } from 'mobx';

const selectColor = '#2dade6';
const normalColor = '#ffffff';

const { Surface, Shape, Path, Group } = ART;

const SelectStyle = StyleSheet.create({
    container: {
        flex: 0,
        justifyContent: 'flex-start',
        alignItems: 'center',
        flexDirection: 'row',
        minWidth: 51,
    },
    rightIcon: {
        marginLeft: 5,
    },
});

@observer
class SelectBtn extends Component {
    static propTypes = {
        onPressAction: propTypes.func,
        style: propTypes.any,
        selected: propTypes.bool,
    }
    static defaultProps = {
        onPressAction: () => {},
        style: {
            width: 90,
            height: 50,
        },
        selected: false,
    }
    constructor(props){
        super(props);
        this.selected = props.selected;
    }

    componentWillReceiveProps(nextProps) {
        runInAction(() => {
            this.selected = nextProps.selected;
        });
    }
    @observable selected = false;
    @action onPressBtn = () => {
        this.selected = !this.selected;
        if (this.props.onPressAction) {
            this.props.onPressAction(this.selected);
        }
    }
    renderART = () => {
        const path = new Path()
            .moveTo(8, 1)
            .arc(0, 14, 4)
            .arc(0, -14, 4)
            .close();
        const path_center = new Path()
            .moveTo(8, 5)
            .arc(0, 6, 1)
            .arc(0, -6, 1)
            .close();
        const _color = this.selected ? selectColor : normalColor;
        return (
            <Surface
                style={SelectStyle.rightIcon}
                width={16}
                height={16}
            >
                <Group>
                    <Shape d={path} stroke={selectColor} strokeWidth={1} />
                    <Shape d={path_center} stroke={_color} fill={_color} strokeWidth={1} />
                </Group>
            </Surface>
        );
    }
    render() {
        return (
            <TouchableOpacity
                style={[SelectStyle.container, this.props.style]}
                onPress={this.onPressBtn}
            >
                {this.props.children && typeof this.props.children === 'string' ? <Text style={[{ fontSize: 14, color: selectColor }]}>{this.props.children}</Text> : null}
                {this.renderART()}
            </TouchableOpacity>
        );
    }
}

export default SelectBtn;
