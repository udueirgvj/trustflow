cmake_minimum_required(VERSION 3.22.1)
project("secrets")

add_library(secrets SHARED secrets.cpp)

find_library(log-lib log)
target_link_libraries(secrets ${log-lib})
