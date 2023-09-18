#include "LoadData.h"

LoadData::LoadData(QObject *parent)
    : QThread{parent}
{
    _M_data = Mat::zeros(0,0,CV_32FC1);
    _M_path = "";
    _M_send_data_finished_loaded = false;
}


/** Call process in parallel thread */
void LoadData::run()
{
    ReadArray(_M_path, _M_data);

    if(_M_send_data_finished_loaded)
        emit data_ReadyFor_processing();
}


//read vector
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

void LoadData::ReadArray(const QString path,bool send_Data_finished_loaded)
{
    _M_path = path;
    _M_send_data_finished_loaded = send_Data_finished_loaded;
    this->start();
}




bool LoadData::ReadArray(const QString path, Mat &out)
{
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

     out = Mat::zeros(0,0,CV_32FC1);

     //Get nb of columns
     int nb_columns = 0;
    QFile file(path);
    if(file.open(QIODevice::ReadOnly))
    {
        QTextStream textStream(&file);
//        QStringList list = textStream.readLine().split(QRegExp(","), QString::SkipEmptyParts);
        QStringList list = textStream.readLine().split(" ");
        file.close();
        nb_columns = list.size();
        file.close();
    }

    emit loading_progess("Load data...");

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
    else
        return false;

//    qDebug()<<"Elapsed time ReadArray Qt: "<<timer.elapsed();

    emit loading_progess("Data loaded...");

//    if(emitSignal_after_loading)
//        emit data_ReadyFor_processing(true);

    return true;
}

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

    // Start the unzip process
    emit loading_progess("Unzip data");

    unzipProcess.start();
    unzipProcess.waitForFinished();

    if (unzipProcess.exitStatus() == QProcess::NormalExit)
        qDebug() << "Extraction successful.";
    else
        qDebug() << "Extraction failed.";

}



void LoadData::removeDirectoryRecursively(const QString& dirPath)
{
    QDir dir(dirPath);

    // Check if the directory exists
    if (!dir.exists())
    {
        qDebug() << "Directory does not exist: " << dirPath;
        return;
    }

    dir.removeRecursively();
}

/*
 * void redFilesBoost(QString path)
{
    cout<<"Test"<<endl;
    //get the number of lines
    boost::iostreams::mapped_file mmap(path.toStdString(), boost::iostreams::mapped_file::readonly);
    auto f = mmap.const_data();
    auto l = f + mmap.size();

    uintmax_t m_numLines = 0;
    while (f && f!=l)
        if ((f = static_cast<const char*>(memchr(f, '\n', l-f))))
        {
            m_numLines++;
            f++;
        }
    char *data = mmap.data();
    cout<<(void *)data;
//    string s = data;
//    cout<<s;

    qDebug()<<"nb of lines: "<<m_numLines;

}
/*
    //read file
    boost::iostreams::mapped_file_source file;
    int numberOfElements = m_numLines;
    int numberOfBytes = numberOfElements*sizeof(string);
    file.open(path.toStdString(), numberOfBytes);


    // Check if file was successfully opened
    if(file.is_open()) {

        // Get pointer to the data
        std::string *string_data = (string*) file.data();


        cout<<string_data[0];
//        std::string delimiter = "\n";

//        QVector<string> test;
//        for(int i=0;i<m_numLines;i++)
//            test.push_back(string_data[i]);

//        size_t pos = 0;
//        while ((pos = string_data.find(delimiter)) != std::string::npos) {
//            test.push_back(string_data.substr(0, pos));
//            string_data.erase(0, pos + delimiter.length());
//        }

        qDebug()<<"nb of lines: "<<m_numLines;
//        qDebug()<<"Vector size: "<<test.size();


//        size_t pos = 0;
//        std::string token;
//        while ((pos = string_data.find(delimiter_char)) != std::string::npos) {
//            token = s.substr(0, pos);
//            std::cout << token << std::endl;
//            s.erase(0, pos + delimiter_char.length());
//        }
//        qDebug()<<QString::fromStdString(string_data);

//        // Do something with the data
//        for(int i = 0; i < numberOfElements; i++)
//            qDebug() << QString::fromStdString(string_data) << " ";

        // Remember to unmap the file
        file.close();
    } else {
        qDebug() << "could not map the file filename.raw";
    }
*/


