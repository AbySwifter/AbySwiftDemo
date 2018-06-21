// /**
//  * Created by phoobobo on 2017/8/16.
//  * Dragon Trail Interactive All Rights Reserved.
//  */
// import { Platform } from 'react-native';
// import { Navigation } from 'react-native-navigation';
// // import { Navigation } from '../../library/react-native-navigation';
// import Constants from '../Constants';
// import TabBar from '../TabBar';
//
// // const Navigation
// const startTabBasedApp = () => {
//     const commonAppStyle = {
//         orientation: 'portrait',
//         ...Constants.Colors.navBarColors,
//     };
//     Navigation.startTabBasedApp({
//         tabs: [
//             {
//                 ...Constants.Screens.CONVERSATION_LIST_TAB,
//             },
//             {
//                 ...Constants.Screens.FORMS_TAB,
//             },
//             {
//                 ...Constants.Screens.MINE_TAB,
//             },
//         ],
//
//         ...Platform.select({
//             ios: {
//                 tabsStyle: {
//                     ...TabBar.Main,
//                     ...Constants.Colors.tabBarColors,
//                 },
//                 animationType: 'slide-down',
//                 appStyle: { ...commonAppStyle },
//             },
//             android: {
//                 appStyle: {
//                     ...TabBar.Main,
//                     ...Constants.Colors.tabBarColors,
//                     bottomTabTitleTextSize: 10,
//                     ...commonAppStyle,
//                     drawUnderNavBar: false,
//                     drawUnderTabBar: false,
//                 },
//                 animationType: 'fade',
//             },
//         }),
//     });
// };
//
// const openLoginModalIn = (navigator: { showModal: Function }, withCancelButton: boolean = false) => {
//     navigator.showModal({
//         ...Constants.Screens.LOGIN_SCREEN,
//         passProps: { withCancelButton },
//         overrideBackPress: true, // [Android] if you want to prevent closing a modal by pressing back button in Android
//     });
// };
//
// export default {
//     startTabBasedApp,
//     openLoginModalIn,
// };
