#include "Syntax.h"
#include <QDebug>
#include <QDir>
#include <QMetaObject>
#include <QQmlEngine>
#include <cstring>
#include <fstream>
#include <iostream>
Syntax::Syntax(QObject *parent)
    : QObject(parent), currentUser(nullptr), users(nullptr), m_usersCount(0),
      m_usersCapacity(10), m_likedPages(nullptr), m_likedPagesCount(0),
      m_likedPagesCapacity(10) {
  users = new User *[m_usersCapacity]();
  m_likedPages = new Page *[m_likedPagesCapacity]();
  for (int i = 0; i < m_usersCapacity; i++) {
    users[i] = nullptr;
  }
  for (int i = 0; i < m_likedPagesCapacity; i++) {
    m_likedPages[i] = nullptr;
  }
}
Syntax::~Syntax() {
  safeDeleteUsers();
  safeDeleteLikedPages();
}
void Syntax::safeDeleteUsers() {
  if (!currentUser) {
  }
  // QMutexLocker locker(&m_mutex);
  if (users) {
    for (int i = 0; i < m_usersCount; i++) {
      if (users[i]) {
        delete users[i];
        users[i] = nullptr;
      }
    }
    delete[] users;
    users = nullptr;
  }
  m_usersCount = 0;
  m_usersCapacity = 0;
  currentUser = nullptr;
}
void Syntax::safeDeleteLikedPages() {
  // QMutexLocker locker(&m_mutex);
  if (m_likedPages) {
    delete[] m_likedPages;
    m_likedPages = nullptr;
  }
  m_likedPagesCount = 0;
  m_likedPagesCapacity = 0;
}
void Syntax::resizeUsersArray() {
  // QMutexLocker locker(&m_mutex);
  int newCapacity = m_usersCapacity * 2;
  User **newUsers = new User *[newCapacity]();
  for (int i = 0; i < m_usersCount; i++) {
    newUsers[i] = users[i];
  }
  delete[] users;
  users = newUsers;
  m_usersCapacity = newCapacity;
}
void Syntax::saveFriendsDataToFile() {
  if (!currentUser) {
    return;
  }
  QString filePath =
      getLikedPagesFilePath().replace("liked_pages.json", "AllFriends.json");
  QFile file(filePath);
  if (!file.open(QIODevice::ReadWrite)) {
    return;
  }
  // Read existing data
  QJsonDocument doc = file.readAll().isEmpty()
                          ? QJsonDocument(QJsonObject())
                          : QJsonDocument::fromJson(file.readAll());
  file.resize(0);
  QJsonObject root = doc.object();
  QJsonObject usersObj = root["users"].toObject();
  // 1. Get current user's actual friends list from memory
  QJsonArray currentUserFriends;
  QVariantList friendsList = currentUser->getFriendsList();
  for (const QVariant &friendVar : friendsList) {
    User *friendUser = friendVar.value<User *>();
    if (friendUser) {
      currentUserFriends.append(friendUser->getUsername());
    }
  }
  // 2. Update current user's entry with their actual current friends
  usersObj[currentUser->getUsername()] = currentUserFriends;
  // 3. For each friend in current user's list, ensure mutual relationship
  for (const QVariant &friendVar : friendsList) {
    User *friendUser = friendVar.value<User *>();
    if (friendUser) {
      QJsonArray friendFriends;
      if (usersObj.contains(friendUser->getUsername())) {
        friendFriends = usersObj[friendUser->getUsername()].toArray();
      }
      // Add current user to friend's list if not present
      if (!friendFriends.contains(currentUser->getUsername())) {
        friendFriends.append(currentUser->getUsername());
        usersObj[friendUser->getUsername()] = friendFriends;
      }
    }
  }
  // 4. Handle removed friends - clean up reciprocal relationships
  QJsonArray previousFriends;
  if (doc.object()["users"].toObject().contains(currentUser->getUsername())) {
    previousFriends =
        doc.object()["users"].toObject()[currentUser->getUsername()].toArray();
  }
  // Find friends that were removed
  for (const QJsonValue &oldFriendVal : previousFriends) {
    QString oldFriend = oldFriendVal.toString();
    if (!currentUserFriends.contains(oldFriend)) {
      // Remove current user from the old friend's list
      if (usersObj.contains(oldFriend)) {
        QJsonArray oldFriendFriends = usersObj[oldFriend].toArray();
        QJsonArray updatedFriends;
        // Copy all friends except the current user
        for (const QJsonValue &friendVal : oldFriendFriends) {
          if (friendVal.toString() != currentUser->getUsername()) {
            updatedFriends.append(friendVal);
          }
        }
        usersObj[oldFriend] = updatedFriends;
      }
    }
  }
  root["users"] = usersObj;
  file.write(QJsonDocument(root).toJson());
  file.close();
}
QVariantList Syntax::loadFriendsData() {
  QVariantList result;
  // QMutexLocker locker(&m_mutex);
  if (!currentUser) {
    return result;
  }
  // Load from memory first
  result = currentUser->getFriendsList();
  // Load from file
  QString filePath =
      getLikedPagesFilePath().replace("liked_pages.json", "AllFriends.json");
  QFile file(filePath);
  if (file.open(QIODevice::ReadOnly)) {
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();
    QJsonObject root = doc.object();
    QJsonObject usersObj = root["users"].toObject();
    QString username = currentUser->getUsername();
    if (usersObj.contains(username)) {
      QJsonArray friendsArray = usersObj[username].toArray();
      for (const QJsonValue &val : friendsArray) {
        QString friendUsername = val.toString();
        User *friendUser = findUserByUsername(friendUsername);
        if (friendUser && !currentUser->isFriend(friendUser)) {
          currentUser->addFriend(friendUser);
          result.append(QVariant::fromValue(friendUser));
        }
      }
    }
  }
  emit FriendsDataChanged();
  return result;
}
void Syntax::addUser(User *user) {
  if (!user)
    return;
  // Check if user already exists
  for (int i = 0; i < m_usersCount; i++) {
    if (users[i] && users[i]->getUsername() == user->getUsername()) {
      return;
    }
  }
  // Resize if needed
  if (m_usersCount >= m_usersCapacity) {
    resizeUsersArray();
  }
  users[m_usersCount++] = user;
}
void Syntax::resizeLikedPagesArray() {
  // QMutexLocker locker(&m_mutex);
  int newCapacity = m_likedPagesCapacity * 2;
  Page **newArray = new Page *[newCapacity]();
  // Initialize all to nullptr
  for (int i = 0; i < newCapacity; i++) {
    newArray[i] = nullptr;
  }
  // Copy existing items
  for (int i = 0; i < m_likedPagesCount; i++) {
    newArray[i] = m_likedPages[i];
  }
  // Swap and delete old array
  Page **oldArray = m_likedPages;
  m_likedPages = newArray;
  delete[] oldArray;
  m_likedPagesCapacity = newCapacity;
}
int Syntax::findPageIndex(const QString &pageId) const {
  for (int i = 0; i < m_likedPagesCount; i++) {
    if (m_likedPages[i] && m_likedPages[i]->getPageID() == pageId) {
      return i;
    }
  }
  return -1;
}
QString Syntax::getLikedPagesFilePath() const {
  return "/home/doubleroote/SocialAppNew/assets/data/liked_pages.json";
}
bool Syntax::hasLikedPage(const QString &pageId) const {
  return findPageIndex(pageId) != -1;
}
void Syntax::loadLikedPages() {
  if (!currentUser) {
  }
  QString filePath = getLikedPagesFilePath();
  if (!currentUser) {
    return;
  }
  QFile file(filePath);
  if (!file.exists()) {
    filePath = "/home/doubleroote/SocialAppNew/assets/data/liked_pages.json";
    file.setFileName(filePath);
  }
  if (!file.open(QIODevice::ReadOnly)) {
    emit likedPagesLoaded();
    return;
  }
  QByteArray jsonData = file.readAll();
  file.close();
  if (jsonData.trimmed().isEmpty()) {
    emit likedPagesLoaded();
    return;
  }
  QJsonParseError parseError;
  QJsonDocument doc = QJsonDocument::fromJson(jsonData, &parseError);
  if (parseError.error != QJsonParseError::NoError) {
    emit likedPagesLoaded();
    return;
  }
  if (!doc.isObject()) {
    emit likedPagesLoaded();
    return;
  }
  QJsonObject root = doc.object();
  QJsonObject users = root["users"].toObject();
  if (!currentUser) {
    emit likedPagesLoaded();
    return;
  }
  QString currentUsername = currentUser->getUsername();
  if (currentUsername.isEmpty()) {
    emit likedPagesLoaded();
    return;
  }
  m_likedPagesCount = 0;
  delete[] m_likedPages;
  m_likedPagesCapacity = 10;
  m_likedPages = new Page *[m_likedPagesCapacity]();
  if (users.contains(currentUsername)) {
    QJsonArray likedPages = users[currentUsername].toArray();
    if (likedPages.size() > m_likedPagesCapacity) {
      delete[] m_likedPages;
      m_likedPagesCapacity = likedPages.size() * 2;
      m_likedPages = new Page *[m_likedPagesCapacity]();
    }
    for (const QJsonValue &value : likedPages) {
      QString pageId = value.toString();
      Page *page = PageLoader::findPageById(pageId);
      if (page) {
        if (m_likedPagesCount < m_likedPagesCapacity) {
          m_likedPages[m_likedPagesCount++] = page;
        } else {
        }
      }
    }
  } else {
  }
  emit likedPagesLoaded();
}
void Syntax::saveLikedPagesToFile() {
  // QMutexLocker locker(&m_mutex);
  if (!currentUser) {
    return;
  }
  QString username = currentUser->getUsername();
  if (username.isEmpty()) {
    return;
  }
  // Create JSON structure
  QJsonObject root;
  QJsonObject usersObject;
  QJsonArray likedPagesArray;
  // Build liked pages array
  for (int i = 0; i < m_likedPagesCount; ++i) {
    if (m_likedPages[i]) {
      likedPagesArray.append(m_likedPages[i]->getPageID());
    }
  }
  // Read existing data if file exists
  QFile file(getLikedPagesFilePath());
  if (file.exists() && file.open(QIODevice::ReadOnly)) {
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    if (!doc.isNull() && doc.isObject()) {
      root = doc.object();
      if (root.contains("users")) {
        usersObject = root["users"].toObject();
      }
    }
    file.close();
  }
  // Update with current user's data
  usersObject[username] = likedPagesArray;
  root["users"] = usersObject;
  // Write to file
  if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
    return;
  }
  file.write(QJsonDocument(root).toJson());
  file.close();
}
void Syntax::likePage(const QString &pageId) {
  // QMutexLocker locker(&m_mutex);
  int index = findPageIndex(pageId);
  bool wasLiked = (index != -1);
  if (wasLiked) {
    // Safe removal
    for (int i = index; i < m_likedPagesCount - 1; i++) {
      m_likedPages[i] = m_likedPages[i + 1];
    }
    m_likedPagesCount--;
  } else {
    // Safe addition
    if (m_likedPagesCount >= m_likedPagesCapacity) {
      resizeLikedPagesArray();
    }
    Page *page = PageLoader::findPageById(pageId);
    if (page) {
      m_likedPages[m_likedPagesCount++] = page;
    }
  }
  if (!currentUser) {
    return;
  }
  QString username = currentUser->getUsername();
  if (username.isEmpty()) {
    return;
  }
  // Create JSON structure
  QJsonObject root;
  QJsonObject usersObject;
  QJsonArray likedPagesArray;
  // Build liked pages array
  for (int i = 0; i < m_likedPagesCount; ++i) {
    if (m_likedPages[i]) {
      likedPagesArray.append(m_likedPages[i]->getPageID());
    }
  }
  // Read existing data if file exists
  QFile file(getLikedPagesFilePath());
  if (file.exists() && file.open(QIODevice::ReadOnly)) {
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    if (!doc.isNull() && doc.isObject()) {
      root = doc.object();
      if (root.contains("users")) {
        usersObject = root["users"].toObject();
      }
    }
    file.close();
  }
  // Update with current user's data
  usersObject[username] = likedPagesArray;
  root["users"] = usersObject;
  // Write to file
  if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
    return;
  }
  file.write(QJsonDocument(root).toJson());
  file.close();
  emit likedPagesChanged();
  emit pageLiked(pageId, !wasLiked);
}
User *Syntax::createUser(const QString &username, const QString &password) {
  // 1. Always reset currentUser first
  currentUser = nullptr;
  // 2. First load all users from files into memory
  QFile idFile("assets/data/id.txt");
  QFile passFile("assets/data/pass.txt");
  if (idFile.open(QIODevice::ReadOnly) && passFile.open(QIODevice::ReadOnly)) {
    QTextStream idStream(&idFile);
    QTextStream passStream(&passFile);
    QString fileUsername, filePassword;
    while (!idStream.atEnd() && !passStream.atEnd()) {
      fileUsername = idStream.readLine().trimmed();
      filePassword = passStream.readLine().trimmed();
      // Check if user already exists in our array
      bool userExists = false;
      for (int i = 0; i < m_usersCount; i++) {
        if (users[i] && users[i]->getUsername() == fileUsername) {
          userExists = true;
          break;
        }
      }
      // If not found, create and add the user
      if (!userExists && !fileUsername.isEmpty()) {
        User *fileUser = new User(fileUsername, fileUsername);
        QQmlEngine::setObjectOwnership(fileUser, QQmlEngine::CppOwnership);
        addUser(fileUser);
      }
    }
    idFile.close();
    passFile.close();
  } else {
  }
  if (!User::authenticateUser(username, password)) {
    return nullptr;
  }
  for (int i = 0; i < m_usersCount; i++) {
    if (users[i] && users[i]->getUsername() == username) {
      currentUser = users[i];
      return currentUser;
    }
  }
  User *newUser = new User(username, username);
  QQmlEngine::setObjectOwnership(newUser, QQmlEngine::CppOwnership);
  if (!newUser) {
    return nullptr;
  }
  addUser(newUser);
  currentUser = newUser;
  return currentUser;
}
QString Syntax::getUsername() const {
  if (!currentUser) {
    return QString();
  }
  return this->currentUser->getUsername();
}
User *Syntax::createUserSignUpFile(const QString &username,
                                   const QString &password) {
  const QString qPassword = password;
  const QString dataDir = "assets/data/";
  //
  QDir dir;
  if (!dir.exists(dataDir)) {
    if (!dir.mkpath(dataDir)) {
      return nullptr;
    }
  }
  User *newUser = new User(username, password);
  QQmlEngine::setObjectOwnership(newUser, QQmlEngine::CppOwnership);
  addUser(newUser);
  return newUser;
}
User **Syntax::getAllUsers(int *count) const {
  // QMutexLocker locker(&m_mutex); // Thread-safe access
  // Option 2: Safer - return a copy of the array (caller must delete[])
  User **userCopy = new User *[m_usersCount];
  for (int i = 0; i < m_usersCount; i++) {
    userCopy[i] = users[i];
  }
  *count = m_usersCount;
  return userCopy;
}
int Syntax::getUserCount() const {
  // QMutexLocker locker(&m_mutex); // Thread-safe access
  return m_usersCount;
}
User *Syntax::createUserSignUp(const QString &username,
                               const QString &password) {
  const QString qPassword = password;
  const QString dataDir = "assets/data/";
  //
  QDir dir;
  if (!dir.exists(dataDir)) {
    if (!dir.mkpath(dataDir)) {
      return nullptr;
    }
  }
  const QString idPath = dataDir + "id.txt";
  const QString passPath = dataDir + "pass.txt";
  std::ofstream idFile(idPath.toStdString(), std::ios::app);
  if (!idFile.is_open()) {
    return nullptr;
  }
  if (idFile.tellp() > 0) {
    idFile << "\n";
  }
  idFile << username.toStdString();
  idFile.close();
  //
  std::ofstream passFile(passPath.toStdString(), std::ios::app);
  if (!passFile.is_open()) {
    return nullptr;
  }
  if (passFile.tellp() > 0) {
    passFile << "\n";
  }
  passFile << qPassword.toStdString();
  passFile.close();
  //
  std::ifstream verifyPassFile(passPath.toStdString());
  if (verifyPassFile.is_open()) {
    std::string passContents((std::istreambuf_iterator<char>(verifyPassFile)),
                             std::istreambuf_iterator<char>());
    verifyPassFile.close();
  } else {
  }
  User *newUser = new User(username, username);
  QQmlEngine::setObjectOwnership(newUser, QQmlEngine::CppOwnership);
  addUser(newUser);
  this->currentUser = nullptr;
  return newUser;
}
bool Syntax::addFriend(const QString &username) {
  // QMutexLocker locker(&m_mutex);
  if (username.isEmpty()) {
    return false;
  }
  if (!currentUser) {
    return false;
  }
  // Don't add self as friend
  if (currentUser->getUsername() == username) {
    return false;
  }
  User *friendToAdd = findUserByUsername(username);
  if (!friendToAdd) {
    return false;
  }
  // Check if already friends
  if (currentUser->isFriend(friendToAdd)) {
  }
  // Perform the add (mutual by default)
  bool success = currentUser->addFriend(friendToAdd, true);
  if (success) {
    emit FriendsDataChanged();
    // Save to file immediately
    QMetaObject::invokeMethod(this, "saveFriendsDataToFile",
                              Qt::QueuedConnection);
  }
  return success;
}
bool Syntax::removeFriend(const QString &username) {
  // QMutexLocker locker(&m_mutex);
  if (username.isEmpty()) {
    return false;
  }
  if (!currentUser) {
    return false;
  }
  User *friendToRemove = findUserByUsername(username);
  if (!friendToRemove) {
    return false;
  }
  // Check if not friends
  if (!currentUser->isFriend(friendToRemove)) {
    return false;
  }
  // Perform the remove (mutual by default)
  bool success = currentUser->removeFriend(friendToRemove, true);
  if (success) {
    emit FriendsDataChanged();
    // Save to file immediately
    QMetaObject::invokeMethod(this, "saveFriendsDataToFile",
                              Qt::QueuedConnection);
  }
  return success;
}
bool Syntax::isFriend(const QString &username) {
  // QMutexLocker locker(&m_mutex);
  if (username.isEmpty()) {
    return false;
  }
  if (!currentUser) {
    return false;
  }
  User *user = findUserByUsername(username);
  if (!user) {
    return false;
  }
  return currentUser->isFriend(user);
}
bool Syntax::userExists(const QString &username) {
  for (int i = 0; i < m_usersCount; i++) {
    if (users[i] && users[i]->getUsername() == username) {
      return true;
    }
  }
  return false;
}
int Syntax::getFriendCount() const {
  // QMutexLocker locker(&m_mutex);
  return this->currentUser->getFriendCount();
}
int Syntax::getPostCount() const {
  // QMutexLocker locker(&m_mutex);
  return this->currentUser->getPostCount();
}
int Syntax::getLikedPagesCount() const {
  // QMutexLocker locker(&m_mutex);
  if (!currentUser) {
  }
  return this->currentUser->getLikedPagesCount();
}