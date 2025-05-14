#ifndef PAGE_H
#define PAGE_H
#include "Post.h"
#include "User.h"
#include <QObject>
#include <QString>
class User;
class Post;
class Page : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString pageID READ getPageID CONSTANT)
  Q_PROPERTY(QString title READ getTitle CONSTANT)
  Q_PROPERTY(int likesCount READ getLikesCount CONSTANT)
  Q_PROPERTY(int postCount READ getPostCount CONSTANT)
private:
  QString pageID;
  QString title;
  User *owner;
  Post **posts;
  int postCount;
  int postsCapacity;
  int likesCount;
  static int totalPages;
  void resizePostsArray();

public:
  Q_INVOKABLE QVariantMap debugInfo() const {
    QVariantMap info;
    info["id"] = getPageID();
    info["title"] = getTitle();
    info["likes"] = getLikesCount();
    info["posts"] = getPostCount();
    // Proper way to handle owner
    if (User *owner = getOwner()) {
      info["owner"] = owner->getUsername(); // Or other identifier
      // Alternative: info["owner"] = QVariant::fromValue(owner);
    } else {
      info["owner"] = "null";
    }
    return info;
  }
  Q_INVOKABLE void setLikesCount(int count) { likesCount = count; }
  Q_INVOKABLE Page(const QString &title, User *owner);
  ~Page();
  void setOwner(User *owner) { this->owner = owner; }
  Q_INVOKABLE void setPageID(const QString &id);
  Q_INVOKABLE QString getPageID() const;
  Q_INVOKABLE QString getTitle() const;
  Q_INVOKABLE User *getOwner() const;
  Q_INVOKABLE Post **getPosts(int *count) const;
  Q_INVOKABLE int getPostCount() const;
  Q_INVOKABLE int getLikesCount() const;
  Q_INVOKABLE void addPost(Post *post);
  Q_INVOKABLE void addLike(User *user);
  Q_INVOKABLE void setPosts(Post **newPosts, int count);
};
#endif // PAGE_H
