# DI Helper for Swift

<a href="https://apps.apple.com/jp/app/di-helper-for-swift/id1554978841">
  <img src="https://user-images.githubusercontent.com/18320004/104383646-82439800-5573-11eb-8ba7-397e9ecff86a.png" width=200 />
</a>

<img src="https://user-images.githubusercontent.com/18320004/112854742-19d37400-90e9-11eb-9d8e-8f9d807bd233.png" width=200 />


DI Helper for Swift is macOS app.
It generates source code of Protocol and Test doubles automatically.
It can also run on Xcode as Xcode Source Extension.

# Introduction

Making a class testable has some bothring steps.

1. defining protocols for the depending classes to separate.
2. implementing test doubles based on the protocols.

This app automates them with Xcode Source Extension.

## Usage
### 1. Open "System Preferences" > "Extension"
<img width="503" alt="step1" src="https://user-images.githubusercontent.com/18320004/112855317-a847f580-90e9-11eb-9375-ee6e709aaa9d.png">

### 2. Select a checkmark of “DI Helper for Swift”
<img width="780" alt="step2" src="https://user-images.githubusercontent.com/18320004/112855337-aaaa4f80-90e9-11eb-8c94-765a8cab0259.png">

### 3. Select a range in your source code
<img width="551" alt="Screen Shot 2021-02-23 at 11 21 15" src="https://user-images.githubusercontent.com/18320004/112855347-ad0ca980-90e9-11eb-9f31-fff5605e2567.png">

### 4. Choose "Editor" > “DI Helper for Swift”
<img width="631" alt="Screen Shot 2021-02-23 at 11 21 32" src="https://user-images.githubusercontent.com/18320004/112855356-af6f0380-90e9-11eb-88f5-4080f41a03df.png">


## Requirement

- Xcode 12.x
- Swift 5.3

# License

MIT License

Copyright (c) 2021 Kazuhiro Hayashi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
