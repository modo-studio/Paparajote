# Paparajote

[![CI Status](http://img.shields.io/travis/carambalabs/Paparajote.svg?style=flat)](https://travis-ci.org/carambalabs/Paparajote)
[![codecov](https://codecov.io/gh/carambalabs/Paparajote/branch/master/graph/badge.svg)](https://codecov.io/gh/carambalabs/Paparajote)
[![Dependency Status](https://gemnasium.com/badges/github.com/carambalabs/Paparajote.svg)](https://gemnasium.com/github.com/carambalabs/Paparajote)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Paparajote is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Paparajote"
```

## Use

### Providers

In order to use Paparajote you have to make sure the provider is supported. You can check it in the list of [supported providers](Paparajote/Classes/Providers). If it's not supported, you can easily give support to a new provider conforming the protocol:

```swift
public typealias Authorization = () -> NSURL
public typealias Authentication = NSURL -> NSURLRequest?
public typealias SessionAdapter = (NSData, NSURLResponse) -> OAuth2Session?

public protocol OAuth2Provider {
    var authorization: Authorization { get }
    var authentication: Authentication { get }
    var sessionAdapter: SessionAdapter { get }
}

```

- **Authorization:** Returns the URL that triggers the OAuth2 flow.
- **Authentication:** Returns an authentication request if the url contains an authentication token.
- **SessionAdapter:** Extracts the session from the authentication response data.

> You can check out the existing providers [here](Paparajote/Classes/Providers)

### OAuth2 on iOS :iphone:

#### Using UIWebView

If you're using `UIWebView` from `UIKit` you can trigger the OAuth2 with a few simple steps:

1. Create an instance of `OAuth2WebviewDelegate` passing the provider, the webview, and a completion closure that will be executed once the authentication completes.
2. Keep a reference to that delegate from your `ViewController`.


#### Using WKWebView


### OAuth2 on macOS :computer:
//TODO


## About

<img src="https://github.com/carambalabs/Foundation/blob/master/ASSETS/avatar_rounded.png?raw=true" width="70" />

This project is funded and maintained by [Caramba](http://caramba.io). We 💛 open source software!

Check out our other [open source projects](https://github.com/carambalabs/), read our [blog](http://blog.caramba.io) or say :wave: on twitter [@carambalabs](http://twitter.com/carambalabs).

## Contribute

Contributions are welcome :metal: We encourage developers like you to help us improve the projects we've shared with the community. Please see the [Contributing Guide](https://github.com/carambalabs/Foundation/blob/master/CONTRIBUTING.md) and the [Code of Conduct](https://github.com/carambalabs/Foundation/blob/master/CONDUCT.md).

## License

Paparajote is available under the MIT license. See the LICENSE file for more info.
