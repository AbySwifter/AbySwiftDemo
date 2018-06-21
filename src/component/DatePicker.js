/**
 * Created by phoobobo on 2017/11/28.
 * Dragon Trail Interactive All Rights Reserved.
 */
import React from 'react';
import PropTypes from 'prop-types';
import DateTimePicker from 'react-native-modal-datetime-picker';
import { observer } from 'mobx-react/native';


 class DatePicker extends React.Component {

    static propTypes = {
        handleDatePicked: PropTypes.func.isRequired,
        show: PropTypes.bool.isRequired,
        dateID: PropTypes.string,
        date: PropTypes.any,       // Initial selected date/time
        minDate: PropTypes.any,
        maxDate: PropTypes.any,
    };
    static defaultProps = {
        dateID: '',
        date: new Date(),
        minDate: new Date(new Date().getFullYear(), 0, 0, 0, 0, 0),
        maxDate: new Date(new Date().getFullYear() + 10, 11, 0, 0, 0, 0),
    };
    constructor(props) {
        super(props);
        this.state = {
            isDateTimePickerVisible: props.show,
        };
        this.handleDatePicked = props.handleDatePicked;
    }
    componentWillReceiveProps(nextProps, nextContext) {
        if (nextProps.show !== this.props.show) {
            this.setState({ isDateTimePickerVisible : nextProps.show });
        }
    }
    handleDatePicked = null;
    _handleDatePicked = (date) => {
        if (this.handleDatePicked) {
            this.handleDatePicked(date, this.props.dateID);
        }
        this._hideDateTimePicker();
    }

    _hideDateTimePicker = () => {
        this.setState({ isDateTimePickerVisible: false });
    }
    _cancel = () => {
        if (this.handleDatePicked) {
            this.handleDatePicked(undefined, this.props.dateID);
        }
        this._hideDateTimePicker();
    }
    render() {
        return (
            <DateTimePicker
                isVisible={this.state.isDateTimePickerVisible}
                onConfirm={this._handleDatePicked}
                onCancel={this._cancel}
                date={this.props.date}
                minimumDate={this.props.minDate}
                maximumDate={this.props.maxDate}
            />
        );
    }
}

export default DatePicker;