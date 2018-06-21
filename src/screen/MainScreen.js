/**
 * Created by aby.wang on 2018/5/24.
 */
import React, {Component} from 'react';
import PropTypes from 'prop-types';
import {
    View,
    StyleSheet,
    Text,
} from 'react-native';
import { observer } from 'mobx-react/native';
import { observable, action, runInAction, toJS } from 'mobx';

const MainScreenStyle = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
});

class MainScreen extends Component<{}> {
    render() {
        return (
            <View style={MainScreenStyle.container}>
                <Text>测试页面</Text>
            </View>
        );
    }
}

export default MainScreen;