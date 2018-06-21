/**
 * Created by aby.wang on 2018/5/25.
 */
import React, {Component} from 'react';
import PropTypes from 'prop-types';
import {
    View,
    StyleSheet,
    Text,
    Platform,
    FlatList,
    Image,
    TouchableOpacity,
} from 'react-native';
import { observer } from 'mobx-react/native';
import { observable, action, runInAction, toJS } from 'mobx';
import Constants from '../global/Constants';
import D, { W750 } from '../global/Constants/Dimensions';
import { VoyageFilterRow, CabinFilterRow, OrderFilterRow } from './'

// 菜单的宽度常量
const menuWidth = D.ScreenW;

// 菜单的高度常量
const menuHeight = D.ScreenH - W750(180) - (Platform.OS === 'ios'? 0 : 20);

const ProductFilterStyle = StyleSheet.create({
    container: {
        flex: 0,
        width: D.ScreenW,
        height: D.ScreenH,
        backgroundColor: '#0000',
        // backgroundColor: '#fff',
        flexDirection: 'row',
        justifyContent: 'flex-start',
    },
    navImage: {
        position: 'absolute',
        width: W750(24),
        height: W750(42),
        left: 12,
        top: 37,
    },
    mainViewStyle: {
        flex: 1,
        width: menuWidth,
        height: D.ScreenH,
        backgroundColor: '#fff',
        position: 'absolute',
        top: 0,
        right: 0,
    },
    titleControllerView: {
        flex: 0,
        width: menuWidth,
        height: W750(180),
        backgroundColor: '#0084bf',
        justifyContent: 'center',
        alignItems: 'center',
    },
    selectTitle: {
        flex: 0,
        width: W750(150 * 3),
        height: W750(65),
        borderRadius: 4,
        justifyContent: 'flex-start',
        flexDirection: 'row',
        overflow: 'hidden',
    },
    selectBtnStyle: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#fff',
    },
    flatListStyle: {
        flex: 0,
        width: menuWidth,
        height: menuHeight,
    },
});

@observer
class ProductFilter extends Component<> {
    // MARK: - 静态属性
    static navigatorStyle = {

    }

    static propTypes = {
        sendAction: PropTypes.func,
    }

    static defaultProps = {
        sendAction: () => {},
    }

    // MARK: - 属性
    flatList = null;
    @observable selectedPage = 0; // 选中的页面

    sendAction = (msg) => {
        const { navigation } = this.props;
        const sendAction = navigation.getParam('sendAction', () => {});
        sendAction(msg);
        navigation.pop();
    }

    keyExtractor = (item, index) => {
        return `index@${index}`;
    };
    getItemLayout = (data, index) => {
        return {
            length: menuWidth,
            offset: menuWidth * index,
            index: index,
        };
    };
    scrollEnd = (event) => {
        const { contentOffset } = event.nativeEvent;
        const index = Math.floor(parseInt(contentOffset.x, 10) / parseInt(menuWidth, 10));
        if (index !== this.selectedPage) {
            runInAction(() => {
                this.selectedPage = index;
            });
        }
    };
    renderRow = (row) => {
        const color = ['#fff', '#0ff', '#ff0'];
        if (row.index === 0) {
            return (
                <VoyageFilterRow
                    width={menuWidth}
                    height={menuHeight}
                    sendAction={(msg) => {
                        this.sendAction(msg);
                    }}
                />
            );
        } else if (row.index === 1) {
            return (
                <CabinFilterRow
                    width={menuWidth}
                    height={menuHeight}
                    sendAction={(msg) => {
                        this.sendAction(msg);
                    }}
                />
            );
        } else if (row.index === 2) {
            return (
                <OrderFilterRow
                    width={menuWidth}
                    height={menuHeight}
                    sendAction={(msg) => {
                        this.sendAction(msg);
                    }}
                />
            );
        }
    };

    @action pressTitle = (index) => {
        this.selectedPage = index;
        if (this.flatList) {
            this.flatList.scrollToIndex({
                index: index,
                viewPosition: 0,
                animated: true,
            });
        }
    };
    renderControllerView = () => {
        const titleArr = ['航线', '舱位', '订单'];
        const list = titleArr.map((value, index, arr) => {
            const style = index === this.selectedPage ? { backgroundColor: '#92c360' } : { backgroundColor: '#fff' };
            const titleColor = index === this.selectedPage ? '#fff' : '#000';
            const leftStyle = { borderTopLeftRadius: 4, borderBottomLeftRadius: 4 };
            const rightStyle = { borderTopRightRadius: 4, borderBottomRightRadius: 4 };
            const radiusStyle = index === 1 ? {} : index === 0 ? leftStyle : rightStyle;
            return (
                <TouchableOpacity
                    key={`selectTab@${index}`}
                    style={[ProductFilterStyle.selectBtnStyle, style, radiusStyle]}
                    onPress={() => {
                        this.pressTitle(index);
                    }}
                >
                    <Text style={{ color: titleColor }}>{value}</Text>
                </TouchableOpacity>
            );
        });
        return (
            <View
                style={ProductFilterStyle.titleControllerView}
            >
                <TouchableOpacity
                    style={ProductFilterStyle.navImage}
                    onPress={() => {
                        this.props.navigation.pop();
                    }}
                >
                    <Image source={Constants.Images.NAV_BTN_LEFT_WHITE} resizeMode={'contain'} style={{ flex: 1 }} />
                </TouchableOpacity>
                <View style={ProductFilterStyle.selectTitle}>
                    {list}
                </View>
            </View>
        );
    };
    renderFlatList = () => {
        return (
            <FlatList
                ref={(f) => { this.flatList = f; }}
                style={ProductFilterStyle.flatListStyle}
                data={[1, 2, 3]}
                horizontal={true}
                renderItem={this.renderRow}
                pagingEnabled={true}
                keyExtractor={this.keyExtractor}
                getItemLayout={this.getItemLayout}
                bounces={false}
                showsHorizontalScrollIndicator={false}
                onMomentumScrollEnd={this.scrollEnd}
                keyboardShouldPersistTaps={'never'}

            />
        );
    };
    render() {
        return (
            <View style={ProductFilterStyle.container}>
                <View style={ProductFilterStyle.mainViewStyle}>
                    {this.renderControllerView()}
                    {this.renderFlatList()}
                </View>
            </View>
        );
    }
}

export default ProductFilter;