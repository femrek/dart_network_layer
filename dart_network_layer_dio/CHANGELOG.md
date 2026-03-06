## 0.7.1

### 🚜 Refactor

- Refactor: Implement the singleton pattern for IgnoredResponseModelFactory

## 0.7.0

### 🚀 Features

- Feat: Allows handling error response bodies.
    - ResponseResult and RequestCommand have one more generic type representing the error response type.
    - Create IgnoredResponseModel as a ResponseModel implementation provided by the core library. Useful when the
      response payload is not relevant.

### 🚜 Refactor

- Refactor: remove payload and headers from RequestCommand.toLogString() method. It can be still overridden by the
  subclass.

## 0.6.0

### 🚀 Features

- Feat: Create ResponseModelFactory and subclasses to reduce
  ResponseModel. No more sample response model.

* Remove JsonResponseModel and CustomResponseModel classes.
  ResponseModes can be extended directly.
* Create abstract classes 'JsonResponseFactory' and
  'CustomResponseFactory' to extend for each response model.
* Update RequestCommand with 'responsefactory' field instead of
  'sampleModel'.

## 0.5.1

### 📚 Documentation

- Improve clarity and grammar in README.md

## 0.5.0

### 🐛 Bug Fixes

- Example project is updated to new version.

- Example flutter dio app updated to new version of the packages.

### 🚜 Refactor

- Init monorepo

- Update request payload handling and enum definitions

- Enhance error handling and logging in network invoker.

### 🧪 Testing

- Root test extended.

## 0.4.0

* Logging is updated as core package is updated.

## 0.3.0

* dart_network_layer_core dependency updated to v0.3.0
* `when` and `whenAsync` functions of `ResponseResult` class are updated to be able to return a custom data.

## 0.2.0

* dart_network_layer_core dependency updated to v0.2.0

## 0.1.3

* Example project is updated.

## 0.1.2

* Readme updated.
* Package Description updated.

## 0.1.1

* Core module dependency version updated to v0.1.0

## 0.1.0

* Alpha release

## 0.0.1

* initial release.
