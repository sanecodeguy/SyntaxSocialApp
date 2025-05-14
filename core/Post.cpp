#include "Post.h"

Post::Post(User *author, const QString &desc, const Date &date)
    : description(desc), sharedDate(date), likedByCount(0), commentsCount(0),
      capacity(10) {
  likedBy = new User *[capacity]();
  comments = new Comment *[capacity]();
}

Post::Post(User *author, const QString &desc, const QDate &date)
    : description(desc), sharedQDate(date), likedByCount(0), commentsCount(0),
      capacity(10) {
  likedBy = new User *[capacity]();
  comments = new Comment *[capacity]();
  this->author = author;
}

Post::~Post() {
  delete[] likedBy;
  for (int i = 0; i < commentsCount; ++i)
    delete comments[i];
  delete[] comments;
}

void Post::addLike(User *user) {
  if (likedByCount >= capacity) {
    capacity *= 2;
    User **newLikedBy = new User *[capacity]();
    for (int i = 0; i < likedByCount; ++i)
      newLikedBy[i] = likedBy[i];
    delete[] likedBy;
    likedBy = newLikedBy;
  }
  likedBy[likedByCount++] = user;
}
void Post::setImagePath(const QString &Path) { this->ImagePath = Path; }
void Post::setLikesCount(int count) { this->likedByCount = count; }
// Comment* Post::addComment(User* user, const QString& content) {
//     if (commentsCount >= capacity) {
//         capacity *= 2;
//         Comment** newComments = new Comment*[capacity]();
//         for (int i = 0; i < commentsCount; ++i) newComments[i] = comments[i];
//         delete[] comments;
//         comments = newComments;
//     }
//     comments[commentsCount] = new Comment(content, user);
//     return comments[commentsCount++];
// }

QString Post::displayPost() const {
  return QString("Post: %1\nDate: %2\nLikes: %3")
      .arg(description)
      .arg(sharedDate.toString())
      .arg(likedByCount);
}
QString Post::getDescription() const { return this->description; }
int Post::getLikesCount() const { return this->likedByCount; }
int Post::getCommentsCount() const { return this->commentsCount; }
QDate Post::getDate() const { return this->sharedQDate; }
QString Post::getImagePath() const {
  // qDebug()<<"[PageView] Post Image Path "<<this->ImagePath;
  return this->ImagePath;
}