#pragma once
#include "Page.h"
#include "PageLoader.h"
#include "User.h"
#include <QDate>
#include <QDebug>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QList>
#include <QMutex>
#include <QObject>
#include <QStandardPaths>
#include <QString>

class Syntax : public QObject {
  Q_OBJECT
  User *currentUser;
  User **users;
  Page **m_likedPages;
  int m_likedPagesCount;
  int m_likedPagesCapacity;
  int m_usersCount;
  int m_usersCapacity;
  mutable QMutex m_mutex;

public:
  explicit Syntax(QObject *parent = nullptr);
  ~Syntax();

  // Memory management helpers
  void safeDeleteUsers();
  void safeDeleteLikedPages();

  Q_INVOKABLE void saveLikedPagesToFile();
  Q_INVOKABLE User *createUser(const QString &username,
                               const QString &password);
  Q_INVOKABLE User *createUserSignUp(const QString &username,
                                     const QString &password);
  Q_INVOKABLE User *createUserSignUpFile(const QString &username,
                                         const QString &password);
  Q_INVOKABLE bool userExists(const QString &username);
  Q_INVOKABLE User **getAllUsers(int *count) const;
  Q_INVOKABLE void createPost(const QString &description,
                              const QString &imagePath,
                              const QDate &sharedDate = QDate::currentDate()) {
    this->currentUser->createPost(description, imagePath, sharedDate);
  }
  Q_INVOKABLE void iterateJsonPosts() {
    if (!currentUser) {
      qWarning() << "No current user set.";
      return;
    }

    int friendCount = 0;
    User **friends = currentUser->getFriends(&friendCount);

    if (!friends || friendCount == 0) {
      qDebug() << "No friends found for user:" << currentUser->getUsername();
      return;
    }

    for (int i = 0; i < friendCount; ++i) {
      User *friendUser = friends[i];
      if (friendUser) {
        bool loaded = loadPostsFromJson(friendUser);
        if (loaded) {
          qDebug() << "Loaded posts for friend:" << friendUser->getUsername();
        } else {
          qWarning() << "Failed to load posts for friend:"
                     << friendUser->getUsername();
        }
      }
    }
  }

  Q_INVOKABLE bool loadPostsFromJson(User *user) {
    qDebug() << " Function loadPostsFromJson Called for "
             << user->getUsername();
    QFile file("assets/data/AllPosts.json");
    if (!file.open(QIODevice::ReadOnly)) {
      qWarning() << "Couldn't open posts file.";
      return false;
    }

    QByteArray jsonData = file.readAll();
    file.close();

    QJsonDocument doc = QJsonDocument::fromJson(jsonData);
    if (doc.isNull()) {
      qWarning() << "Failed to parse JSON";
      return false;
    }

    QJsonArray postsArray = doc.array();
    for (const QJsonValue &postValue : postsArray) {
      QJsonObject postObj = postValue.toObject();

      // Only load posts for the current user
      if (postObj["username"].toString() !=
          user->getUsername()) { // Skip other users' posts
        continue;
      }

      QString postId = postObj["id"].toString();
      if (postExists(postId, user)) {
        qDebug() << " Post " << postId << " Already Loaded - Skipping";
        continue;
      }

      QString description = postObj["description"].toString();
      QString imagePath = postObj["image"].toString();
      QString dateStr = postObj["date"].toString();
      int likes = postObj["likes"].toInt();
      int comments = postObj["comments"].toInt();
      QDate postDate = QDate::fromString(dateStr, "yyyy-MM-dd");
      Post *newPost = user->createPost(description, imagePath, postDate);
      if (newPost) {
        newPost->setId(postId);
        newPost->setLikesCount(likes);
        newPost->setCommentsCount(comments);
        qCritical() << "Post " << newPost->getId() << "added ";
      }
    }
    savePostsToFile();
    emit postsLoaded();
    return true;
  }
  Q_INVOKABLE bool savePostsToFile() {
    QFile file("assets/data/AllPosts.json");
    QJsonArray allPostsArray;

    // Step 1: Load existing posts
    if (file.exists() && file.open(QIODevice::ReadOnly)) {
      QByteArray jsonData = file.readAll();
      file.close();

      QJsonDocument existingDoc = QJsonDocument::fromJson(jsonData);
      if (!existingDoc.isNull() && existingDoc.isArray()) {
        allPostsArray = existingDoc.array();
      }
    }

    // Step 2: Filter out old posts by current user OR posts with same postID
    QString currentUsername = currentUser->getUsername();
    QSet<QString> currentUserPostIDs;
    for (int i = 0; i < currentUser->getPostCount(); ++i) {
      currentUserPostIDs.insert(currentUser->getPosts()[i]->getId());
    }

    QJsonArray filteredPostsArray;
    for (const QJsonValue &val : allPostsArray) {
      QJsonObject obj = val.toObject();
      QString username = obj["username"].toString();
      QString postId = obj["id"].toString();

      // Keep only posts from other users AND not duplicate post IDs
      if (username != currentUsername && !currentUserPostIDs.contains(postId)) {
        filteredPostsArray.append(obj);
      }
    }

    // Step 3: Append current user's updated posts
    for (int i = 0; i < currentUser->getPostCount(); ++i) {
      Post *post = currentUser->getPosts()[i];
      QJsonObject postObj;
      postObj["username"] = post->author->getUsername();
      postObj["id"] = post->getId();
      postObj["image"] = post->getImagePath();
      postObj["description"] = post->getDescription();
      postObj["likes"] = post->getLikesCount();
      postObj["comments"] = post->getCommentsCount();
      postObj["date"] = post->getDate().toString("yyyy-MM-dd");
      filteredPostsArray.append(postObj);
    }

    // Step 4: Save final array
    QJsonDocument finalDoc(filteredPostsArray);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
      qWarning() << "Couldn't open file for writing";
      return false;
    }

    file.write(finalDoc.toJson());
    file.close();
    return true;
  }

  Q_INVOKABLE QVariantList getPosts() {
    QVariantList result;
    if (!currentUser)
      return result;

    int count = 0;
    Post **posts = currentUser->getPosts(&count);

    for (int i = 0; i < count; i++) {
      if (posts[i]) {
        result.append(QVariant::fromValue(posts[i]));
        qDebug() << "[POST]" << posts[i]->getId() << "Retrieved For"
                 << currentUser->getUsername();
      }
    }
    return result;
  }
  Q_INVOKABLE int getPLC(QString PostID) {
    if (!currentUser)
      return 0;

    int count = 0;
    Post **posts = currentUser->getPosts(&count);

    for (int i = 0; i < count; i++) {
      if (posts[i] && posts[i]->getId() == PostID) {
        return posts[i]->getLikesCount();
      }
    }
    return 0; // Return 0 instead of -1 for consistency
  }
  Q_INVOKABLE void saveFriendsDataToFile();
  Q_INVOKABLE QVariantList
  loadFriendsData(); // find friends from file and add them for current User
  Q_INVOKABLE bool isFriend(const QString &username);
  Q_INVOKABLE bool addFriend(const QString &username);
  Q_INVOKABLE QVariantList getFriendsPosts() {
    QMutexLocker locker(&m_mutex); // Add thread safety
    QVariantList result;

    int friendCount = 0;
    User **friends = currentUser->getFriends(&friendCount);

    for (int i = 0; i < friendCount; ++i) {
      if (!friends[i])
        continue;

      int postCount = 0;
      loadPostsFromJson(friends[i]);
      Post **posts = friends[i]->getPosts(&postCount);
      QVariantList friendPosts;

      for (int j = 0; j < postCount; ++j) {
        if (posts[j]) {
          friendPosts.append(QVariant::fromValue(posts[j]));
        }
      }

      delete[] posts; // Clean up the temporary array
      result.append(friendPosts);
    }

    return result;
  }
  Q_INVOKABLE void loadAllFriendsPosts() {
    // Thread safety
    QMutexLocker locker(&m_mutex);

    if (!currentUser) {
      qWarning() << "Cannot load posts - no current user set!";
      return;
    }

    qDebug() << "=== STARTING POST LOAD FOR ALL FRIENDS ===";
    qDebug() << "Current user:" << currentUser->getUsername();

    // Get friends array (with proper memory management)
    int friendCount = 0;
    User **friends = currentUser->getFriends(&friendCount);
    QScopeGuard friendsCleanup([&]() { delete[] friends; });

    qDebug() << "Found" << friendCount << "friends to process";

    for (int i = 0; i < friendCount; ++i) {
      if (!friends[i]) {
        qDebug() << "Skipping null friend at index" << i;
        continue;
      }

      qDebug() << "\nProcessing friend" << i + 1 << "of" << friendCount << ":"
               << friends[i]->getUsername();

      // Load posts with error handling
      try {
        bool loadSuccess = loadPostsFromJson(friends[i]);
        if (!loadSuccess) {
          qWarning() << "Failed to load posts for friend"
                     << friends[i]->getUsername();
          continue;
        }

        // Get and log posts
        int postCount = 0;
        Post **posts = friends[i]->getPosts(&postCount);
        QScopeGuard postsCleanup([&]() { delete[] posts; });

        qDebug() << "Loaded" << postCount << "posts:";
        for (int j = 0; j < postCount; ++j) {
          if (!posts[j]) {
            qDebug() << "  [" << j << "] NULL POST";
            continue;
          }

          qDebug().nospace()
              << "  [" << j << "] "
              << "ID: " << posts[j]->getId() << " | "
              << "Author: "
              << (posts[j]->author ? posts[j]->author->getUsername() : "NULL")
              << " | "
              << "Date: " << posts[j]->getDate().toString("yyyy-MM-dd") << " | "
              << "Likes: " << posts[j]->getLikesCount() << " | "
              << "Comments: " << posts[j]->getCommentsCount() << " | "
              << "Image: "
              << (posts[j]->getImagePath().isEmpty() ? "None" : "Exists")
              << " | "
              << "Desc: "
              << (posts[j]->getDescription().left(30) +
                  (posts[j]->getDescription().length() > 30 ? "..." : ""));
        }
      } catch (const std::exception &e) {
        qCritical() << "Exception loading posts for friend"
                    << friends[i]->getUsername() << ":" << e.what();
      }
    }

    qDebug() << "=== COMPLETED POST LOADING ===";
    emit postsLoaded(); // Notify QML when done
  }
  Q_INVOKABLE bool removeFriend(const QString &username);
  Q_INVOKABLE User *getCurrentUser() {
    // QMutexLocker locker(&m_mutex); // Add thread safety
    return currentUser; // Simple return, no conditional
  }
  Q_INVOKABLE User *findUserByUsername(QString username) {
    // QMutexLocker locker(&m_mutex);

    if (!username.isEmpty() && users) {
      for (int i = 0; i < m_usersCount; i++) {
        if (users[i] && users[i]->getUsername() == username) {
          return users[i];
        }
      }
    }

    qWarning() << "User not found:" << username;
    return nullptr; // Always return something
  }
  // User info
  Q_INVOKABLE QVariantList getUsersList() const {
    QVariantList result;
    if (!currentUser) {
      qDebug() << "Current User not Found";
      return result;
    }
    for (int i = 0; i < this->m_usersCount; i++) {
      if (this->users[i] && this->users[i] != this->currentUser)
        result.append(QVariant::fromValue(this->users[i]));
    }
    qDebug() << "Returning " << result.size() << " Users ";
    return result;
  }

  Q_INVOKABLE int getPostCount() const;
  Q_INVOKABLE int getUserCount() const;
  Q_INVOKABLE int getLikedPagesCount() const;
  Q_INVOKABLE QString getUsername() const;
  Q_INVOKABLE int getFriendCount() const;

  // Like functionality
  Q_INVOKABLE void likePage(const QString &pageId);
  Q_INVOKABLE void loadLikedPages();
  Q_INVOKABLE bool hasLikedPage(const QString &pageId) const;
  Q_INVOKABLE QVariantList getLikedPages() const {
    QVariantList result;
    if (!currentUser) {
      qWarning() << "No current user!";
      return result;
    }

    for (int i = 0; i < m_likedPagesCount; i++) {
      if (m_likedPages[i]) {
        result.append(QVariant::fromValue(m_likedPages[i]));
      }
    }
    qDebug() << "Returning" << result.size() << "liked pages for"
             << currentUser->getUsername();
    return result;
  }
  Q_INVOKABLE QString getLikedPagesFilePath() const;
  void addUser(User *user);
  bool postExists(const QString &postId, User *user) const {
    for (auto i = 0; i < user->getPostCount(); i++) {
      if (user->getPosts()[i]->getId() == postId)
        return true;
    }
    return false;
  }
signals:
  void FriendsDataChanged();
  void likedPagesChanged();
  void likedPagesLoaded();
  void postsLoaded();
  void pageLiked(const QString &pageId, bool isLiked);

private:
  void resizeFriendsArray() {
    int newCapacity = m_usersCapacity * 2;
    User **newArray = new User *[newCapacity]();

    for (int i = 0; i < m_usersCount; ++i) {
      newArray[i] = users[i];
    }

    delete[] users;
    users = newArray;
    m_usersCapacity = newCapacity;

    qDebug() << "Resized friends array to new capacity:" << m_usersCapacity;
  }
  void resizeUsersArray();
  void resizeLikedPagesArray();
  int findPageIndex(const QString &pageId) const;
};