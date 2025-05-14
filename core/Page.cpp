#include "Page.h"
#include <QDebug>
int Page::totalPages = 0;
Page::Page(const QString &title, User *owner)
    : title(title), owner(owner), postCount(0), likesCount(0),
      postsCapacity(5) {
  pageID = QString("P%1").arg(++totalPages, 4, 10, QChar('0'));
  posts = new Post *[postsCapacity]();
  // Initialize all pointers to nullptr
  for (int i = 0; i < postsCapacity; ++i) {
    posts[i] = nullptr;
  }
}
Page::~Page() {
  // Delete all posts
  for (int i = 0; i < postCount; ++i) {
    if (posts[i]) {
      delete posts[i];
    }
  }
  delete[] posts;
}
void Page::resizePostsArray() {
  int newCapacity = postsCapacity * 2;
  Post **newPosts = new Post *[newCapacity]();
  // Copy existing posts
  for (int i = 0; i < postCount; ++i) {
    newPosts[i] = posts[i];
  }
  // Initialize remaining pointers to nullptr
  for (int i = postCount; i < newCapacity; ++i) {
    newPosts[i] = nullptr;
  }
  delete[] posts;
  posts = newPosts;
  postsCapacity = newCapacity;
}
void Page::addPost(Post *post) {
  if (!post)
    return;
  if (postCount >= postsCapacity) {
    resizePostsArray();
  }
  posts[postCount++] = post;
}
void Page::addLike(User *user) {
  if (user) {
    likesCount++;
  }
}
void Page::setPosts(Post **newPosts, int count) {
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
Post **Page::getPosts(int *count) const {
  *count = postCount;
  return posts;
}
// Getters
QString Page::getPageID() const { return pageID; }
QString Page::getTitle() const { return title; }
User *Page::getOwner() const { return owner; }
int Page::getPostCount() const { return postCount; }
int Page::getLikesCount() const { return likesCount; }
void Page::setPageID(const QString &id) { pageID = id; }