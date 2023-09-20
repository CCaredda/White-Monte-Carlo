QT       += core gui concurrent

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++17
CONFIG += console

INCLUDEPATH += $$absolute_path(./inc)
INCLUDEPATH += /usr/include/opencv4

QMAKE_CXXFLAGS+= -fopenmp
QMAKE_LFLAGS += -fopenmp "-Wl,--enable-new-dtags -Wl,-rpath"


SOURCES += \
    $$PWD/src/main.cpp \
    $$PWD/src/mainwindow.cpp \
    $$PWD/src/functions.cpp \
    $$PWD/src/process.cpp \
    $$PWD/src/LoadData.cpp

HEADERS += \
    $$PWD/inc/mainwindow.h \
    $$PWD/inc/functions.h \
    $$PWD/inc/process.h \
    $$PWD/inc/LoadData.h

FORMS += \
    $$PWD/ui/mainwindow.ui

#get path of .pro file
DEFINES += PROPATH="\\\"$${_PRO_FILE_PWD_}\\\""

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target



LIBS += -lopencv_core -lopencv_flann -lopencv_highgui -lopencv_core -lopencv_imgproc -pthread -lboost_iostreams #-L(path to boost libraries)
