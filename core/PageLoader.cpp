#include "Page.h"
#include "PageLoader.h"
#include "Post.h"
#include "Syntax.h"
#include "User.h"
#include <QDebug>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlEngine>
#include <cstring>
PageLoader::PageLoader(QObject *parent) : QObject(parent) {}
PageLoader::~PageLoader() {
  // clearMemory();
}
void PageLoader::setSyntax(Syntax *syntax) {
  // QMutexLocker locker(&m_mutex);
  m_syntax = syntax;
}
void PageLoader::clearMemory() {
  // QMutexLocker locker(&m_mutex);
  if (m_pages) {
    for (int i = 0; i < m_pageCount; i++) {
      if (m_pages[i]) {
        // Clear posts
        int postCount = 0;
        Post **posts = m_pages[i]->getPosts(&postCount);
        if (posts) {
          for (int j = 0; j < postCount; j++) {
            if (posts[j]) {
              delete posts[j];
              posts[j] = nullptr;
            }
          }
          delete[] posts;
        }
        // Delete page
        delete m_pages[i];
        m_pages[i] = nullptr;
      }
    }
    delete[] m_pages;
    m_pages = nullptr;
  }
  m_pageCount = 0;
  m_initialized = false;
}
bool PageLoader::loadFromJson(const QString &filePath) {
  // QMutexLocker locker(&m_mutex);
  if (m_initialized) {
    return true;
  }
  //
  // Handle resource paths
  QString resolvedPath =
      filePath.startsWith("qrc:") ? ":" + filePath.mid(4) : filePath;
  QFile file(resolvedPath);
  if (!file.open(QIODevice::ReadOnly)) {
    return false;
  }
  QJsonParseError parseError;
  QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &parseError);
  file.close();
  if (parseError.error != QJsonParseError::NoError) {
    return false;
  }
  QJsonObject rootObj = doc.object();
  if (!rootObj.contains("pages")) {
    return false;
  }
  QJsonArray pagesArray = rootObj["pages"].toArray();
  //
  // Allocate memory
  m_pageCount = pagesArray.size();
  m_pages = new Page *[m_pageCount](); // Zero-initialized array
  bool success = true;
  for (int i = 0; i < m_pageCount; i++) {
    if (!pagesArray[i].isObject()) {
      continue;
    }
    m_pages[i] = parsePage(pagesArray[i].toObject());
    if (!m_pages[i]) {
      success = false;
      break;
    }
  }
  if (success) {
    m_initialized = true;
    emit pagesChanged();
    //
  } else {
    clearMemory();
  }
  return success;
}
Page **PageLoader::getPages(int *count) {
  // QMutexLocker locker(&m_mutex);
  if (count)
    *count = m_pageCount;
  return m_pages;
}
Page *PageLoader::getPage(int index) {
  // QMutexLocker locker(&m_mutex);
  return (index >= 0 && index < m_pageCount) ? m_pages[index] : nullptr;
}
Post **PageLoader::getPagePosts(int pageIndex, int *count) {
  // QMutexLocker locker(&m_mutex);
  if (count)
    *count = 0;
  if (pageIndex < 0 || pageIndex >= m_pageCount || !m_pages[pageIndex]) {
    return nullptr;
  }
  return m_pages[pageIndex]->getPosts(count);
}
QVariantList PageLoader::getPagesList() {
  // QMutexLocker locker(&m_mutex);
  QVariantList list;
  for (int i = 0; i < m_pageCount; i++) {
    if (m_pages[i]) {
      list.append(QVariant::fromValue(m_pages[i]));
    }
  }
  return list;
}
QVariantList PageLoader::getPagePostsList(const QString &pageId) {
  // QMutexLocker locker(&m_mutex);
  QVariantList list;
  if (pageId.isEmpty()) {
    return list;
  }
  // Find page by ID first
  int pageIndex = -1;
  for (int i = 0; i < m_pageCount; ++i) {
    if (m_pages[i] && m_pages[i]->getPageID() == pageId) {
      pageIndex = i;
      break;
    }
  }
  if (pageIndex < 0) {
    return list;
  }
  // Get posts for the found index
  int postCount = 0;
  Post **posts = m_pages[pageIndex]->getPosts(&postCount);
  if (!posts || postCount <= 0) {
    return list;
  }
  // Convert to QVariantList safely
  for (int i = 0; i < postCount; ++i) {
    if (posts[i] && posts[i]->isValid()) {
      // Ensure the QObject-derived Post has proper QML ownership
      QQmlEngine::setObjectOwnership(posts[i], QQmlEngine::CppOwnership);
      list.append(QVariant::fromValue(posts[i]));
    } else {
    }
  }
  return list;
}
Post *PageLoader::parsePost(const QJsonObject &json) {
  if (json.isEmpty()) {
    return nullptr;
  }
  QString id =
      json["id"].toString(); // Make sure this matches your JSON structure
  QString imagePath = json["image"].toString();
  QString description = json["description"].toString();
  int likes = json["likes"].toInt();
  int comments = json["comments"].toInt();
  QDate date = QDate::fromString(json["date"].toString(), "yyyy-MM-dd");
  if (description.isEmpty() || date.isNull()) {
    return nullptr;
  }
  Post *post = new Post(m_syntax->getCurrentUser(), description, date);
  post->setId(id); // Make sure you have this setter in your Post class
  post->setImagePath(imagePath);
  post->setLikesCount(likes);
  post->setCommentsCount(comments);
  //
  return post;
}
Page *PageLoader::parsePage(const QJsonObject &json) {
  if (json.isEmpty()) {
    return nullptr;
  }
  if (!m_syntax) {
    return nullptr;
  }
  QString id = json["id"].toString();
  QString title = json["title"].toString();
  QString ownerId = json["owner"].toString();
  QString password = json["password"].toString();
  if (title.isEmpty() || ownerId.isEmpty()) {
    return nullptr;
  }
  // First try to find existing user
  User *owner = nullptr;
  int userCount = 0;
  User **allUsers = m_syntax->getAllUsers(&userCount);
  for (int i = 0; i < userCount; i++) {
    if (allUsers[i] && allUsers[i]->getUsername() == ownerId) {
      owner = allUsers[i];
      break;
    }
  }
  // If user not found, create through syntax
  if (!owner) {
    owner = m_syntax->createUserSignUpFile(ownerId, password);
    if (!owner) {
      return nullptr;
    }
  }
  Page *page = new Page(title, owner);
  page->setPageID(id);
  page->setLikesCount(json["likes"].toInt());
  page->setOwner(owner);
  QJsonArray postsArray = json["posts"].toArray();
  int postCount = postsArray.size();
  Post **posts = new Post *[postCount];
  memset(posts, 0, sizeof(Post *) * postCount);
  for (int i = 0; i < postCount; i++) {
    posts[i] = parsePost(postsArray[i].toObject());
  }
  page->setPosts(posts, postCount);
  owner->setPosts(posts, postCount);
  return page;
}
Page *PageLoader::findPageById(const QString &id) {
  for (int i = 0; i < m_pageCount; i++) {
    if (m_pages[i] && m_pages[i]->getPageID() == id) {
      return m_pages[i];
    }
  }
  return nullptr;
}