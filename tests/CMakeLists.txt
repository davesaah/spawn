find_package(GTest REQUIRED) # google test
include(GoogleTest)

file(GLOB TEST_FILES CONFIGURE_DEPENDS
  "${CMAKE_CURRENT_SOURCE_DIR}/test_*.cpp"
)

foreach(TEST_FILE ${TEST_FILES})
  get_filename_component(TEST_NAME ${TEST_FILE} NAME_WE)

  add_executable(${TEST_NAME}
    ${TEST_FILE}
  )

  target_link_libraries(${TEST_NAME}
    PRIVATE
    spawn_lib
    GTest::gtest_main  # GoogleTest main runner
    GTest::gmock       # GoogleMock
  )

  # automatically register tests
  gtest_discover_tests(${TEST_NAME})
endforeach()
