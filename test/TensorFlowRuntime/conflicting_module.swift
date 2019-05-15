// Compiles two modules with identically-named tensor functions, then calls
// those functions. This reproduces a former bug where the associated
// "whilecond" and "whilebody" functions get identical names, which causes a
// crash at runtime when adding the functions to the eager context.

// RUN: %empty-directory(%t)
// RUN: %target-build-swift %S/Inputs/ConflictingModule1.swift -emit-module -emit-library -module-name ConflictingModule1 -o %t/%target-library-name(libConflictingModule1) -emit-module-path %t/ConflictingModule1.swiftmodule
// RUN: %target-build-swift %S/Inputs/ConflictingModule2.swift -emit-module -emit-library -module-name ConflictingModule2 -o %t/%target-library-name(libConflictingModule2) -emit-module-path %t/ConflictingModule2.swiftmodule
// RUN: %target-build-swift %s -I %t -L %t %t/%target-library-name(libConflictingModule1) %t/%target-library-name(libConflictingModule2) -Xlinker -rpath -Xlinker %t -o %t/a.out
// RUN: %target-run %t/a.out %swift-tensorflow-test-run-extra-options
// REQUIRES: executable_test

import StdlibUnittest
#if TPU
import TensorFlowUnittestTPU
#else
import TensorFlowUnittest
#endif

import ConflictingModule1
import ConflictingModule2

var ConflictingModuleTests = TestSuite("ConflictingModule")

ConflictingModuleTests.testAllBackends("call functions") {
  expectEqual(5, ConflictingModule1.conflictingFunction(5).scalar!)
  expectEqual(10, ConflictingModule2.conflictingFunction(5).scalar!)
}

runAllTests()