/**
 * @file LoadData.h
 *
 * @brief This class contains the function for loading in parallel threads large txt files.
 * Data are stored in a pointer on Mat file to easily be used by other part of the programm.
 * @author Charly Caredda
 * Contact: caredda.c@gmail.com
 *
 */


#ifndef LOADDATA_H
#define LOADDATA_H

#include <QObject>
#include <QThread>
#include <QProcess>
#include <QDir>

#include <boost/iostreams/device/mapped_file.hpp> // for mmap
#include "functions.h"

class LoadData : public QThread
{
    Q_OBJECT
public:
    /** Class constructor */
    explicit LoadData(QObject *parent = nullptr);

    /** Class destructor: delete pointers */
    ~LoadData();

    /** Read a float vector
     *  @param path[in] path of the txt file that contains data
     *  @param out[out] vector of float in which data will be stored
    */
    bool ReadVector(const QString path,QVector<float> &out);

    /** Read an array of data
     *  @param path[in] path of the txt file that contains data
     *  @param out[out] array of float in which data will be stored
    */
    bool ReadArray(const QString path, Mat &out);

    /** Read an array of data in a parallel thread (used for large txt files)
     *  @param path[in] path of the txt file that contains data
    */
    void ReadArray(const QString path);



    /** Load simulation info and store it into a _info_simulations structure
     *  @param path path of the txt file that contains the information
     *  @param info structured that is used to store the simulation information
    */
    bool LoadInfoSimulation(const QString path, _info_simulations &info);

    /** Unzip .zip files
     *  @param file file to be unzipped
     *  @param extract_dir directory that will containes data
    */
    void unzipFiles(QString file, QString extract_dir);


    /** Remove directory recursively from an input path
     *  @param dirPath path from which data are removed
    */
    void removeDirectoryRecursively(const QString& dirPath);


    /** Get data status (correctly loaded)
     *  @returns boolean that indicates the correct loading of data
    */
    bool getDataStatus()    {return _M_data_status;}

    /** Get data
     *  @returns pointer that points on a Mat containing data
    */
    Mat* getData()           {return _M_data;}



protected:
    /** Call process in parallel thread */
  void run();


signals:
    /** Signal that indicates the status of data loading
    *  @param[out] string to indicate the status of data loading
    */
    void loading_progess(QString);

    /** Signal that indicates that data have been read
     *  @param[out] boolean flag that indicates that data have been read
    */
    void data_Loaded(bool);

private:
    /** Private functions to read data that is called when the parallel thread started.
     *  @returns boolean flag that indicates if data have been correctly read
    */
    bool ReadArrayPointer();

    /** Path of the txt file that contains the data */
    QString _M_path;

    /** Pointer on Mat file in which data will be stored */
    Mat *_M_data;

    /** Boolean flag to indicate that data has been correctly loaded */
    bool _M_data_status;
};

#endif // LOADDATA_H
