#ifndef POST_H
#define POST_H
#include "Comment.h"
#include "Date.h"
#include "User.h"
#include <QDate>
#include <QObject>
class User;
class Comment;
class Post : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString id READ getId CONSTANT)
  Q_PROPERTY(QString description READ getDescription CONSTANT)
  Q_PROPERTY(int likesCount READ getLikesCount NOTIFY likesChanged)
  Q_PROPERTY(int commentsCount READ getCommentsCount NOTIFY commentsChanged)
  Q_PROPERTY(QString imagePath READ getImagePath CONSTANT)
  Q_PROPERTY(QString date READ getDateString CONSTANT)
  Q_PROPERTY(QString authorUsername READ getAuthorUsername CONSTANT)
  Q_PROPERTY(QString authorId READ getAuthorId CONSTANT)
protected:
  QString postID;
  QString description;
  Date sharedDate;
  QDate sharedQDate;
  QString ImagePath;
  User **likedBy;
  Comment **comments;
  int likedByCount;
  int commentsCount;
  int capacity;

public:
  User *author;
  Q_INVOKABLE Post(User *author, const QString &desc, const Date &date);
  Q_INVOKABLE Post(User *author, const QString &desc, const QDate &date);
  Q_INVOKABLE QString getId() const {
    return postID;
  } // Add this member variable to Post class
  virtual ~Post();
  Q_INVOKABLE bool isValid() const {
    return !postID.isEmpty() && !description.isEmpty();
  }
  QString getDateString() const { return sharedQDate.toString(Qt::ISODate); }
  QString getAuthorUsername() const {
    return author ? author->getUsername() : "";
  }
  QString getAuthorId() const { return author ? author->getUserID() : ""; }
  Q_INVOKABLE void addLike(User *user);
  Q_INVOKABLE QString getImagePath() const;
  Q_INVOKABLE QString getDescription() const;
  Q_INVOKABLE int getLikesCount() const;
  Q_INVOKABLE int getCommentsCount() const;
  Q_INVOKABLE QDate getDate() const;
  void setId(QString id) {
    this->postID = id;
    //
  }
  void setCommentsCount(int count) {
    this->commentsCount = count;
    //
  }
  Q_INVOKABLE void setImagePath(const QString &Path);
  Q_INVOKABLE void setLikesCount(int count);
  // Comment* addComment(User* user, const QString& content);
  virtual QString displayPost() const;
signals:
  void likesChanged();
  void commentsChanged();
};
#endif // POST_H