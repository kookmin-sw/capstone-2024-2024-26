import React, { useState } from 'react';
import DatePicker from 'react-datepicker';
import { ko } from 'date-fns/locale';
import 'react-datepicker/dist/react-datepicker.css';
import '../styles/reserve.css';

const DatePick = ({ onChange }) => {
    const [selectedStartDate, setSelectedStartDate] = useState(null);
    const [selectedEndDate, setSelectedEndDate] = useState(null);

    const handleDateChange = (dates) => {
        if (dates && dates.length === 2) {
            const [start, end] = dates;
            const formattedStartDate = start ? start.toISOString().split('T')[0] : null;
            const formattedEndDate = end ? end.toISOString().split('T')[0] : null;
            setSelectedStartDate(start);
            setSelectedEndDate(end);
            onChange([formattedStartDate, formattedEndDate]);
        }
    };

    return (
        <div> 
            <DatePicker
                selectsRange={true}
                className="datepicker"
                locale={ko}
                dateFormat="yyyy년 MM월 dd일"
                selected={selectedStartDate}
                startDate={selectedStartDate}
                endDate={selectedEndDate}
                onChange={handleDateChange}
            />
        </div>
    );
};

export default DatePick;