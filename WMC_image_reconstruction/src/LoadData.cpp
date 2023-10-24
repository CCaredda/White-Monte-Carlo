#include "LoadData.h"

LoadData::LoadData(QObject *parent)
    : QThread{parent}
{
    _M_data = new Mat(Mat::zeros(0,0,CV_32FC1));
    _M_path = "";
    _M_data_status = false;
}

LoadData::~LoadData()
{
    delete _M_data;
}


/** Call process in parallel thread */
void LoadData::run()
{
    qDebug()<<"LoadData In run";
    _M_data_status = false; //Init to false (data not loaded)
    _M_data_status = ReadArrayPointer();
    _M_data_status = ((*_M_data).empty()) ? false : _M_data_status;

    emit data_Loaded(_M_data_status);
}


/** Read a float vector
 *  @param path[in] path of the txt file that contains data
 *  @param out[out] vector of float in which data will be stored
*/
bool LoadData::ReadVector(const QString path,QVector<float> &out)
{
    QElapsedTimer timer;
    timer.start();

    QFile file(path);
    out.clear();

    if(file.open(QIODevice::ReadOnly))
    {
        QTextStream in(&file);
        QString line = in.readLine();
        QStringList list = line.split(" ");


        for (int i=0;i<list.size();i++)
        {
            out.push_back(list[i].toFloat());
        }

    }
    else
        return false;

    qDebug()<<"Elapsed time ReadVector Qt: "<<timer.elapsed();

    return true;
}

/** Read an array of data in a parallel thread (used for large txt files)
 *  @param path[in] path of the txt file that contains data
*/
void LoadData::ReadArray(const QString path)
{
    qDebug()<<"LoadData In ReadArray";
    _M_path = path;
    this->start();
}

/** Read an array of data
 *  @param path[in] path of the txt file that contains data
 *  @param out[out] array of float in which data will be stored
*/
bool LoadData::ReadArray(const QString path, Mat &out)
{
    //init output
    out = Mat::zeros(0,0,CV_32FC1);

    //Check if file exists
    QFile file(path);
    if(!file.exists())
        return false;

    if(!file.open(QIODevice::ReadOnly))
        return false;
    file.close();


    //get the number of lines
    boost::iostreams::mapped_file mmap(path.toStdString(), boost::iostreams::mapped_file::readonly);
    auto f = mmap.const_data();
    auto l = f + mmap.size();

    int m_numLines = 0;
    while (f && f!=l)
    {
        if ((f = static_cast<const char*>(memchr(f, '\n', l-f))))
        {
            m_numLines++;
            f++;
        }
    }



     //Get nb of columns
     int nb_columns = 0;
    if(file.open(QIODevice::ReadOnly))
    {
        QTextStream textStream(&file);
//        QStringList list = textStream.readLine().split(QRegExp(","), QString::SkipEmptyParts);
        QStringList list = textStream.readLine().split(" ");
        file.close();
        nb_columns = list.size();
        file.close();
    }

    //init output
    out = Mat::zeros(m_numLines,nb_columns,CV_32FC1);
    if(file.open(QIODevice::ReadOnly))
    {
        QTextStream textStream(&file);
        for(int i=0;i<m_numLines;i++)
        {
            //QStringList list = textStream.readLine().split(QRegExp(","), QString::SkipEmptyParts);
            QStringList list = textStream.readLine().split(" ");
            for(int col=0;col<list.size();col++)
            {
                out.at<float>(i,col) = list[col].toFloat();
            }


        }
        file.close();
    }


//    qDebug()<<"Elapsed time ReadArray Qt: "<<timer.elapsed();


//    if(emitSignal_after_loading)
//        emit data_ReadyFor_processing(true);

    return true;
}

/** Private functions to read data that is called when the parallel thread started.
 *  @returns boolean flag that indicates if data have been correctly read
*/
bool LoadData::ReadArrayPointer()
{
    qDebug()<<"Read array in pointer: "<<_M_path;
    //init output
    delete _M_data;
    _M_data = new Mat(Mat::zeros(0,0,CV_32FC1));

    //Check if file exists
    QFile file(_M_path);
    if(!file.exists())
        return false;

    if(!file.open(QIODevice::ReadOnly))
        return false;
    file.close();


    //get the number of lines
    boost::iostreams::mapped_file mmap(_M_path.toStdString(), boost::iostreams::mapped_file::readonly);
    auto f = mmap.const_data();
    auto l = f + mmap.size();

    int m_numLines = 0;
    while (f && f!=l)
    {
        if ((f = static_cast<const char*>(memchr(f, '\n', l-f))))
        {
            m_numLines++;
            f++;
        }
    }



     //Get nb of columns
     int nb_columns = 0;
    if(file.open(QIODevice::ReadOnly))
    {
        QTextStream textStream(&file);
//        QStringList list = textStream.readLine().split(QRegExp(","), QString::SkipEmptyParts);
        QStringList list = textStream.readLine().split(" ");
        file.close();
        nb_columns = list.size();
        file.close();
    }

    //init output
    _M_data = new Mat(Mat::zeros(m_numLines,nb_columns,CV_32FC1));
    if(file.open(QIODevice::ReadOnly))
    {
        QTextStream textStream(&file);
        for(int i=0;i<m_numLines;i++)
        {
            //QStringList list = textStream.readLine().split(QRegExp(","), QString::SkipEmptyParts);
            QStringList list = textStream.readLine().split(" ");
            for(int col=0;col<list.size();col++)
            {
                (*_M_data).at<float>(i,col) = list[col].toFloat();
            }


        }
        file.close();
    }

    return true;
}


/** Load simulation info and store it into a _info_simulations structure
 *  @param path path of the txt file that contains the information
 *  @param info structured that is used to store the simulation information
*/
bool LoadData::LoadInfoSimulation(const QString path, _info_simulations &info)
{
    QFile file(path+"/cst.txt");

    //If file does not exist, indicate 2 steps (1 periode of stimulation)
    if(!file.exists())
        return false;


    if(file.open(QIODevice::ReadOnly))
    {
        QTextStream in(&file);

        while(!in.atEnd())
        {
            QStringList list = in.readLine().split(" ");
            if(!list.empty())
            {
                if(list[0]=="nb_photons")
                    info.nb_photons = ((int)((list[list.size()-1].toInt())));
                if(list[0]=="repetitions")
                    info.repetions = ((int)((list[list.size()-1].toInt())));
                if(list[0]=="unitinmm")
                    info.unit_in_mm = list[list.size()-1].toFloat();

                if(list[0]=="vol_rows")
                    info.modelled_volume_rows = ((int)((list[list.size()-1].toInt())));
                if(list[0]=="vol_cols")
                    info.modelled_volume_cols = ((int)((list[list.size()-1].toInt())));
            }
        }
    }

    return true;
}

/** Unzip .zip files
 *  @param file file to be unzipped
 *  @param extract_dir directory that will containes data
*/
void LoadData::unzipFiles(QString file,QString extract_dir)
{

    QDir dir(extract_dir);

    //Create saving dir
    if(!dir.exists())
        dir.mkdir(extract_dir);

    // Use QProcess to execute the 'unzip' command
    QProcess unzipProcess;
    unzipProcess.setProgram("unzip"); // Assuming 'unzip' is available in your system's PATH
    QStringList arguments;
    arguments << file<< "-d" << extract_dir;
    unzipProcess.setArguments(arguments);

    unzipProcess.start();
    unzipProcess.waitForFinished();

    if (unzipProcess.exitStatus() == QProcess::NormalExit)
        qDebug() << "Extraction successful.";
    else
        qDebug() << "Extraction failed.";

}



/** Remove directory recursively from an input path
 *  @param dirPath path from which data are removed
*/
void LoadData::removeDirectoryRecursively(const QString& dirPath)
{
    QDir dir(dirPath);

    // Check if the directory exists
    if (!dir.exists())
        return;


    dir.removeRecursively();
}

