/**
 * Created by aby.wang on 2018/4/13.
 */


import { observable } from 'mobx';
import { persist } from 'mobx-persist';

class CalendarDataStore {
    @persist('list') @observable calendarDataArr = [];
}

export default new CalendarDataStore();