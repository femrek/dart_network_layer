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

## 0.4.1

* Fix: `network_error.dart` file is exported in `dart_network_layer_core.dart` file.

## 0.4.0

* Logging components are added to the core library. The implementations must provide an `onLog` function.
* Error types are created for the errors occurs in the network invokers.

## 0.3.0

* `when` and `whenAsync` functions of `ResponseResult` class are updated to be able to return a custom data.

## 0.2.1

* Readme updated.

## 0.2.0

* `IRequestCommand` interface turned into `RequestCommand` abstract class.
* `IResponseModel` interface turned into `JsonResponseModel` and `CustomResponseModel` abstract classes.
* In product level, requests and responses have to be created by extending these abstract classes.

## 0.1.1

* Readme updated.
* Example project updated.

## 0.1.0

* Alpha release

## 0.0.1

* initial release.
