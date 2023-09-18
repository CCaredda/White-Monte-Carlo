#include "data.h"


////////////////////////////////////////////// A FAIRE ////////////////////////////////////
// Lire les fichiers texte p.txt et ppath.txt en parallele















Data::Data(QObject *parent)
    : QThread{parent}
{
    connect(&_M_loadData,SIGNAL(loading_progess(QString)),this,SIGNAL(processing(QString)));

    //Wavelenfth to process
    _M_wavelength_to_process.clear();
    _M_wavelength_to_process.push_back(500);

    //Saving dir
    _M_saving_dir = "";


    //Binning for reconstuction the images
    _M_binning = 1;

    //output image rows
    _M_out_img_rows = 0;
    //output image cols
    _M_out_img_cols = 0;

    //Wavelength
    _M_mua_eps_data_ready = _M_loadData.ReadVector(QString(PROPATH)+"/epsilon_mua/lambda.txt",_M_wavelength);
    _M_id_w = -1;

    //Info simulations
    _M_info_simus.nb_photons = 1e6;
    _M_info_simus.repetions = 1;
    _M_info_simus.unit_in_mm = 1;
    _M_info_simus.modelled_volume_cols = 1;
    _M_info_simus.modelled_volume_rows = 1;


    //extinction coefficent in (Mol.cm-1)

    _M_mua_eps_data_ready = _M_mua_eps_data_ready && _M_loadData.ReadVector(QString(PROPATH)+"/epsilon_mua/eps_HbO2.txt",_M_eps_HbO2);
    _M_mua_eps_data_ready = _M_mua_eps_data_ready && _M_loadData.ReadVector(QString(PROPATH)+"/epsilon_mua/eps_Hb.txt",_M_eps_Hb);
    _M_mua_eps_data_ready = _M_mua_eps_data_ready && _M_loadData.ReadVector(QString(PROPATH)+"/epsilon_mua/eps_oxCCO.txt",_M_eps_oxCCO);
    _M_mua_eps_data_ready = _M_mua_eps_data_ready && _M_loadData.ReadVector(QString(PROPATH)+"/epsilon_mua/eps_redCCO.txt",_M_eps_redCCO);

    //Aborption coefficient (in cm-1)
    _M_mua_eps_data_ready = _M_mua_eps_data_ready && _M_loadData.ReadVector(QString(PROPATH)+"/epsilon_mua/mua_Fat.txt",_M_mua_Fat);
    _M_mua_eps_data_ready = _M_mua_eps_data_ready && _M_loadData.ReadVector(QString(PROPATH)+"/epsilon_mua/mua_H2O.txt",_M_mua_H2O);

    qDebug()<<"Mua and eps data ready"<<_M_mua_eps_data_ready;


    //simulations
    _M_ppath = Mat::zeros(0,0,CV_32FC1);
    _M_p = Mat::zeros(0,0,CV_32FC1);

    //simulation dir
    _M_simu_dir = "";
    _M_optical_changes_dir = "";

    //Optical changes over time (size Nb of class; time)
    _M_mua = Mat::zeros(0,0,CV_32FC1);

    //Optical changes over time (size Nb of class; Nb of chromophores; time)
    _M_optical_changes.clear();

    // Name of the classes used in image recontruction
    _M_class_names.clear();
    _M_class_names.push_back("grey_matter");
    _M_class_names.push_back("large_blood_vessels");
    _M_class_names.push_back("capillaries");
    _M_class_names.push_back("activated_grey_matter");
    _M_class_names.push_back("activated_large_blood_vessels");
    _M_class_names.push_back("activated_capillaries");

    //Flag for controlling if process can be done
    _M_simu_data_ready = false;
    _M_optical_changes_data_ready = false;
}


/** request reconstruction */
void Data::Launch_reconstruction()
{
    //Get input image size
    _M_out_img_rows = floor(_M_info_simus.modelled_volume_rows/_M_binning);
    _M_out_img_cols = floor(_M_info_simus.modelled_volume_cols/_M_binning);

    qDebug()<<"out img size: "<<_M_out_img_rows<<" "<<_M_out_img_cols;


    //check size
    if(_M_out_img_rows<=0 || _M_out_img_cols<=0)
        return;

    //check if all data have been loaded
    if (_M_mua_eps_data_ready && _M_optical_changes_data_ready)
        this->start();
}



/** Call process in parallel thread */
void Data::run()
{
    QElapsedTimer timer;
    timer.start();
    //For loop over wavelengths
    for(int i=0;i<_M_wavelength_to_process.size();i++)
    {
        //Set wavelength
        _setWavelength(_M_wavelength_to_process[i]);

        //Check if wavelength is found
        if(_M_id_w==-1)
            break;

        //Calculate mua (size: (size Nb of class; time))
        qDebug()<<"Calculate mua";
        _M_mua = get_mua(_M_optical_changes,_M_mua_H2O[_M_id_w],_M_mua_Fat[_M_id_w],_M_eps_HbO2[_M_id_w],_M_eps_Hb[_M_id_w],_M_eps_oxCCO[_M_id_w],_M_eps_redCCO[_M_id_w]);

        cout<<_M_mua<<endl;

        //Load simulations
        qDebug()<<"Load simulations";
        _Load_Simulation_Data(_M_wavelength_to_process[i]);


        //Check if data have been correctly loaded
        int T = _M_mua.cols;

        if(_M_simu_data_ready)
        {
            //For loop over time
            qDebug()<<"Calculate mean path and diffuse reflectance";
            for(int t=0;t<T;t++)
                _Create_Diffuse_reflectance_Pathlength_Img(_M_mua.col(t),_M_wavelength_to_process[i]);

        }
    }

    emit processing("Process terminated in "+QString::number(timer.elapsed()/1000)+"s");

    qDebug()<<"Reconstruction time: "<<timer.elapsed()/1000<<"s";

}



void Data::_setWavelength(int w)
{
    // get wavelength index
    _M_id_w=-1;
    for(int i=0;i<_M_wavelength.size();i++)
    {
        if(int(_M_wavelength[i]) == w)
        {
            _M_id_w = i;
            break;
        }
    }

    //check if wavelength exists
    if(_M_id_w==-1)
        return;
}


/** Set optical changes directory */
void Data::setOpticalChangesDir(QString s)
{


    _M_optical_changes_dir = s;
    if(_M_optical_changes_dir == "")
        return;

    //init optical changes
    _M_optical_changes.clear();
    _M_optical_changes.resize(_M_class_names.size());

    //Loop over class
    _M_optical_changes_data_ready = true;
    for(int i=0;i<_M_class_names.size();i++)
    {
        // Array of size (6; time)
        // 0: fraction of Water in %
        // 1: fraction of Fat in %
        // 2: C_HbO2 in Mol
        // 3: C_Hb in Mol
        // 4: C_oxCCO in Mol
        // 5: C_redCCO in Mo
//        QVector<QVector<float> > temp;

        //Size(Chromophores, time)
        Mat temp;

        _M_optical_changes_data_ready = _M_optical_changes_data_ready && _M_loadData.ReadArray(_M_optical_changes_dir+"/"+_M_class_names[i]+".txt",temp);

        // Check data
        if (temp.empty())
        {
            _M_optical_changes_data_ready = false;
            break;
        }

        //Check if the vector contains 6 chromophores
        if(temp.rows!=6)
        {
            _M_optical_changes_data_ready = false;
            break;
        }

        _M_optical_changes[i] = temp;
    }

    qDebug()<<"Optical changes data ready"<<_M_optical_changes_data_ready;

}


/** Set simulation dir */
void Data::setSimulationDir(QString s)
{
    _M_simu_dir = s;

    //Load info
    //Info simulations
    _M_loadData.LoadInfoSimulation(s,_M_info_simus);

    qDebug()<<_M_info_simus.nb_photons;
    qDebug()<<_M_info_simus.repetions;
    qDebug()<<_M_info_simus.unit_in_mm;
    qDebug()<<_M_info_simus.modelled_volume_rows;
    qDebug()<<_M_info_simus.modelled_volume_cols;

    //Create directory for results
    _M_saving_dir  =_M_simu_dir+"/results/";
    QDir dir(_M_saving_dir);

    //Create saving dir
    if(!dir.exists())
        dir.mkdir(_M_saving_dir);


    //clear interface
    emit processing("Click on Reconstruct images");
}

void Data::_Load_Simulation_Data(int w)
{
    QElapsedTimer timer;
    timer.start();

    if(_M_simu_dir=="")
        return;

    qDebug()<<"Unzip files";
    _M_loadData.unzipFiles(_M_simu_dir+"/"+QString::number(w)+".zip",_M_simu_dir+"/"+QString::number(w));

    // Load partial path length (Size: detected photons, nb of class)
    _M_simu_data_ready = _M_loadData.ReadArray(_M_simu_dir+"/"+QString::number(w)+"/ppath_"+QString::number(w)+".txt",_M_ppath);


    // Load exiting photons (Size: detected photons, nb of class)
    _M_simu_data_ready = _M_simu_data_ready && _M_loadData.ReadArray(_M_simu_dir+"/"+QString::number(w)+"/p_"+QString::number(w)+".txt",_M_p);


    qDebug()<<"Remove temp files";
    _M_loadData.removeDirectoryRecursively(_M_simu_dir+"/"+QString::number(w));


    // Check data
    if(_M_p.empty())
        _M_simu_data_ready = false;

    if(_M_ppath.empty())
        _M_simu_data_ready = false;

    qDebug()<<"Load data: "<<timer.elapsed()/1000<<"s";
    qDebug()<<"ppath size: "<<_M_ppath.rows<<" "<<_M_ppath.cols;
    qDebug()<<"p size: "<<_M_p.rows<<" "<<_M_p.cols;
    qDebug()<<"Simulation data ready"<<_M_simu_data_ready;


}




void Data::_Create_Diffuse_reflectance_Pathlength_Img(const Mat &mua,int w)
{
    QElapsedTimer timer;
    timer.start();

    //Init mean path and diffuse reflectance img
    Mat mp = Mat::zeros(_M_out_img_rows,_M_out_img_cols,CV_32FC1);
    Mat dr = Mat::zeros(_M_out_img_rows,_M_out_img_cols,CV_32FC1);

    //Area of detector
    float area = pow(_M_binning*_M_info_simus.unit_in_mm,2);

    //sum of weights
    Mat sum_weights = Mat::zeros(mp.size(),CV_32FC1);


    //Loop over detected photons
    qDebug()<<"Compute mean path and diffuse reflectance";
    int Nb_photons = _M_ppath.rows;
    emit processing("Reconstruct images...");

//    #pragma omp parallel
//    {
////        int nb_thread = omp_get_num_threads();
//        #pragma omp for


        for(int i=0;i<Nb_photons;i++)
        {
            //Calculate weights
            double weight = 1;
            for(int n=0;n<mua.rows;n++)
                weight *= exp(-mua.at<float>(n,0)*_M_ppath.at<float>(i,n)*_M_info_simus.unit_in_mm);

             // get row and col index
            int row_id = ceil(_M_p.at<float>(i,0)/_M_binning) -1 ;
            int col_id = ceil(_M_p.at<float>(i,1)/_M_binning) -1 ;

            //Sum weights
            sum_weights.at<float>(row_id,col_id) += weight;

            //compute diffuse reflectance
            float temp = weight/(area*_M_info_simus.nb_photons*_M_info_simus.repetions);
            temp = (isnan(temp) || isinf(temp)) ? 0 : temp;

            dr.at<float>(row_id,col_id) += temp;

            //Compute mean path length
            temp = float(sum(_M_ppath.row(i)*_M_info_simus.unit_in_mm*weight)[0]);
            temp = (isnan(temp) || isinf(temp)) ? 0 : temp;

            mp.at<float>(row_id,col_id) += temp;

            //emit processing(100*i/(Nb_photons-1));
        }
//    }


    emit processing("Normalize outputs...");
    //normalize mean path length with the sum of the weights
    qDebug()<<"Normalize";
    #pragma omp parallel
    {
    //        int nb_thread = omp_get_num_threads();
        #pragma omp for
        for(int r=0;r<_M_out_img_rows;r++)
        {
            for(int c=0;c<_M_out_img_cols;c++)
                mp.at<float>(r,c) /= sum_weights.at<float>(r,c);
            //emit processing(100*(r)/(_M_out_img_rows-1));
        }
    }



    //Write output
    WriteFloatImg(_M_saving_dir+"/mp_"+QString::number(w)+"_binning_"+QString::number(_M_binning)+".txt",mp);
    WriteFloatImg(_M_saving_dir+"/dr_"+QString::number(w)+"_binning_"+QString::number(_M_binning)+".txt",dr);

    qDebug()<<"Compute diffuse reflectance and mean path length images: "<<timer.elapsed()/1000<<"s";

}
