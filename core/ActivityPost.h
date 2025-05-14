#ifndef ACTIVITYPOST_H
#define ACTIVITYPOST_H

#include "Post.h"

class ActivityPost : public Post {
private:
    int activityType; // 0=Feeling, 1=Watching, etc.
    QString activityValue;

public:
    ActivityPost(User* author, const QString& desc, int type, const QString& value, const Date& date);
    QString displayPost() const override;
};

#endif // ACTIVITYPOST_H