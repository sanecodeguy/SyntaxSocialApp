#pragma once
#include <QDate>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMutex>
#include <QObject>
#include <QString>
class Post;
class Page;
class Comment;

class User : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString username READ getUsername CONSTANT)
  Q_PROPERTY(QString userID READ getUserID CONSTANT)
  Q_PROPERTY(int friendCount READ getFriendCount NOTIFY friendsChanged)
private:
  QString userID;
  QString username;
  QString name;
  User **friends;
  Page **likedPages;
  Post **posts;
  static const QString ID_FILE_PATH;
  static const QString PASS_FILE_PATH;
  int friendCount;
  int likedPagesCount;
  int postCount;
  int friendsCapacity;
  int likedPagesCapacity;
  int postsCapacity;
  static int totalUsers;
  void resizeFriendsArray();
  void resizeLikedPagesArray();
  void resizePostsArray();
  QMutex m_friendsMutex, m_mutex;

public:
  QJsonObject toJson() const;

  static User *fromJson(const QJsonObject &json, QObject *parent = nullptr);
  Q_INVOKABLE bool addFriend(User *newFriend, bool mutual = true);
  Q_INVOKABLE bool removeFriend(User *friendToRemove, bool mutual = true);
  Q_INVOKABLE bool isFriend(User *user) const;
  Q_INVOKABLE void setPosts(Post **newPosts, int count);
  Q_INVOKABLE QVariantList getFriendsList() const;
  User **getFriends(int *count = nullptr) const;
  Page **getLikedPages(int *count = nullptr) const;
  Post **getPosts(int *count = nullptr) const;
  QString getSafeUsername() const {
    // QMutexLocker locker(&m_mutex);
    return username;
  }
  User(const QString &username, const QString &name);
  ~User();

  static bool authenticateUser(const QString &username,
                               const QString &password);
  static bool userExists(const QString &username);
  Q_INVOKABLE QString getUserID() const { return this->userID; }
  QString getUsername() const;
  QString getName() const;
  User *getFriend(int index) const;
  int getFriendCount() const;
  int getLikedPagesCount() const;
  int getPostCount() const;
  void likePage(Page *page);
  void likePage(QString PageID);

  Q_INVOKABLE Post *createPost(const QString &description,
                               const QString &imagePath,
                               const QDate &sharedDate = QDate::currentDate());
  void likePost(Post *post);
  Comment *commentOnPost(Post *post, const QString &content);
  Post *shareMemory(Post *originalPost, const QString &newDescription);
  bool likesPage(Page *page) const;
signals:

  void friendsChanged();
};
