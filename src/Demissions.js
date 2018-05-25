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

export default {
    pixel,
    W,
    ScreenH,
    ScreenW,
};

export { W750 }
