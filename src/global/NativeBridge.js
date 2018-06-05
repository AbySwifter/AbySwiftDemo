/**
 * Created by aby.wang on 2018/5/28.
 */

import {
    NativeModules,
} from 'react-native';

const bridge = NativeModules.BaseBridge;

class NativeBridge {
    pop = () => {
       if (bridge&&bridge.nativePop) {
           bridge.nativePop()
       }
    }

    passJSON = (value, type) => {
        if (bridge&&bridge.passJSON) {
            bridge.passJSON(value, type);
        }
    }
}

export default new NativeBridge(); // 导出单例