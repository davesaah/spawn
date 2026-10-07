find_package(benchmark REQUIRED) # google benchmark

file(GLOB BENCH_FILES CONFIGURE_DEPENDS
  "${CMAKE_CURRENT_SOURCE_DIR}/bench_*.cpp"
)

foreach(BENCH_FILE ${BENCH_FILES})
  get_filename_component(BENCH_NAME ${BENCH_FILE} NAME_WE)

  add_executable(${BENCH_NAME} ${BENCH_FILE})

  target_link_libraries(${BENCH_NAME}
    PRIVATE
    spawn_lib
    benchmark::benchmark    # Google Benchmark
  )
endforeach()
