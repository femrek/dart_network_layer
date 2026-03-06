## 0.7.1 - 2025-10-25



### 🚜 Refactor

- Refactor: Implement the singleton pattern for IgnoredResponseModelFactory


## 0.7.0 - 2025-10-25



### 🚀 Features

- Feat: Allows handling error response bodies.

- ResponseResult and RequestCommand have one more generic type representing the error response type.
- Create IgnoredResponseModel as a ResponseModel implementation provided by the core library. Useful when the response payload is not relevant.



### 🚜 Refactor

- Refactor: remove payload and headers from RequestCommand.toLogString() method. It can be still overridden by the subclass.


## 0.6.0 - 2025-09-21



### 🚀 Features

- Feat: Create ResponseModelFactory and subclasses to reduce
ResponseModel. No more sample response model.

* Remove JsonResponseModel and CustomResponseModel classes.
  ResponseModes can be extended directly.
* Create abstract classes 'JsonResponseFactory' and
  'CustomResponseFactory' to extend for each response model.
* Update RequestCommand with 'responsefactory' field instead of
  'sampleModel'.



### 📚 Documentation

- Docs: improve clarity and grammar in README.md


## 0.5.0 - 2025-08-30



### 🐛 Bug Fixes

- Fix: example project is updated to new version.

- Fix: example flutter dio app updated to new version of the packages.



### 🚜 Refactor

- Refactor: init monorepo

- Refactor: update request payload handling and enum definitions

- Refactor: enhance error handling and logging in network invoker.

* Remove some log types.
* Refactor onLog calls in invoker implementations.



### 🧪 Testing

- Test: root test extended.


## dart_v0.4.0 - 2025-01-21



### 🐛 Bug Fixes

- Fix: missing tag pattern in change_log_reader.dart

- Fix: workflow release package name.


## dio_v0.4.0 - 2025-01-21



### 🚀 Features

- Feat: core module version updated to 0.4

* Logging is updated as core package.

- Feat: dart impl switched to core v0.4


## core_v0.4.1 - 2025-01-20



### 🐛 Bug Fixes

- Fix: core_v0.4.1

* missing export of a file.


## core_v0.4.0 - 2025-01-20



### 🚀 Features

- Feat: dart implementaion is created with basic test.

* The invoker implementation class is created.
* a simple test is created.

- Feat: logger rules in core package.

* log type enum and on log funciton type is added to core package.
* `INetworkInvoker` have onLog function.

- Feat: core package has error data types for errors of invokers.

* NetworkError classes are created.
* Error log types are updated with new error data types.



### 🚜 Refactor

- Refactor: logging in core module is improved.

* Enum is removed. Using classes instead of the enum of log types.
* Tests is written for each class of log type.
* Response and Request models hava toLogString function.



### 🧪 Testing

- Test: a simple test is written in the root of the project.

* http_test_server is added to project.
* Dio and Dart implementation is being test at the same time.


## dio_v0.3.0 - 2025-01-12



### 🚀 Features

- Feat: dio_v0.3.0

* dart_network_layer_core dependency updated to v0.3.0
* `when` and `whenAsync` functions of `ResponseResult`
  class are updated to be able to return a custom data.



### 🐛 Bug Fixes

- Fix: workflow release


## core_v0.3.0 - 2025-01-12



### 🚀 Features

- Feat: core_v0.3.0

* when and whenAsync functions of ResponseResult class are able to
  return an object optionally.


## core_v0.2.1 - 2025-01-12



### 🚀 Features

- Feat: example_flutter_dio is updated to new packages.

- Feat: generating class diagram of whole project.

* Script added to generate mermaid file.

- Feat: reads CHANGELOG.md file when creating github releases.



### 🐛 Bug Fixes

- Fix: change log reader extracts absolute number.

- Fix: workflow release job. release body.

- Fix: workflow file. release



### 🧪 Testing

- Test: dio implementation unit test refactored with http_test_server

* http_test_server added to project dev dependencies.
* Instead of using HttpServer directly, using the added package in
  tests.


## 0.2.0 - 2025-01-08



### 🚀 Features

- Feat: v0.2.0

* dart_network_layer_dio dependency updated to v0.2.0.
* example project and its tests are migrated.



### 🐛 Bug Fixes

- Fix: workflow publish install dependencies --no-example flag.


## dio_v0.2.0 - 2025-01-08



### 🐛 Bug Fixes

- Fix: workflow wrong env usage is corrected.


## core_v0.2.0 - 2025-01-08



### 🚀 Features

- Feat: core structure updated significantly.

* IResponseModel interface replaced with ResponseModel base class and
  JsonResponseModel and CustomResponseModel classes.
* In production level the response models should be extend one of this
  classes instead of implementing.

- Feat: in core module, IRequestCommand turned into RequestCommand.

* The interface IRequestCommand turned into a class.
* Default values are assinged in that class excluding path and
  sampleModel.

- Feat: workflow has pub dev publish code.

- Feat; dio_v0.2.0

* Core module version updated to 0.2.0
* Model classes are renewed according to new core classes.
* readme and changelog files are updated.



### 🐛 Bug Fixes

- Fix: workflow tags are fixed.

- Fix: workflow publis section is fixed.

- Fix: workflow publis section is fixed.

- Fix: workflow publish install dependencies in correct folder.



### 🎨 Styling

- Style: unncessary commend block.



### 🧪 Testing

- Test: for core module a basic test is written.

* workflow updated to test core module as well.


## core_v0.1.1 - 2025-01-07



### 🚀 Features

- Feat: example_flutter_dio application

* The example app renamed as example_flutter_dio
* It runs with its functions.

- Feat: core module example project reduced to dart console program.

- Feat: dio module example project reduced to dart console programm.



### 🐛 Bug Fixes

- Fix: example project dependency errors


## 0.1.0 - 2025-01-05



### 🚀 Features

- Feat: bundle package dependencies and exporting packages updated.

* No more it exports core package. the core package already exported by
  the implementation library.
* Dio impl package version updated.


## dio_v0.1.1 - 2025-01-05



### 🚀 Features

- Feat: core module verion updated.


## core_v0.1.0 - 2025-01-05



### 🐛 Bug Fixes

- Fix: github actions release script fixed. (zip file name)


## dio_v0.1.0 - 2025-01-05



### 🚀 Features

- Feat: core module has an example project

* A widget test is written to try the demo network usage without running
  the applicaiton.

- Feat: example of dio implementaion added.

* example project copied from bundle project.
* unneccesary import removed in dio impl.



### 📚 Documentation

- Doc: github action file explained better.


## dio_v0.0.2.7 - 2025-01-04



### 🐛 Bug Fixes

- Fix: github actions

* auto release script fixed

- Fix: github actions

* auto release script syntax and etc. fixed


## dio_v0.0.2.1 - 2025-01-04



### 🚀 Features

- Feat: network module.

* Response and request interfaces created.
* HttpRequestMethod enum create.
* RequestPayloadType enum create with json and form data values.
* For network module unit test are written for success and not found
  response.

- Feat: example project shows responses from api.

* network package is created in product folder to keep response models,
  request commands network manager initializer.
* a screen created to fetch and present data from api.
* tests are written for product requests and responses.
* in network module INetworkManager interface has init function with
  baseUrl parameter.

- Feat: post request and responses are added.

* RequestPostPost, RequestGetPost nad ResponsePost are added.
* Tests to get and post post are written.

- Feat: dio impl exports core package.



### 🐛 Bug Fixes

- Fix: analysis_options.yaml files are corrected for both package and
example project.

- Fix: flutter_test removed.

* added test package instead of flutter_test. it was lead to error
  because of flutter is not a dependency of the package.

- Fix: dio error responses. style: name change of dio impl logger

* Dio instance is created without validateStatus field.
* Better exception handling over request call of dio.
* onDioLog field is renamed to onLog.
* LogInterceptor is removed from init funciton of dio impl. Then, the
  interceptor list parameter is added to constructor fucntion of the dio
  implementation.

- Fix: github action, runnig tests.

* Test run command is updated to run in correct folder.



### 🚜 Refactor

- Refactor: logging in dio implementation of network module.

* The log level are replaced with specific names instead of standard
  names.
* maySensitiveData field is added to log level.

- Refactor: network manager renamed as network invoker.

* All components named like network manager renamed as network invoker.
* Some classes made final, immutable or etc.

- Refactor: ResponseResult refactored.

* isError field removed. (isSuccess is enough)
* whenAsync funciton is created as an alternative of when.

- Refactor: pubspec.yaml files are refactored.

* example project has a valid description.
* flutter dependency completely removed from package dependencies. (an
  import of cupertino removed by changing with core method.)


