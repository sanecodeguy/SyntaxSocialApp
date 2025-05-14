#ifndef MEMORY_H
#define MEMORY_H

#include "Post.h"

class Memory : public Post {
private:
    Post* originalPost;

public:
    Memory(Post* original, const QString& newDesc, User* author, const Date& date);
    QString displayPost() const override;
};

#endif // MEMORY_H