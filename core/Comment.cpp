#include "Comment.h"

Comment::Comment(const QString& content, User* author, Page* pageAuthor) 
    : content(content), author(author), pageAuthor(pageAuthor) {}

QString Comment::getContent() const { return content; }

QString Comment::getAuthorName() const {
    return pageAuthor ? pageAuthor->getTitle() : author->getUsername();
}