/**
 * Created by aby.wang on 2018/4/13.
 */
/**
 * Created by phoobobo on 2017/8/17.
 * Dragon Trail Interactive All Rights Reserved.
 */
import {
    StyleSheet,
    Dimensions,
    PixelRatio,
} from 'react-native';

// 尺寸相关的常量

/* 最小线宽 */
export const pixel = 1 / PixelRatio.get();

const ScreenW = Dimensions.get('window').width;
const ScreenH = Dimensions.get('window').height;
const STANDARD_WIDTH = 750;

// 根据屏幕宽度的标准，转换设计图的尺寸
// TODO: 决定是否更换基准
function W750(number) {
    if (number === 'minPix') {
        return pixel;
    } else {
        const value = parseInt((number / STANDARD_WIDTH) * ScreenW, 0);
        return value;
    }
}

const TEXT_TYPE = 'TEXT_MSG';
const VOICE_TYPE = 'VOICE_MSG';
const IMG_TYPE = 'IMG_MSG';

const SYSTEM_MSG_TYPE = 'SYS_TYPE';
const CHAT_MSG_TYPE = 'CHAT_TYPE';
const CUSTOM_MSG_TYPE = 'CUSTOM_TYPE';
const ARTICLE_MSG_TYPE = 'ARTICLE_MSG';

// 消息内容枚举
const MSG_ELEM = {
    // CHAT
    TEXT_ELEM: TEXT_TYPE,
    VOICE_ELEM: VOICE_TYPE,
    IMG_ELEM: IMG_TYPE,
    // SYSTEM
    SYS_CUSTOMER_JOIN: 'SYS_CUSTOMER_JOIN',
    SYS_SERVICE_START: 'SYS_SERVICE_START',
    SYS_EVALUATE_START: 'SYS_EVALUATE_START',
    SYS_CUSTOMER_EVALUATE: 'SYS_CUSTOMER_EVALUATE',
    SYS_SERVICE_END: 'SYS_SERVICE_END',
    SYS_SERVICE_SWITCH: 'SYS_SERVICE_SWITCH',
    SYS_CHAT_TIMEOUT: 'SYS_CHAT_TIMEOUT',
    SYS_SERVICE_TIMEOUT: 'SYS_SERVICE_TIMEOUT',
    SYS_SERVICE_WAIT_COUNT: 'SYS_SERVICE_WAIT_COUNT',
    SYS_ALERT_MESSAGE: "SYS_ALERT_MESSAGE", // 用户已经离开了会话
    // CUSTOM_TYPE
    BOT_ELEM: 'BOT_REPLY_ELEM',
    PRODUCT_REPLY_ELEM: 'PRODUCT_PATTERN_REPLY_ELEM',
    EVALUATE_ELEM: 'H5_CUSTOMER_EVALUATE_ELEM',
    // ARTICLE
    ARTICLE_ELEM: 'ARTICLE_ELEM',
    // PRODUCT
    PRODUCT_VOYAGE_ELEM: 'PRODUCT_VOYAGE_ELEM',
    PRODUCT_CABIN_ELEM: 'PRODUCT_CABIN_ELEM',
    PRODUCT_ORDER_ELEM: 'PRODUCT_ORDER_ELEM',

};

// 消息类型枚举
const MSG = {
    SYSTEM: SYSTEM_MSG_TYPE,
    CHAT_MSG: CHAT_MSG_TYPE,
    CUSTOM_MSG: CUSTOM_MSG_TYPE,
    ARTICLE_MSG: ARTICLE_MSG_TYPE,
};

export default {
    pixel,
    W750,
    ScreenH,
    ScreenW,
};

export {
    W750,
    MSG,
    MSG_ELEM,
}
