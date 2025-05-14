#include "Comment.h"
#include "Page.h"
#include "Post.h"
#include "User.h"
#include <QDebug>
#include <QFile>
#include <QJsonObject>
#include <QStandardPaths>
// #include<TextStream>
int User::totalUsers = 0;
const QString User::ID_FILE_PATH = "assets/data/id.txt";
const QString User::PASS_FILE_PATH = "assets/data/pass.txt";
const int INITIAL_CAPACITY = 10;
// User.cpp
#include "User.h"
#include <QJsonArray>
#include <QQmlEngine>
QJsonObject User::toJson() const {
  QJsonObject json;
  json["id"] = userID;
  json["username"] = username;
  json["name"] = name;
  // Serialize friends
  QJsonArray friendsArray;
  {
    // QMutexLocker locker(&m_friendsMutex);
    for (int i = 0; i < friendCount; i++) {
      if (friends[i]) {
        friendsArray.append(friends[i]->getUserID());
      }
    }
  }
  json["friends"] = friendsArray;
  // Serialize liked pages
  QJsonArray pagesArray;
  {
    // QMutexLocker locker(&m_pagesMutex);
    for (int i = 0; i < likedPagesCount; i++) {
      if (likedPages[i]) {
        pagesArray.append(likedPages[i]->getPageID());
      }
    }
  }
  json["likedPages"] = pagesArray;
  return json;
}
User *User::fromJson(const QJsonObject &json, QObject *parent) {
  if (json.isEmpty()) {
    return nullptr;
  }
  QString id = json["id"].toString();
  QString username = json["username"].toString();
  QString name = json["name"].toString();
  if (username.isEmpty()) {
    return nullptr;
  }
  User *user = new User(username, name);
  QQmlEngine::setObjectOwnership(user, QQmlEngine::CppOwnership);
  user->userID = id;
  // Friends and liked pages will be populated by Syntax class
  // when all users are loaded (to ensure proper references)
  return user;
}
bool User::addFriend(User *newFriend, bool mutual) {
  if (!newFriend || newFriend == this)
    return false;
  // QMutexLocker locker(&m_friendsMutex);
  // Check if already friends
  for (int i = 0; i < friendCount; ++i) {
    if (friends[i] == newFriend)
      return true;
  }
  // Resize if needed
  if (friendCount >= friendsCapacity) {
    resizeFriendsArray();
  }
  // Add the friend
  friends[friendCount++] = newFriend;
  // locker.unlock();
  // Reciprocal add if mutual
  if (mutual) {
    newFriend->addFriend(this, false);
  }
  emit friendsChanged();
  return true;
}
bool User::removeFriend(User *friendToRemove, bool mutual) {
  if (!friendToRemove)
    return false;
  // QMutexLocker locker(&m_friendsMutex);
  bool found = false;
  for (int i = 0; i < friendCount; ++i) {
    if (friends[i] == friendToRemove) {
      // Shift remaining elements
      for (int j = i; j < friendCount - 1; ++j) {
        friends[j] = friends[j + 1];
      }
      friendCount--;
      found = true;
      break;
    }
  }
  // locker.unlock();
  if (found) {
    // Reciprocal remove if mutual
    if (mutual) {
      friendToRemove->removeFriend(this, false);
    }
    emit friendsChanged();
    return true;
  }
  return false;
}
bool User::isFriend(User *user) const {
  if (!user)
    return false;
  // QMutexLocker locker(&m_friendsMutex);
  for (int i = 0; i < friendCount; ++i) {
    if (friends[i] == user) {
      return true;
    }
  }
  return false;
}
QVariantList User::getFriendsList() const {
  QVariantList list;
  // QMutexLocker locker(&m_friendsMutex);
  for (int i = 0; i < friendCount; i++) {
    if (friends[i]) {
      QQmlEngine::setObjectOwnership(friends[i], QQmlEngine::CppOwnership);
      list.append(QVariant::fromValue(friends[i]));
    }
  }
  return list;
}
User **User::getFriends(int *count) const {
  // QMutexLocker locker(&m_friendsMutex);
  if (count)
    *count = friendCount;
  // Create a copy of the array for thread safety
  User **friendsCopy = new User *[friendCount];
  for (int i = 0; i < friendCount; i++) {
    friendsCopy[i] = friends[i];
  }
  return friendsCopy;
}
Page **User::getLikedPages(int *count) const {
  // QMutexLocker locker(&m_pagesMutex);
  if (count)
    *count = likedPagesCount;
  Page **pagesCopy = new Page *[likedPagesCount];
  for (int i = 0; i < likedPagesCount; i++) {
    pagesCopy[i] = likedPages[i];
  }
  return pagesCopy;
}
Post **User::getPosts(int *count) const {
  // QMutexLocker locker(&m_postsMutex);
  if (count)
    *count = postCount;
  Post **postsCopy = new Post *[postCount];
  for (int i = 0; i < postCount; i++) {
    postsCopy[i] = posts[i];
  }
  return postsCopy;
}
bool User::authenticateUser(const QString &username, const QString &password) {
  QFile idFile(ID_FILE_PATH);
  QFile passFile(PASS_FILE_PATH);
  if (!idFile.open(QIODevice::ReadOnly) ||
      !passFile.open(QIODevice::ReadOnly)) {
    return false;
  }
  QTextStream idStream(&idFile);
  QTextStream passStream(&passFile);
  QString currentId;
  QString currentPass;
  while (!idStream.atEnd() && !passStream.atEnd()) {
    currentId = idStream.readLine().trimmed();
    currentPass = passStream.readLine().trimmed();
    if (currentId == username && currentPass == password) {
      idFile.close();
      passFile.close();
      return true;
    }
  }
  idFile.close();
  passFile.close();
  return false;
}
bool User::userExists(const QString &username) {
  QFile idFile(ID_FILE_PATH);
  if (!idFile.open(QIODevice::ReadOnly)) {
    return false;
  }
  //
  QTextStream idStream(&idFile);
  QString currentId;
  while (!idStream.atEnd()) {
    currentId = idStream.readLine().trimmed();
    if (currentId == username) {
      idFile.close();
      return true;
    }
  }
  idFile.close();
  return false;
}
User::User(const QString &username, const QString &name)
    : username(username), name(name), friendCount(0), likedPagesCount(0),
      postCount(0), friendsCapacity(INITIAL_CAPACITY),
      likedPagesCapacity(INITIAL_CAPACITY), postsCapacity(INITIAL_CAPACITY) {
  this->userID = username;
  this->friends = new User *[friendsCapacity]();
  this->likedPages = new Page *[likedPagesCapacity]();
  this->posts = new Post *[postsCapacity]();
}
User::~User() {
  for (int i = 0; i < postCount; ++i) {
    delete this->posts[i];
  }
  delete[] this->friends;
  delete[] this->likedPages;
  delete[] this->posts;
}
void User::resizeFriendsArray() {
  // QMutexLocker locker(&m_friendsMutex);
  int newCapacity = friendsCapacity * 2;
  User **newFriends = new User *[newCapacity]();
  for (int i = 0; i < friendCount; ++i) {
    newFriends[i] = friends[i];
  }
  delete[] friends;
  friends = newFriends;
  friendsCapacity = newCapacity;
}
void User::resizeLikedPagesArray() {
  likedPagesCapacity *= 2;
  Page **newLikedPages = new Page *[likedPagesCapacity]();
  for (int i = 0; i < likedPagesCount; ++i) {
    newLikedPages[i] = likedPages[i];
  }
  delete[] likedPages;
  likedPages = newLikedPages;
}
void User::resizePostsArray() {
  postsCapacity *= 2;
  Post **newPosts = new Post *[postsCapacity]();
  for (int i = 0; i < postCount; ++i) {
    newPosts[i] = posts[i];
  }
  delete[] posts;
  posts = newPosts;
}
User *User::getFriend(int index) const {
  if (index < 0 || index >= friendCount) {
    return nullptr;
  }
  if (!friends) {
    return nullptr;
  }
  return friends[index];
}
void User::likePage(QString PageID) { ; }
void User::likePage(Page *page) {
  if (!page || likesPage(page))
    return;
  if (likedPagesCount >= likedPagesCapacity) {
    resizeLikedPagesArray();
  }
  likedPages[likedPagesCount++] = page;
  // page->addLike(this);
}
Post *User::createPost(const QString &description, const QString &imagePath,
                       const QDate &sharedDate) {

  if (postCount >= postsCapacity) {
    resizePostsArray();
  }

  Post *newPost = new Post(this, description, sharedDate);
  newPost->setImagePath(imagePath);
  QString newId = "PT" + QUuid::createUuid().toString(QUuid::WithoutBraces);
  newPost->setId(newId);
  posts[postCount++] = newPost;
  qDebug() << "Creating Post " << newPost->getId() << " for " << this->username;
  return newPost;
}
void User::setPosts(Post **newPosts, int count) {
  // Clear existing posts
  for (int i = 0; i < postCount; ++i) {
    if (posts[i]) {
      delete posts[i];
    }
  }
  delete[] posts;
  posts = newPosts;
  postCount = count;
  postsCapacity = count > 5 ? count : 5;
}
int User::getPostCount() const { return postCount; }
bool User::likesPage(Page *page) const {
  for (int i = 0; i < likedPagesCount; ++i) {
    if (likedPages[i] == page)
      return true;
  }
  return false;
}
int User::getFriendCount() const { return friendCount; }
int User::getLikedPagesCount() const { return likedPagesCount; }
QString User::getUsername() const { return this->username; }