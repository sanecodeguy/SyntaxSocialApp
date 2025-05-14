#ifndef PAGELOADER_H
#define PAGELOADER_H
#include "Page.h"
#include <QMutex>
#include <QObject>
#include <QVariant>
#include <QVariantList>
class Syntax;
class Page;
class Post;
class User;
class PageLoader : public QObject {
  Q_OBJECT
  Q_PROPERTY(QVariantList pages READ getPagesList NOTIFY pagesChanged)
public:
  explicit PageLoader(QObject *parent = nullptr);
  ~PageLoader();
  void setSyntax(Syntax *syntax);
  Q_INVOKABLE int returnPostLikesCount(QString postID) {
    for (int i = 0; i < this->m_pageCount; i++) {
      Post **temp = m_pages[i]->getPosts(0);
      for (int j = 0; j < this->m_pages[i]->getPostCount(); j++) {
        if (temp[j]->getId() == postID)
          return temp[i]->getLikesCount();
      }
    }
    return -1;
  }
  Q_INVOKABLE bool loadFromJson(const QString &filePath);
  Q_INVOKABLE static QVariantList getPagesList();
  Q_INVOKABLE int returnlikescount(QString pageID) const {
    for (auto i = 0; i < this->m_pageCount; i++) {
      if (this->m_pages[i]->getPageID() == pageID && this->m_pages[i])
        return this->m_pages[i]->getLikesCount();
    }
    return -1;
  }
  // Change the method signature in your header file
  Q_INVOKABLE QVariantList static getPagePostsList(const QString &pageId);
  Q_INVOKABLE static int getPageCount() {
    int count = 0;
    getPages(&count); // Calls your existing function
    return count;
  }
  Q_INVOKABLE static int getPostCount(int pageIndex) {
    int count = 0;
    getPagePosts(pageIndex, &count); // Calls your existing function
    return count;
  }
  Q_INVOKABLE QString getPageTitle(QString pageID) const {
    Page *temp = findPageById(pageID);
    return temp->getTitle();
  }
  Q_INVOKABLE static Page *findPageById(const QString &id);
  Q_INVOKABLE static void clearMemory();
  // New method to check initialization state
  Q_INVOKABLE static bool isInitialized() { return m_initialized; }
signals:
  void pagesChanged();

private:
  Post *parsePost(const QJsonObject &json);
  Page *parsePage(const QJsonObject &json);
  // Thread-safe getters
  static Page **getPages(int *count);
  static Page *getPage(int index);
  static Post **getPagePosts(int pageIndex, int *count);
  // Static members with mutex protection
  inline static Page **m_pages = nullptr;
  inline static int m_pageCount = 0;
  inline static Syntax *m_syntax = nullptr;
  inline static bool m_initialized = false;
  inline static QMutex m_mutex;
};
#endif