#include "ActivityPost.h"

ActivityPost::ActivityPost(User *author, const QString &desc, int type,
                           const QString &value, const Date &date)
    : Post(author, desc, date), activityType(type), activityValue(value) {}

QString ActivityPost::displayPost() const {
  return QString("%1\nActivity: %2 %3")
      .arg(Post::displayPost())
      .arg(activityType)
      .arg(activityValue);
}