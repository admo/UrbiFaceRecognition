set(URBI_ROOT_DIR "/usr" CACHE PATH "Urbi root directory.")

#find_package (OpenCV REQUIRED)
find_package (Urbi REQUIRED)
#find_package (Boost REQUIRED serialization)

#link_directories (${BOOST_LIBRARYDIR})

include_directories (${OpenCV_INCLUDE_DIRS} ${Boost_INCLUDE_DIRS} ${URBI_INCLUDE_DIRS})

if (WIN32)
  add_definitions( -DBOOST_ALL_DYN_LINK )
endif (WIN32)

add_library (ufacerecognition MODULE ufacerecognition.cpp)

target_link_libraries (ufacerecognition ${OpenCV_LIBS} ${URBI_LIBRARIES} ${Boost_LIBRARIES})

set_target_properties (ufacerecognition PROPERTIES
  PREFIX "")
  
install (TARGETS ufacerecognition DESTINATION lib/gostai/uobjects COMPONENT libraries)
