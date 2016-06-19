# Handwrito
A sample iOS Swift project manipulating the Handwriting.io API

## Content
- [Features](#features)
- [Installation](#installation)
- [Achitecture](#achitecture)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [TODOS](#todos)
- [License](#license)


## Features
- Validation of user's input
- Handwrited text render as a PNG Image
- Loader while processing
- Error handling
- Version and Build versioning, respectively, on Build and on Package the project  
- CocoaPods to manage dependencies

## Installation
1. Download or clone the project
2. Add your Handwriting.io API Key and API Secret in `HWConstants.swift` file
```
/// The handwriting.io API Key
static let HANDWRITING_API_KEY = "<Your API Key goes here>"

/// The handwriting.io API Secret
static let HANDWRITING_API_SECRET = "<Your API Secret goes here>"
```

## Achitecture
This app uses the [Handwriting.io API](https://handwriting.io/) to render user's input text as a handwrited text as a PNG Image.

## Project Structure
This app is based on a MVC pattern. The project app folder is organized as follow:
```
- /
|- Application
|- HWConstant.swift (contains all constants used in the app)
|- API (all managers handle API calls)
|- Controllers (all controllers used by the App)
|- Utils (extensions, helpers, etc.)
|- Models (all models representing the data)
|- Resources
|- Assets.xcassets (contains all images, icons)
|- Languages (contains all localized files)
|- Views (contains all storyboards)
```

## Dependencies
Dependencies are managed by CocoaPods. This project uses the following:
- [Alamofire](https://github.com/Alamofire/Alamofire) HTTP Networking, GET and POST operations
- [SwiftValidator](https://github.com/jpotts18/SwiftValidator) to validate user's inputs
- [Dodo](https://github.com/marketplacer/Dodo) to display error messages

## TODOS
- [ ] Localize
- [ ] Choose from Popular Font
- [ ] Choose font size
- [ ] Choose font color
- [ ] App Icon
- [ ] Launch Screen
- [ ] Separate Component for text input and toolbar
- [ ] Select render between PNG image or PDF
- [ ] Support Orientation
- [ ] Support keyboard dismiss
- [ ] UI and Unit Tests
- [ ] Add CI
- [ ] Add Code Quality badge

---

## License
`handwrito` is released under MIT License. See `LICENSE` for details.

>**Copyright &copy; 2016 KBLNY.**

*Please provide attribution, it is greatly appreciated.*
