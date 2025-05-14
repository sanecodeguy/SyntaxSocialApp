#include "Page.h"
#include "PageLoader.h"
#include "Post.h"
#include "Syntax.h"
#include <QDebug>
#include <QFile>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
int main(int argc, char *argv[]) {
  QGuiApplication app(argc, argv);
  // Verify resources
  QFile testFile(":/assets/data/AllPages.json");
  // Create instances
  Syntax *syntax = new Syntax();
  PageLoader *pageLoader = new PageLoader();
  pageLoader->setSyntax(syntax);
  // Register singletons
  qmlRegisterSingletonInstance("com.rizzons.syntax", 1, 0, "Syntax", syntax);
  qmlRegisterSingletonInstance("com.company", 1, 0, "PageLoader", pageLoader);
  // Register Page class as a QML type
  qmlRegisterType<Page>("com.company", 1, 0, "NotPage");
  qmlRegisterType<Post>("com.rizzons.post", 1, 0, "Post");
  // Clean up on failure
  QQmlApplicationEngine engine;
  QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                   [pageLoader](QObject *obj, const QUrl &url) {
                     if (!obj) {
                       pageLoader->clearMemory();
                       QCoreApplication::exit(-1);
                     }
                   });
  engine.load(
      QUrl::fromLocalFile("/home/doubleroote/SocialAppNew/qml/main.qml"));
  return app.exec();
}