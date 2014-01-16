# Include guard.
if (DEFINED THIRD_PARTY_MAVEN_LIBRARIES_CMAKE_)
  return()
endif ()
set(THIRD_PARTY_MAVEN_LIBRARIES_CMAKE_ TRUE)

function(maven_library LIB ARTIFACT_ID VERSION)
  set(JAR_FILE
      "${PROJECT_BINARY_DIR}/third_party/java/${ARTIFACT_ID}-${VERSION}.jar")
  set("third_party.${LIB}" ${JAR_FILE} PARENT_SCOPE)
  set(TARGET "third_party.${LIB}_target")
  add_custom_target(${TARGET} ALL)
  set_target_properties(
      ${TARGET} PROPERTIES ARTIFACT_ID "${ARTIFACT_ID}")
  set_target_properties(
      ${TARGET} PROPERTIES CLASSPATH_FILE "${JAR_FILE}.classpath_")
  set_target_properties(
      ${TARGET} PROPERTIES TARGET_FILE "${JAR_FILE}")
  set_target_properties(
      ${TARGET} PROPERTIES JAR_FILE "${ARTIFACT_ID}-${VERSION}.jar")
  set_target_properties(
      ${TARGET} PROPERTIES VERSION "${VERSION}")
  add_dependencies(${TARGET} ${MAVEN_LIBS_TARGET})
endfunction(maven_library)

maven_library(commons-logging commons-logging 1.1.3)
maven_library(javax.activation activation 1.1-rev-1)
maven_library(junit junit 4.8.1)
maven_library(protobuf_java_runtime protobuf-java 2.5.0)
maven_library(servlet-api servlet-api 2.5)
maven_library(spring-beans spring-beans 3.2.5.RELEASE)
maven_library(spring-context spring-context 3.2.5.RELEASE)
maven_library(spring-web spring-web 3.2.5.RELEASE)
maven_library(spring-webmvc spring-webmvc 3.2.5.RELEASE)
