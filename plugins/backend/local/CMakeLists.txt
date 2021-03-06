set (NAME local)

set (UINAME ${NAME}UI)
set (DAEMONTARGET ${NAME}_target)
set (UITARGET ${UINAME}_target)

find_package(GLIB REQUIRED)
find_package(Curl REQUIRED)
include_directories(${GLIB_INCLUDE_DIRS})
include_directories(rss-glib)

add_subdirectory(libnxml)
add_subdirectory(libmrss)
add_subdirectory(rss-glib)

# ----------------------------------------------------------
# Daemon Plugin
# ----------------------------------------------------------

vala_precompile(VALA_C ${DAEMONTARGET}
    localInterface.vala
    localUtils.vala

PACKAGES
    libpeas-1.0
    json-glib-1.0
    libsoup-2.4
    gee-0.8
    libxml-2.0
    sqlite3
    libsecret-1

OPTIONS
    --target-glib=2.32
    --library ${NAME}

CUSTOM_VAPIS
    ${CMAKE_BINARY_DIR}/FeedReader.vapi
    ${CMAKE_BINARY_DIR}/FeedReaderCommon.vapi
    rss-glib/rss-glib-1.0.vapi
)

add_library(${NAME} SHARED ${VALA_C})
target_link_libraries(${NAME} gobject-2.0 glib-2.0 curl rss-glib mrss nxml)


# ----------------------------------------------------------
# UI Plugin
# ----------------------------------------------------------


vala_precompile(VALA_C2 ${UITARGET}
    localLoginWidget.vala
    SuggestedFeedRow.vala

PACKAGES
    libpeas-1.0
    gtk+-3.0
    gee-0.8
    json-glib-1.0
    libsecret-1
    sqlite3
    libsoup-2.4
    WebKit2-4.0
    posix
    libxml-2.0

OPTIONS
    --target-glib=2.32
    --library ${NAME}

CUSTOM_VAPIS
    ${CMAKE_BINARY_DIR}/FeedReaderUI.vapi
    ${CMAKE_BINARY_DIR}/FeedReaderCommon.vapi
    ${CMAKE_SOURCE_DIR}/vapi/gd-1.0.vapi
    rss-glib/rss-glib-1.0.vapi
)

GLIB_COMPILE_RESOURCES(GRESOURCES SOURCE ${NAME}.gresource.xml)

add_library(${UINAME} SHARED ${VALA_C2} ${GRESOURCES})
target_link_libraries(${UINAME} gobject-2.0 glib-2.0 curl rss-glib mrss nxml)


# ----------------------------------------------------------


add_dependencies(${NAME} ${UI_NAME} ${DAEMON_NAME})
add_dependencies(${UINAME} ${UI_NAME} ${DAEMON_NAME})

install(TARGETS ${NAME} DESTINATION ${PKGLIBDIR}/plugins)
install(TARGETS ${UINAME} DESTINATION ${PKGLIBDIR}/pluginsUI)
install(FILES ${NAME}.plugin DESTINATION ${PKGLIBDIR}/plugins)
install(FILES ${UINAME}.plugin DESTINATION ${PKGLIBDIR}/pluginsUI)

