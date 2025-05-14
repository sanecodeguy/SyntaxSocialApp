#include "Date.h"

Date::Date(int d, int m, int y) : day(d), month(m), year(y) {}

QString Date::toString() const {
    return QString("%1/%2/%3").arg(day).arg(month).arg(year);
}

bool Date::operator==(const Date& other) const {
    return day == other.day && month == other.month && year == other.year;
}