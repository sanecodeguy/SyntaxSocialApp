#ifndef COMMENT_H
#define COMMENT_H

#include <QString>
#include "User.h"
#include "Page.h"

class User;
class Page;

class Comment {
private:
    QString content;
    User* author;
    Page* pageAuthor; // Optional (nullptr if user-authored)

public:
    Comment(const QString& content, User* author, Page* pageAuthor = nullptr);
    QString getContent() const;
    QString getAuthorName() const;
};

#endif // COMMENT_H