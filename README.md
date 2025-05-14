<p align="center">
  <img src="https://raw.githubusercontent.com/sanecodeguy/SyntaxSocialApp/main/qml/screens/icons/logo.png" width="120" height="120" alt="Syntax Logo">
  <h1 align="center">Syntax - QML/Qt C++ Social Media App</h1>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Qt-6.x-%2341CD52?logo=qt" alt="Qt 6">
  <img src="https://img.shields.io/badge/QML-2.15-%2323B14D" alt="QML 2.15">
  <img src="https://img.shields.io/badge/C%2B%2B-17-%2300599C?logo=c%2B%2B" alt="C++17">
  <img src="https://img.shields.io/badge/CMake-3.16+-%23064F8C?logo=cmake" alt="CMake">
  <img src="https://img.shields.io/badge/Build-Ninja-%23017C92?logo=ninja" alt="Ninja Build">
</p>

---

## 🌟 Features

- **Modern QML Interface** with smooth animations
- **Qt Quick Controls 2** for polished UI components
- **C++ Backend** for high-performance logic
- **JSON Data Storage** for pages, posts, and user data
- **Responsive Design** works on desktop and mobile
- **Interactive Posts** with likes and comments

## 🖥️ Screens

| Auth Screen | Home Feed | Discover |
|-------------|-----------|----------|
| ![Auth](https://github.com/user-attachments/assets/8b0d6478-16c6-4ec5-b879-a0a017316173) | ![Home](https://github.com/user-attachments/assets/797b462e-50cb-469f-addb-5655b8751238) | ![Discover](https://github.com/user-attachments/assets/b2ff6bb0-cf04-4b26-8062-45133d9191e7) |

| PageView | Friends | Profile |
|----------|---------|---------|
| ![PageView](https://github.com/user-attachments/assets/fb15cee1-151b-48f8-aad7-17e316d24b2f) | ![Friends](https://github.com/user-attachments/assets/87170d51-fc96-442e-926a-ff36927efe19) | ![Profile](https://github.com/user-attachments/assets/4930b74b-3cac-407e-9f27-302b05f64724) |
## 🛠️ Tech Stack

- <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/qt/qt-original.svg" width="16" height="16"/> **Qt 6** - Core framework
- <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/qml/qml-original.svg" width="16" height="16"/> **QML** - Declarative UI language
- <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/cplusplus/cplusplus-original.svg" width="16" height="16"/> **C++17** - Backend logic
- <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/cmake/cmake-original.svg" width="16" height="16"/> **CMake** - Build system
- <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nixos/nixos-original.svg" width="16" height="16"/> **Ninja** - Fast build tool

## 📦 Project Structure (UML)
![image](https://github.com/user-attachments/assets/1f1911d6-01d7-43c7-9881-21b028ecf336)

## C++ Backend UML
![image](https://github.com/user-attachments/assets/861546bd-2466-4289-8f37-6e88c1d25260)

### Build Instructions
```bash
# Configure project
cmake -G Ninja -B build

# Compile
cd build && ninja

# Run
./Syntax
```

### Development Workflow
```bash
# Rebuild after changes
ninja -C build

# Clean build
rm -rf build/
cmake -G Ninja -B build
```
```json
📝 JSON Data Structure
{
  "id": "P001",
  "title": "The Simpsons",
  "owner": "doubleroote",
  "likes": 1000,
  "posts": [
    {
      "id": "PT001",
      "image": "qrc:/qml/images/posts/s1.jpg",
      "description": "Sheesh",
      "likes": 97,
      "comments": 3,
      "date": "2023-05-15"
    }
  ]
}
```
🤝 Contributing

    Fork the project

    Create your feature branch (git checkout -b feature/AmazingFeature)

    Commit your changes (git commit -m 'Add some amazing feature')

    Push to the branch (git push origin feature/AmazingFeature)

    Open a Pull Request

📜 License

MIT
<p align="center"> Made with ❤️ by <a href="https://github.com/sanecodeguy">Syed Al Rizvi</a> (sanecodeguy) </p> ```
