fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios unit_test
```
fastlane ios unit_test
```
Runs the unit tests in QCardsTests
### ios ui_test
```
fastlane ios ui_test
```
Runs the UI tests in QCardsUITests
### ios deploy_to_app_store
```
fastlane ios deploy_to_app_store
```
Deploys QCards to App Store

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
