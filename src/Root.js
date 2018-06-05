/**
 * Created by aby.wang on 2018/4/13.
 */

import React, {Component} from 'react';
import {
    StyleSheet,
    Image,
    Text,
    View,
    NativeModules,
} from 'react-native';
import { createStackNavigator } from 'react-navigation';
import CardStackStyleInterpolator from 'react-navigation/src/views/StackView/StackViewStyleInterpolator'; // 动画的导入

import MainScreen from './screen/MainScreen';
import { Product, ProductInformation } from './ViJing';

// 这里在mobx的Provide中提供RootStore
import { Provider } from 'mobx-react';

const routes = {
    Main: {
        screen: Product,
        navigationOptions: {
            title: '产品',
            header: null,
            headerTitleStyle: {fontSize: 18, color: '#fff'},
            headerStyle: {backgroundColor: '#0084bf'},
            headerTintColor: '#ffffff',
        },
    },
    ProductInformation: {
        screen: ProductInformation,
    }
};

function getRouteConfig(name) {
    const BaseBridge = NativeModules.BaseBridge;
    return {
        initialRouteName: name,
        navigationOptions: {
            // 开启动画
            animationEnabled: true,
            // 开启边缘触摸返回
            gesturesEnabled: true,
            navigationOptions: {
                title: '选择产品',
                headerTitleStyle: {fontSize: 18, color: 'green'},
                headerStyle: {backgroundColor: '#0fb'},
                headerTintColor: '#0fb',
            }
        },
        mode: 'card',
        headerMode: 'float',
        transitionConfig:() => ({
            screenInterpolator: CardStackStyleInterpolator.forHorizontal,
        }),
        onTransitionEnd: (info) => {
            console.log('end',info.index);
            if (info.index === 0) {
                BaseBridge.changeTab(false);
            } else {
                BaseBridge.changeTab(true);
            }
        },
        onTransitionStart: (info) => {
            console.log('end',info.index);
            if (info.index === 0) {
                BaseBridge.changeTab(false);
            } else {
                BaseBridge.changeTab(true);
            }
        }
    }
}


class APP extends Component {
    initRoute = (params) => {
        if (params.routeName === 'Main') {
            return createStackNavigator(routes, getRouteConfig('ProductInformation'));
        } else {
            return createStackNavigator(routes, getRouteConfig('Main'));
        }
    }

    render() {
        const NavigatorAPP = this.initRoute(this.props);
        return (
            <Provider>
                <NavigatorAPP />
            </Provider>
        );
    }
}

export default APP;
