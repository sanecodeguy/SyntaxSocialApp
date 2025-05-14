#include "Memory.h"

Memory::Memory(Post* original, const QString& newDesc, User* author, const Date& date)
    : Post(author, newDesc, date), originalPost(original) {}

QString Memory::displayPost() const {
    return QString("Memory: %1\nOriginal: %2").arg(Post::displayPost()).arg(originalPost->displayPost());
}