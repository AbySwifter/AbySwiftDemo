/**
 * Created by aby.wang on 2018/4/13.
 */
type DateDay = {
    dateValue: number,
    weekDay : number,
    isToday : boolean,
    notCurrentMonth: boolean,
}

/**
 * 定义日历结构接口
 */
type Calendar = {
    year: number,
    month: number,
    totalWeeks: number,
    firstWeek: [],
    secondWeek: [],
    thirdWeek: [],
    forthWeek: [],
    fifthWeek: [], // 只有在二月份28天且二月1号在周日的情况下，没有第五周
    sixthWeek: [], // 极少数情况会有第六周
}

class CalendarManager {
    static weeks = ['日','一','二','三','四','五','六'];// 静态的日历角标
    year: number; // 年
    month: number; // 月
    date: number; // 日（当前日期）
    timeSp: Date; // 当前日期对象
    weekDay: number; // 当前的星期数
    // readonly currentMonthData: Calendar; // 当前月份的数据，暂时没有用到
    constructor(){
        this.timeSp = new Date();
        this.year = this.timeSp.getFullYear();
        this.month = this.timeSp.getMonth() + 1;
        this.date = this.timeSp.getDate();
        this.weekDay = this.timeSp.getDay();
        // this.currentMonthData = this.calculateCalendarData();
    }
    // 需要一个根据当前月份计算日期的方法
    // 日历表为7*5矩阵，即为一个二维数组，每次调整当前类的数据时，自动计算当月的日历（有7*4和7*6的情况）
    calculateCalendarData = (year, month) => {
        if (!year) {
            year = this.year;
        }
        if (!month) {
            month = this.month - 1;
        } else {
            month = month - 1;
        }
        const tempDate = new Date(year, month, 0); // 首先找出上个月的最后一天
        const day = tempDate.getDay();// 上个月最后一天的week数
        const lastMonthLastDayDate = tempDate.getDate();
        const isFeb = month == 1;// 判断是否是二月
        const isFirstDaySat = day == 6;
// 初始化接口类型的数据，默认weeks数为5
        let result: Calendar = {
            year: year,
            month: month + 1,
            totalWeeks: 5,
            firstWeek: [],
            secondWeek: [],
            thirdWeek: [],
            forthWeek: []
        };
// 开始填充数据
        for (let weeksNum = 0; weeksNum < 6; weeksNum += 1) {
            let endDate = new Date(year, month + 1, 0).getDate();
            // 第一周的情况
            if (weeksNum == 0) {
                let startDate = 1;
                if (day !== 6) {
                    // 填充第一周的空白天数
                    for (let spaceDays = 0; spaceDays <= day; spaceDays += 1) {
                        const last_date = lastMonthLastDayDate - (day - spaceDays); // 计算日期
                        const dayData: DateDay = {dateValue: last_date, weekDay: day - spaceDays, notCurrentMonth: true}
                        result.firstWeek.push(dayData);
                    }
                }
                // 填充第一周的剩余天数
                for (let startDay = result.firstWeek.length; startDay < 7; startDay += 1) {
                    const dayData: DateDay = {dateValue: startDate, weekDay: startDay, notCurrentMonth: false}
                    if (this.date == startDate && this.month == month && this.year == year) {
                        dayData.isToday = true;
                    }
                    result.firstWeek.push(dayData);
                    startDate += 1;
                }
            }
            // 二到四的情况
            if (weeksNum !== 0 && weeksNum !== 4) {
                let everyDate = result.firstWeek[6].dateValue + 1;
                if (weeksNum == 2) {
                    everyDate = result.secondWeek[6].dateValue + 1;
                }
                if (weeksNum == 3) {
                    everyDate = result.thirdWeek[6].dateValue + 1;

                }
                for (let startDay = 0; startDay < 7; startDay += 1) {
                    const dayData: DateDay = {dateValue: everyDate, weekDay: startDay, notCurrentMonth: false};
                    if (this.date == everyDate && this.month == month && this.year == year) {
                        dayData.isToday = true;
                    }
                    switch (weeksNum) {
                        case 1:
                            result.secondWeek.push(dayData);
                            break;
                        case 2:
                            result.thirdWeek.push(dayData);
                            break;
                        case 3:
                            result.forthWeek.push(dayData);
                    }
                    everyDate += 1;
                }
                result.totalWeeks = 4;
            }
            // 第五周的情况
            if (weeksNum === 4 && !(isFeb && isFirstDaySat && endDate === 28)) {
                let everyDate = result.forthWeek[6].dateValue + 1;
                let lastDayNum = endDate - result.forthWeek[6].dateValue;
                result.fifthWeek = [];
                if (lastDayNum <= 7) {
                    for (let startDay = 0; startDay < lastDayNum; startDay += 1) {
                        const dayData: DateDay = {dateValue: everyDate, weekDay: startDay, notCurrentMonth: false};
                        if (this.date == everyDate && this.month == month && this.year == year) {
                            dayData.isToday = true;
                        }
                        result.fifthWeek.push(dayData);
                        everyDate += 1;
                    }
                    for (let nextDay = 0; nextDay < 7 - lastDayNum; nextDay += 1) {
                        const dayData: DateDay = {
                            dateValue: nextDay + 1,
                            weekDay: lastDayNum + nextDay + 1,
                            notCurrentMonth: true
                        };
                        result.fifthWeek.push(dayData);
                    }
                    result.totalWeeks = 5;
                    break; // 打断循环即可
                } else {
                    for (let startDay = 0; startDay < 7; startDay += 1) {
                        const dayData: DateDay = {dateValue: everyDate, weekDay: startDay, notCurrentMonth: false};
                        if (this.date == everyDate && this.month == month && this.year == year) {
                            dayData.isToday = true;
                        }
                        result.fifthWeek.push(dayData);
                        everyDate += 1;
                    }
                }
            }
            if (weeksNum === 5 && result.fifthWeek) {
                let everyDate = result.fifthWeek[6].dateValue + 1;
                let lastDayNum = endDate - result.fifthWeek[6].dateValue;
                result.sixthWeek = [];
                for (let startDay = 0; startDay < lastDayNum; startDay += 1) {
                    const dayData: DateDay = {dateValue: everyDate, weekDay: startDay, notCurrentMonth: false};
                    if (this.date == everyDate && this.month == month && this.year == year) {
                        dayData.isToday = true;
                    }
                    result.sixthWeek.push(dayData);
                    everyDate += 1;
                }
                for (let nextDay = 0; nextDay < 7 - lastDayNum; nextDay += 1) {
                    const dayData: DateDay = {
                        dateValue: nextDay + 1,
                        weekDay: lastDayNum + nextDay + 1,
                        notCurrentMonth: true
                    };
                    result.sixthWeek.push(dayData);
                }
                result.totalWeeks = 6;
            }
        }
        return result;
    }
}

export default CalendarManager;
