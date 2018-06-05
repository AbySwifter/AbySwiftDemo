/**
 * Created by aby.wang on 2018/5/25.
 */

/**
 * Created by Chris. on 2018/3/30.
 * 推荐产品
 */

import React from 'react';
import PropTypes from 'prop-types';
import {
    StyleSheet,
    View,
    Text,
    TouchableOpacity,
    FlatList,
    Image
} from 'react-native';
import { observer } from 'mobx-react/native';
import { observable, action, runInAction, toJS, computed } from 'mobx';
import Constants from '../global/Constants';
import Dms, { W750, MSG_ELEM } from '../global/Constants/Dimensions';
// import { BasePage } from '../../library';
// import NavBar from '../../global/NavBar';
import ResultItem from './ResultItem';
import Bridge from '../global/NativeBridge'

const paddingH = W750(40);
const moreProductonWay = 'moreProductionWay';

const ProductInfoStyle = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'flex-start',
        backgroundColor: '#fff',
    },
    filterResultView: {
        flex: 1,
        backgroundColor: '#fff',
    },
    buttonContainer: {
        height: W750(314 + 20),
        paddingHorizontal: paddingH,
        paddingTop: W750(20),
        alignItems: 'center',
        backgroundColor: '#fff',
    },
    sendBtn: {
        width: Dms.ScreenW - (2 * paddingH),
        height: W750(88),
        backgroundColor: '#0084bf',
        alignItems: 'center',
        justifyContent: 'center',
    },
    moreBtn: {
        marginTop: W750(60),
        width: W750(150),
        alignItems: 'center',
    },
});

class ProductInformationModel {
    resultArrSelectedStatusArr = new Set();

    @action selectedResultArr = (item, selected) => {
        if (selected) {
            this.resultArrSelectedStatusArr.add({ id: item.id, type: item.type });
        } else {
            this.resultArrSelectedStatusArr.delete({ id: item.id, type: item.type });
        }
    };

    @action getMessage = () => {
        if (this.resultArrSelectedStatusArr.size === 0) {
            return undefined;
        }
        return {
            elemType: MSG_ELEM.PRODUCT_REPLY_ELEM,
            content: {
                id: [...this.resultArrSelectedStatusArr],
            },
        };
    };
}

@observer
export default class ProductInformation extends React.Component<> {

    static navigationOptions = ({navigation}) => {
        const params = navigation.state.params || {};
        return {
            title: '产品推荐',
            headerLeft: (
                <TouchableOpacity
                    style={{ flex: 0, height: 32, width: 32, justifyContent: 'center', alignItems: 'center' }}
                    onPress={params.back}
                >
                    <Image source={Constants.Images.CHAT_NAV_LEFT} />
                </TouchableOpacity>
            ),
        }
    }

    static propTypes = {
        info: PropTypes.any,
        sendAction: PropTypes.func,
    };
    static defaultProps = {
        info: [],
        sendAction: () => {},
    };
    constructor(props) {
        super(props);
        const { navigation } = props;
        this.model = new ProductInformationModel();
        navigation.setParams({
            back: this.back,
        })
    }

    back = () => {
        Bridge.pop();
    }

    model = null;

    keyExtractor = (item, index) => `productRst@${index}`;

    @action checkSelectedStatus = (itemId) => {
        return this.model.resultArrSelectedStatusArr.has(itemId);
    };

    renderResultFlatListItem = ({ item, index }) => {
        return (
            <ResultItem
                item={toJS(item)}
                feeColor={'red'}
                margin={20}
                pressItemAction={(_item, selected) => {
                    this.model.selectedResultArr(toJS(item), selected, index);
                }}
                selected={this.checkSelectedStatus(item.id)}
            />
        );
    };
    renderSeparator = () => {
        return (
            <View
                style={{
                    backgroundColor: '#efefef',
                    width: Dms.ScreenW,
                    height: 1,
                    alignSelf: 'center',
                }}
            />
        );
    };
    renderFilterResultList = () => {
        if (this.props.info.length === 0) {
            // 无推荐产品信息
            return (
                <View style={{ flex: 1, alignItems: 'center' }}>
                    <Text style={{ fontSize: 20, marginTop: W750(80), color: '#333333' }}>暂无可推荐的产品信息</Text>
                </View>
            );
        } else {
            // 有推荐产品信息
            return (
                <FlatList
                    style={ProductInfoStyle.filterResultView}
                    data={this.props.info}
                    renderItem={this.renderResultFlatListItem}
                    ItemSeparatorComponent={this.renderSeparator}
                    keyExtractor={this.keyExtractor}
                    // showsVerticalScrollIndicator={false}
                />
            );
        }
    };

    sendAction = (passMsg, way) => {
        if (way === moreProductonWay && passMsg !== undefined) {
            // 从"更多产品"跳转回该页面の发送
            const str = JSON.stringify(passMsg)
            Bridge.passJSON(str, 'MSG_ELEM');
        } else {
            // 在该页面选择的推荐产品の发送
            const msg = this.model.getMessage();
            if (msg === undefined) return;
            const str = JSON.stringify(msg)
            Bridge.passJSON(str, 'MSG_ELEM');
        }
        this.back();
    };
    moreProductAction = () => {
        this.props.navigation.navigate('Main',{
            sendAction: (msg) => {
                this.sendAction(msg, moreProductonWay);
            }
        });
    };
    renderButtons = () => {
        return (
            <View style={ProductInfoStyle.buttonContainer}>
                <TouchableOpacity style={ProductInfoStyle.sendBtn} onPress={this.sendAction}>
                    <Text style={{ color: '#fff', fontSize: 18 }}>发 送</Text>
                </TouchableOpacity>
                <TouchableOpacity style={ProductInfoStyle.moreBtn} onPress={this.moreProductAction}>
                    <Text style={{ color: '#0084bf', fontSize: 18 }}>更多产品</Text>
                    <View style={{ backgroundColor: '#0084bf', width: W750(150), height: 1 }} />
                </TouchableOpacity>
            </View>
        );
    };

    render() {
        return (
            <View style={ProductInfoStyle.container}>
                {this.renderFilterResultList()}
                {this.renderButtons()}
            </View>
        );
    }
}
