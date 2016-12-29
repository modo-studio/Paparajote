![header](Assets/Header.png)

[![build status](https://gitlab.com/caramba/Paparajote/badges/master/build.svg)](https://gitlab.com/caramba/Paparajote/commits/master)
[![codecov](https://codecov.io/gl/caramba/Paparajote/branch/master/graph/badge.svg)](https://codecov.io/gl/caramba/Paparajote)

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

#### Using UIWebView *(iOS only)*

If you're using `UIWebView` from `UIKit` you can trigger the OAuth2 with a few simple steps:

1. Create an instance of `OAuth2WebviewDelegate` passing the provider, the webview, and a completion closure that will be executed once the authentication completes.
2. Keep a reference to that delegate from your `ViewController`.


#### Using WKWebView *(iOS and macOS)*

If you're using `WKWebView` from `WKWebKit` you can trigger the OAuth2 with a few simple steps:

1. Create an instance of `OAuth2WKNavigationDelegate` passing the provider, the webview, and a completion closure that will be executed once the authentication completes.
2. Keep a reference to that delegate from your `ViewController`.

## About

<img src="https://github.com/carambalabs/Foundation/blob/master/ASSETS/avatar_rounded.png?raw=true" width="70" />

This project is funded and maintained by [Caramba](http://caramba.io). We 💛 open source software!

Check out our other [open source projects](https://github.com/carambalabs/), read our [blog](http://blog.caramba.io) or say :wave: on twitter [@carambalabs](http://twitter.com/carambalabs).

## Contribute

Contributions are welcome :metal: We encourage developers like you to help us improve the projects we've shared with the community. Please see the [Contributing Guide](https://github.com/carambalabs/Foundation/blob/master/CONTRIBUTING.md) and the [Code of Conduct](https://github.com/carambalabs/Foundation/blob/master/CONDUCT.md).

## License

Paparajote is available under the MIT license. See the LICENSE file for more info.
