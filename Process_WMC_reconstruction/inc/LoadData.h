#ifndef LOADDATA_H
#define LOADDATA_H

#include <QObject>
#include <QThread>
#include <QProcess>
#include <QDir>
//#include <QElapsedTimer>
//#include <QFile>
//#include <QTextStream>
//#include <QDebug>

#include <boost/iostreams/device/mapped_file.hpp> // for mmap
#include "functions.h"
//#include <algorithm>  // for std::find
//#include <iostream>   // for std::cout
//#include <cstring>

class LoadData : public QThread
{
    Q_OBJECT
public:
    explicit LoadData(QObject *parent = nullptr);
    ~LoadData();

    bool ReadVector(const QString path,QVector<float> &out);
    bool ReadArray(const QString path, Mat &out);
    void ReadArray(const QString path);

    bool ReadArrayPointer();

    bool LoadInfoSimulation(const QString path, _info_simulations &info);


    void unzipFiles(QString file, QString extract_dir);
    void removeDirectoryRecursively(const QString& dirPath);

    bool getDataStatus()    {return _M_data_status;}

    Mat* getData()           {return _M_data;}



protected:
    /** Call process in parallel thread */
  void run();


signals:
    void loading_progess(QString);
    void data_Loaded(bool);

private:
    //Array
    QString _M_path;
    Mat *_M_data;
    bool _M_data_status;
};

#endif // LOADDATA_H
