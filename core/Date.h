#ifndef DATE_H
#define DATE_H

#include <QString>

class Date {
private:
    int day;
    int month;
    int year;

public:
    Date(int d = 1, int m = 1, int y = 2000);
    QString toString() const;
    bool operator==(const Date& other) const;
};

#endif // DATE_H