/* eslint-disable react/prop-types */
/**
 * Created by phoobobo on 2017/8/16.
 * Dragon Trail Interactive All Rights Reserved.
 */
import React, { Component } from 'react';
import {
    View,
    Text,
    StyleSheet,
    TouchableOpacity,
} from 'react-native';
import Constants from '../global/Constants';
import { observer, inject } from 'mobx-react/native';
import { Error } from '../utils';

const BaseStyle = StyleSheet.create({
    noNetContainer: {
        flex: 0,
        height: 30,
        width: Constants.Dimensions.ScreenW,
        backgroundColor: '#ff1e1e',
        justifyContent: 'center',
        alignItems: 'center',
    },
});

@observer
export default class BasePage extends Component {
    constructor(props) {
        super(props);
        this.props = props;

        this.state = {
            needReconnectManually: false,
        };
    }

    /**
     * 显示对话框
     * @param title 标题
     * @param _content 内容
     * @param onSureCallBack 点确定按钮的回调
     * @param justConfirm 是否只需要确定按钮
     */
    showLightBox = (title, _content, onSureCallBack, justConfirm:? boolean) => {
        this.props.navigator.showLightBox({
            screen: Constants.Screens.LIGHT_BOX.screen,
            passProps: {
                title: title || '提示',
                content: _content,
                onClose: this.dismissLightBox,
                justConfirm,
                onSure: () => { this.onLightBoxSure(onSureCallBack); },
            },
            style: {
                backgroundBlur: 'none',
                backgroundColor: 'rgba(0, 0, 0, 0.3)',
                navigationBarColor: Constants.Colors.themeColor,
                tapBackgroundToDismiss: false,
            },
        });
    };

    // dismissLightBox = () => {
    //     // this.props.navigator.dismissLightBox();
    //     Navigation.dismissLightBox();
    // };

    // onLightBoxSure = (callback) => {
    //     this.dismissLightBox();
    //     if (typeof callback === 'function') {
    //         callback();
    //     }
    // };

    // showInAppNotification = (head: string = '', content: string) => {
    //     this.props.navigator.showInAppNotification({
    //         screen: Constants.Screens.NOTIFICATION.screen,
    //         passProps: {
    //             head,
    //             content,
    //         },
    //         position: 'top',  // or bottom // Can I set exactly from where it appears in pixels for example from underneath the navbar
    //         autoDismissTimerSec: 2, // That works
    //         dismissWithSwipe: true,
    //     });
    // };

    showError = (err: Error) => {
        this.showInAppNotification('提示', err.message);
    }

   renderNetNotice = (netWorkState) => {
        if (netWorkState === 0) {
            return (
                <View style={BaseStyle.noNetContainer}>
                    <Text style={{ color: '#fff' }}>没有网连接，请检查网络。</Text>
                </View>
            );
        } else {
            return (
                <View />
            );
        }
   }
   renderSocketConnectionState = (connected) => {
        if (!connected) {
            setTimeout(() => {
                this.setState({
                    needReconnectManually: true,
                });
            }, 10000);
            return (
                <TouchableOpacity
                    style={[BaseStyle.noNetContainer, { backgroundColor: '#f08080' }]}
                    disabled={!this.state.needReconnectManually}
                >
                    <Text style={{ color: '#fff' }}>与服务器连接断开，正在重连...</Text>
                </TouchableOpacity>
            );
        } else {
            return (
                <View />
            );
        }
   }
}
