#include "process.h"


////////////////////////////////////////////// A FAIRE ////////////////////////////////////
// Lire les fichiers texte p.txt et ppath.txt en parallele
//Optimise image reconstruction
// Read available wavelengths in directory

Process::Process(QObject *parent)
    : QThread{parent}
{
    //Send processing info
    connect(&_M_loadData,SIGNAL(loading_progess(QString)),this,SIGNAL(processing(QString)));

    //Data ready for processing
    connect(&_M_ppath,SIGNAL(data_Loaded(bool)),this,SLOT(on_ppath_data_Loaded(bool)));
    connect(&_M_p,SIGNAL(data_Loaded(bool)),this,SLOT(on_p_data_Loaded(bool)));
    connect(&_M_v,SIGNAL(data_Loaded(bool)),this,SLOT(on_v_data_Loaded(bool)));

    //request new processing
    connect(this,SIGNAL(finished()),this,SLOT(onNewWavelengthProcessingRequested()));


    //Lens and camera modeling
    _M_model_lens_sensor = false;
    _M_lens_sensor.f0_mm = 30;
    _M_lens_sensor.working_distance_mm = 400;
    _M_lens_sensor.distance_to_sensor = 0;
    _M_lens_sensor.transfer_Matrix = Mat::zeros(0,0,CV_32FC1);

    _M_lens_sensor.y_sensor_mm =6;
    _M_lens_sensor.x_sensor_mm =_M_lens_sensor.y_sensor_mm*0.8;

    _M_lens_sensor.y_sensor_px = 100;
//    _M_lens_sensor.x_sensor_px = floor(_M_lens_sensor.y_sensor_px*(_M_lens_sensor.x_sensor_mm/_M_lens_sensor.y_sensor_mm));
    _M_lens_sensor.x_sensor_px = floor(_M_lens_sensor.y_sensor_px*0.8);

    _M_lens_sensor.sensor_reso_x = _M_lens_sensor.x_sensor_mm/_M_lens_sensor.x_sensor_px;
    _M_lens_sensor.sensor_reso_y = _M_lens_sensor.y_sensor_mm/_M_lens_sensor.y_sensor_px;

    //Compute transfer matrix
    getTransferMatrix(_M_lens_sensor);



    //Wavelenfth to process
    _M_wavelength_to_process.clear();
    for(int i=400;i<1010;i+=10)
        _M_wavelength_to_process.push_back(i);


    // Study one lambda
    _M_study_one_lambda = true;
    _M_id_wavelength_to_process = 0;

    //Saving dir
    _M_saving_dir = "";


    //Binning for reconstuction the images
    _M_binning = 1;


    //Wavelength idx
    _M_id_w = -1;

    //Info simulations
    _M_info_simus.nb_photons = 1e6;
    _M_info_simus.repetions = 1;
    _M_info_simus.unit_in_mm = 1;
    _M_info_simus.modelled_volume_cols = 1;
    _M_info_simus.modelled_volume_rows = 1;


//    //simulations
//    _M_ppath = Mat::zeros(0,0,CV_32FC1);
//    _M_p = Mat::zeros(0,0,CV_32FC1);
//    _M_v = Mat::zeros(0,0,CV_32FC1);


    //simulation dir
    _M_simu_dir = "";

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



    //get mua and epsilon coefficient
    qDebug()<<"Read epsilon";
    _get_mua_epsilon();

}


// SLOT called when the reconstruction process finished
void Process::onNewWavelengthProcessingRequested()
{
    if(!_M_simu_data_ready)
        return;

    if(_M_study_one_lambda)
        return;

    if(_M_id_wavelength_to_process+1>=_M_wavelength_to_process.size())
        return;

    _M_id_wavelength_to_process++;
    _Load_Simulation_Data(_M_wavelength_to_process[_M_id_wavelength_to_process]);
}


/** On ppath data finished loaded
 *  SLOT called when data finished loaded. Once data is loaded start reconstruction */
void Process::on_ppath_data_Loaded(bool v)
{
    if(!v)
    {
        qDebug()<<"ppath file not loaded ";
        _M_simu_data_ready = false;
        return;
    }

    if(_M_ppath.getDataStatus() && _M_p.getDataStatus() && _M_v.getDataStatus())
    {
        _M_simu_data_ready = true;

        qDebug()<<"Remove temp files";
        emit processing("Remove temp files "+QString::number(_M_wavelength_to_process[_M_id_wavelength_to_process])+"nm");
        _M_loadData.removeDirectoryRecursively(_M_simu_dir+"/"+QString::number(_M_wavelength_to_process[_M_id_wavelength_to_process]));

        this->start();
    }
}

/** On exiting photons positions finished loaded */
void Process::on_p_data_Loaded(bool v)
{
    if(!v)
    {
        qDebug()<<"p file not loaded ";
        _M_simu_data_ready = false;
        return;
    }

    if(_M_ppath.getDataStatus() && _M_p.getDataStatus() && _M_v.getDataStatus())
    {
        _M_simu_data_ready = true;

        qDebug()<<"Remove temp files";
        _M_loadData.removeDirectoryRecursively(_M_simu_dir+"/"+QString::number(_M_wavelength_to_process[_M_id_wavelength_to_process]));

        this->start();
    }
}

/** On exiting photons angles finished loaded */
void Process::on_v_data_Loaded(bool v)
{
    if(!v)
    {
        qDebug()<<"v file not loaded ";
        _M_simu_data_ready = false;
        return;
    }

    if(_M_ppath.getDataStatus() && _M_p.getDataStatus() && _M_v.getDataStatus())
    {
        _M_simu_data_ready = true;

        qDebug()<<"Remove temp files";
        _M_loadData.removeDirectoryRecursively(_M_simu_dir+"/"+QString::number(_M_wavelength_to_process[_M_id_wavelength_to_process]));

        this->start();
    }
}

/** Display results */
void Process::_Display_Results()
{
    //Launch Python script: Launch Neural network
    QProcess p;
    p.setWorkingDirectory(QString(PROPATH)+"/python");
    QStringList params;
    params << "display.py";
    p.start("python", params);
    p.waitForFinished(-1);

    //remove txt files
    QFile file(QString(PROPATH)+"/python/mp.txt");
    if(file.exists())
        file.remove();
    file.setFileName(QString(PROPATH)+"/python/dr.txt");
    if(file.exists())
        file.remove();

}



/** Call process in parallel thread */
void Process::run()
{
    emit processing("Process data "+QString::number(_M_wavelength_to_process[_M_id_wavelength_to_process])+"nm");
    bool res = _Process(_M_wavelength_to_process[_M_id_wavelength_to_process]);


    if(_M_study_one_lambda && res)
        _Display_Results();
}

/** Reconstruction processing
 *  @param w: Wavelength to process (in nm) */
bool Process::_Process(int w)
{
    QElapsedTimer timer;
    timer.start();

    //Check if data is ready
    if(!_M_mua_eps_data_ready)
    {
        qDebug()<<"mua epsilon data not laoded";
        return false;
    }
    if(!_M_optical_changes_data_ready)
    {
        qDebug()<<"Optical changes data not laoded";
        return false;
    }
    if(!_M_simu_data_ready)
    {
        qDebug()<<"Optical changes data not laoded";
        return false;
    }

    qDebug()<<"process "<<w;

    //Set wavelength
    _setWavelength(w);

    //Check if wavelength is found
    if(_M_id_w==-1)
        return false;

    //Calculate mua (size: (size Nb of class; time)) in mm-1
    Mat mua = get_mua(_M_optical_changes,_M_mua_H2O[_M_id_w],_M_mua_Fat[_M_id_w],_M_eps_HbO2[_M_id_w],_M_eps_Hb[_M_id_w],_M_eps_oxCCO[_M_id_w],_M_eps_redCCO[_M_id_w]);


    //Check if data have been correctly loaded
    int T = mua.cols;

    //For loop over time
    #pragma omp parallel
    {
//        int nb_thread = omp_get_num_threads();
        #pragma omp for
        for(int t=0;t<T;t++)
            _Create_Diffuse_reflectance_Pathlength_Img(mua.col(t),w,t);
    }

    emit processing("Process terminated in "+QString::number(timer.elapsed()/1000)+"s");

    qDebug()<<"Reconstruction time: "<<timer.elapsed()/1000<<"s";

    return true;
}


/** set Wavelength to analyze
 *  @param w wavelength that is required to be anlyzed (in nm) */
void Process::setWavelength(int w)
{
    for(int i=0;i<_M_wavelength_to_process.size();i++)
    {
        if(int(_M_wavelength_to_process[i]) == w)
        {
            _M_id_wavelength_to_process = i;
            break;
        }
    }

    this->start();
}

/** Set wavelength range (for multi wavelength reconstruction)
 *  within the range [start:stop] by steps of step. */
void Process::setWavelengthRange(int start,int end, int step)
{
    _M_wavelength_to_process.clear();
    for(int i=start;i<end+step;i+=step)
        _M_wavelength_to_process.push_back(i);
}



/** Set Wavelength (in nm) */
void Process::_setWavelength(int w)
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


/** Read optical changes */
void Process::ReadOpticalChanges(QString dir)
{
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
        // 5: C_redCCO in Mol
//        QVector<QVector<float> > temp;

        //Size(Chromophores, time)
        Mat temp;

//        _M_optical_changes_data_ready = _M_optical_changes_data_ready && _M_loadData.ReadArray(QString(PROPATH)+"/optical_changes/"+_M_class_names[i]+".txt",temp);
        _M_optical_changes_data_ready = _M_optical_changes_data_ready && _M_loadData.ReadArray(dir+"/"+_M_class_names[i]+".txt",temp);

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


/** Get epsilon and mua coefficients */
void Process::_get_mua_epsilon()
{
    //Wavelength
    _M_mua_eps_data_ready = _M_loadData.ReadVector(QString(PROPATH)+"/../spectra/lambda.txt",_M_wavelength);

    //extinction coefficent in (Mol.cm-1)
    _M_mua_eps_data_ready = _M_mua_eps_data_ready && _M_loadData.ReadVector(QString(PROPATH)+"/../spectra/eps_HbO2.txt",_M_eps_HbO2);
    _M_mua_eps_data_ready = _M_mua_eps_data_ready && _M_loadData.ReadVector(QString(PROPATH)+"/../spectra/eps_Hb.txt",_M_eps_Hb);
    _M_mua_eps_data_ready = _M_mua_eps_data_ready && _M_loadData.ReadVector(QString(PROPATH)+"/../spectra/eps_oxCCO.txt",_M_eps_oxCCO);
    _M_mua_eps_data_ready = _M_mua_eps_data_ready && _M_loadData.ReadVector(QString(PROPATH)+"/../spectra/eps_redCCO.txt",_M_eps_redCCO);

    //Aborption coefficient (in cm-1)
    _M_mua_eps_data_ready = _M_mua_eps_data_ready && _M_loadData.ReadVector(QString(PROPATH)+"/../spectra/mua_Fat.txt",_M_mua_Fat);
    _M_mua_eps_data_ready = _M_mua_eps_data_ready && _M_loadData.ReadVector(QString(PROPATH)+"/../spectra/mua_H2O.txt",_M_mua_H2O);


    qDebug()<<"Mua and eps data ready"<<_M_mua_eps_data_ready;
}
/** Set simulation directory
 *  @param s directory that contains the simulation files */
void Process::setSimulationDir(QString s)
{


    qDebug()<<"Read simulation info";
    _M_simu_dir = s;

    //Load info
    //Info simulations
    _M_loadData.LoadInfoSimulation(s,_M_info_simus);

//    qDebug()<<_M_info_simus.nb_photons;
//    qDebug()<<_M_info_simus.repetions;
//    qDebug()<<_M_info_simus.unit_in_mm;
//    qDebug()<<_M_info_simus.modelled_volume_rows;
//    qDebug()<<_M_info_simus.modelled_volume_cols;

    //Create directory for results
    _M_saving_dir  =_M_simu_dir+"/results/";
    QDir dir(_M_saving_dir);

    //Create saving dir
    if(!dir.exists())
        dir.mkdir(_M_saving_dir);

//    this->start();
    if(_M_optical_changes_data_ready && _M_mua_eps_data_ready)
        _Load_Simulation_Data(_M_wavelength_to_process[_M_id_wavelength_to_process]);

}

/** Load data at selected wavelength */
void Process::_Load_Simulation_Data(int w)
{

    qDebug()<<"Load data";
    QElapsedTimer timer;
    timer.start();



    if(_M_simu_dir=="")
        return;

    qDebug()<<"Unzip files";
    emit processing("Unzip files "+QString::number(_M_wavelength_to_process[_M_id_wavelength_to_process])+"nm");
    _M_loadData.unzipFiles(_M_simu_dir+"/"+QString::number(w)+".zip",_M_simu_dir+"/"+QString::number(w));


    qDebug()<<"Load files";

    emit processing("Read data "+QString::number(_M_wavelength_to_process[_M_id_wavelength_to_process])+"nm");
    // Load partial path length (Size: detected photons, nb of class)
    _M_ppath.ReadArray(_M_simu_dir+"/"+QString::number(w)+"/ppath_"+QString::number(w)+".txt");
    // Load exiting photon positions (Size: detected photons, nb of class)
    _M_p.ReadArray(_M_simu_dir+"/"+QString::number(w)+"/p_"+QString::number(w)+".txt");
    // Load exiting photon angles (Size: detected photons, nb of class)
    _M_v.ReadArray(_M_simu_dir+"/"+QString::number(w)+"/v_"+QString::number(w)+".txt");
}

/** Binning of output images */

void Process::onBinningChanged(int v)
{
    _M_binning = v;
    this->start();
}

/** Request processing on only one wavelength */
void Process::onrequestSingleLambda(bool v)
{
    _M_study_one_lambda = v;
    this->start();
}

/** Request lens modeling */
void Process::requestLensSensorModeling(bool v)
{
    _M_model_lens_sensor = v;
    if(!_M_lens_sensor.transfer_Matrix.empty() && _M_model_lens_sensor)
        this->start();
}

/** New lens design defined for the GUI
 *  @param lens structure that contains the optics device definition */
void Process::newLensSensorDesign(_lens_sensor &lens)
{
    //Lens
    _M_lens_sensor.working_distance_mm = lens.working_distance_mm;
    _M_lens_sensor.f0_mm = lens.f0_mm;
    getTransferMatrix(_M_lens_sensor);

    cout<<_M_lens_sensor.transfer_Matrix<<endl;

    //Sensor
//    _M_lens_sensor.y_sensor_px = floor(_M_lens_sensor.y_sensor_px/_M_binning)+1;
//    _M_lens_sensor.x_sensor_px = floor(_M_lens_sensor.x_sensor_px/_M_binning)+1;

    _M_lens_sensor.x_sensor_mm = lens.x_sensor_mm;
    _M_lens_sensor.y_sensor_mm = lens.y_sensor_mm;

    _M_lens_sensor.y_sensor_px = lens.y_sensor_px;
    _M_lens_sensor.x_sensor_px = lens.x_sensor_px;

    _M_lens_sensor.sensor_reso_x = lens.x_sensor_mm/lens.x_sensor_px;
    _M_lens_sensor.sensor_reso_y = lens.y_sensor_mm/lens.y_sensor_px;


    if(!_M_lens_sensor.transfer_Matrix.empty() && _M_model_lens_sensor)
        this->start();
}


/** calculate diffuse reflectance pathlength img without lens and sensor optics.
 *  Images are reconstructed at the tissue surface
 *  @param mua matrix of absorption changes (in mm-1). Size: number of class x time
 *  @param w wavelength (in nm) */
void Process::_Create_Diffuse_reflectance_Pathlength_Img(const Mat &mua,int w,int t)
{
//    QElapsedTimer timer;
//    timer.start();

    //outputs
    Mat mp,dr;

    float reso_x,reso_y;
    QString name="";
    QString name_info="";



    if(!_M_lens_sensor.transfer_Matrix.empty() && _M_model_lens_sensor)
    {
        name = "sensor_"+QString::number(_M_lens_sensor.y_sensor_mm)+"_"+QString::number(_M_lens_sensor.x_sensor_mm)+"mm"+QString::number(w)+"_t_"+QString::number(t)+".txt";;

        //Get position on sensor after lens
        Mat *p = new Mat(*_M_p.getData());

        qDebug()<<"get photon pos on sensor after lens";
        _get_photon_pos_after_lens(p);

        //Area of detector
        reso_x = _M_lens_sensor.sensor_reso_x;
        reso_y = _M_lens_sensor.sensor_reso_y;
        float area = reso_x*reso_y;

        get_Diffuse_reflectance_Pathlength(1,_M_info_simus.nb_photons,_M_info_simus.repetions,mua, _M_lens_sensor.x_sensor_px, _M_lens_sensor.y_sensor_px,
                                           area,_M_info_simus.unit_in_mm,_M_ppath.getData(), p, dr, mp);
    }
    else
    {
        //name output file
        name = "surface_"+QString::number(w)+"_binning_"+QString::number(_M_binning)+"_t_"+QString::number(t)+".txt";

        //Area of detector
        reso_x = _M_binning*_M_info_simus.unit_in_mm;
        reso_y = _M_binning*_M_info_simus.unit_in_mm;
        float area = reso_x*reso_y;

        //Define output image size
        int out_img_rows = floor(_M_info_simus.modelled_volume_rows/_M_binning)+1;
        int out_img_cols = floor(_M_info_simus.modelled_volume_cols/_M_binning)+1;

        get_Diffuse_reflectance_Pathlength(_M_binning,_M_info_simus.nb_photons,_M_info_simus.repetions,mua, out_img_rows, out_img_cols,
                                           area,_M_info_simus.unit_in_mm,_M_ppath.getData(), _M_p.getData(), dr, mp);
    }



//    qDebug()<<"Write images";
    WriteFloatImg(_M_saving_dir+"/mp_"+name,mp);
    WriteFloatImg(_M_saving_dir+"/dr_"+name,dr);

    //Write info
    QFile file(_M_saving_dir+"/info_out_"+name_info+".txt");
    if(!file.exists())
    {
        file.close();
        QVector<QString> info;
        info.push_back("reso x (mm): "+QString::number(reso_x));
        info.push_back("reso y (mm): "+QString::number(reso_y));
        if(_M_model_lens_sensor)
        {
            info.push_back("focal length (mm): "+QString::number(_M_lens_sensor.f0_mm));
            info.push_back("working distance (mm): "+QString::number(_M_lens_sensor.working_distance_mm));
        }

        WriteInfo(_M_saving_dir+"/info_out_"+name_info+".txt",info);
    }


    //Write output
    if(_M_study_one_lambda)
    {
        //Write for display
        WriteFloatImg(QString(PROPATH)+"/python/mp.txt",mp);
        WriteFloatImg(QString(PROPATH)+"/python/dr.txt",dr);
    }


//    qDebug()<<"Compute diffuse reflectance and mean path length images: "<<timer.elapsed()/1000<<"s";

}


/** get output pos on sensor after lens
 *  @param[out] p pointer on matrix that contanins the position of exiting photons after the lens */
void Process::_get_photon_pos_after_lens(Mat *p)
{

    //p = new Mat(*_M_p.getData());
    Mat *v = _M_v.getData();

    //nb photon
    int nb_photons = p->rows;

    //Concatenate pos and angle
    Mat x_pos_angle = Mat::zeros(2,nb_photons,CV_32FC1);
    Mat y_pos_angle = Mat::zeros(2,nb_photons,CV_32FC1);


    //Calculate angles in radian
    #pragma omp parallel
    {
//        int nb_thread = omp_get_num_threads();
        #pragma omp for
        for(int c=0;c<nb_photons;c++)
        {
            //positions
            // *_M_info_simus.unit_in_mm
            // Convert the position of exiting photons in mm

            // *(-1)
            // Rotation around y axis (to simulate the light propagation, z+ axis was
            //from the light to the tissue. We want the opposite so we apply the
            //rotation matrix of 180 degrees around y axis.

            // -_M_info_simus.modelled_volume_rows/2 and -_M_info_simus.modelled_volume_cols/2
            // Change the coordinate (set the optical axis at the center of the surface)
            x_pos_angle.at<float>(0,c) = -(p->at<float>(c,0)-_M_info_simus.modelled_volume_rows/2)*_M_info_simus.unit_in_mm; //multiply by -1 for the rotation
            y_pos_angle.at<float>(0,c) = (p->at<float>(c,1)-_M_info_simus.modelled_volume_cols/2)*_M_info_simus.unit_in_mm;

            //angle
            x_pos_angle.at<float>(1,c) = -asin((*v).at<float>(c,0)); //multiply by -1 for the rotation
            y_pos_angle.at<float>(1,c) = asin((*v).at<float>(c,1));
        }
    }




    //Apply transfer matrix
    x_pos_angle = _M_lens_sensor.transfer_Matrix*x_pos_angle;
    y_pos_angle = _M_lens_sensor.transfer_Matrix*y_pos_angle;

    //get output position in sensor (in mm)
    delete p;
    p = new Mat(Mat::zeros(nb_photons,2,CV_32FC1));
    transpose(x_pos_angle.row(0),p->col(0));
    transpose(y_pos_angle.row(0),p->col(1));

    //Convert positions in pixels
    p->col(0) /= _M_lens_sensor.sensor_reso_x;
    p->col(1) /= -_M_lens_sensor.sensor_reso_y; //-1 for rotation


    //Get back in mcx space (space ordinate at at a corner no at the center of the surface)
    p->col(0) += _M_lens_sensor.x_sensor_px/2;
    p->col(1) += _M_lens_sensor.y_sensor_px/2;




//    qDebug()<<"Input p(x,y): "<<_M_p.at<float>(0,0)<<" "<<_M_p.at<float>(0,1);
//    qDebug()<<"Output p(x,y): "<<p.at<float>(0,0)<<" "<<p.at<float>(0,1);


//    //Concatenate pos and angle
//    //Use asin() for angle to get radians
//    Mat x_pos_angle = (Mat_<float>(2,1) << _M_p.at<float>(i,0), asin(_M_v.at<float>(i,0)));
//    Mat y_pos_angle = (Mat_<float>(2,1) << _M_p.at<float>(i,1), asin(_M_v.at<float>(i,1)));


//    //Change the coordinate (set the optical axis at the center of the surface)
//    x_pos_angle.at<float>(0,0) -= _M_info_simus.modelled_volume_rows/2;
//    y_pos_angle.at<float>(0,0) -= _M_info_simus.modelled_volume_cols/2;


//    //Rotation around y axis (to simulate the light propagation, z+ axis was
//    //from the light to the tissue. We want the opposite so we apply the
//    //rotation matrix of 180 degrees around y axis.
//    x_pos_angle = -x_pos_angle;

//    // Convert the position of exiting photons in mm
//    // not required for angles
//    x_pos_angle.at<float>(0,0) *= _M_info_simus.unit_in_mm;
//    y_pos_angle.at<float>(0,0) *= _M_info_simus.unit_in_mm;


//    //Apply transfer matrix
//    x_pos_angle = _M_lens_sensor.transfer_Matrix*x_pos_angle;
//    y_pos_angle = _M_lens_sensor.transfer_Matrix*y_pos_angle;


//    //get output position in sensor (in mm)
//    float x = x_pos_angle.at<float>(0,0);
//    float y = y_pos_angle.at<float>(0,0);

//    //Convert positions in pixels
//    x /= _M_lens_sensor.sensor_reso_x;
//    y /= _M_lens_sensor.sensor_reso_y;

//    //Rotation around y axis of 180 degrees (back in the mcx space)
//    //x = -x;
//    y = -y;

//    //Get back in mcx space (space ordinate at at a corner no at the center of the surface)
//    x += _M_lens_sensor.x_sensor_px/2;
//    y += _M_lens_sensor.y_sensor_px/2;
}


/*
void Process::_Create_Diffuse_reflectance_Pathlength_Img_With_Lens(const Mat &mua,int w)
{
    QElapsedTimer timer;
    timer.start();



    //Init mean path and diffuse reflectance img
    Mat mp = Mat::zeros(_M_lens_sensor.x_sensor_px,_M_lens_sensor.y_sensor_px,CV_32FC1);
    Mat dr = Mat::zeros(_M_lens_sensor.x_sensor_px,_M_lens_sensor.y_sensor_px,CV_32FC1);

    //Area of detector
    float area = _M_lens_sensor.sensor_reso_x*_M_lens_sensor.sensor_reso_y;

    //sum of weights
    Mat sum_weights = Mat::zeros(mp.size(),CV_32FC1);

    qDebug()<<"Size output: "<<mp.rows<<" "<<mp.cols;
    qDebug()<<"Area detector: "<<area;

    //Loop over detected photons
    qDebug()<<"Compute mean path and diffuse reflectance with Lens";
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

            if(weight == 0 || isnan(weight) || isinf(weight))
                    qDebug()<<weight;
//            weight = (isnan(weight) || isinf(weight))? 0 : weight;


            //Concatenate pos and angle
            //Use asin() for angle to get radians
            Mat x_pos_angle = (Mat_<float>(2,1) << _M_p.at<float>(i,0), asin(_M_v.at<float>(i,0)));
            Mat y_pos_angle = (Mat_<float>(2,1) << _M_p.at<float>(i,1), asin(_M_v.at<float>(i,1)));


            //Change the coordinate (set the optical axis at the center of the surface)
            x_pos_angle.at<float>(0,0) -= _M_info_simus.modelled_volume_rows/2;
            y_pos_angle.at<float>(0,0) -= _M_info_simus.modelled_volume_cols/2;


            //Rotation around y axis (to simulate the light propagation, z+ axis was
            //from the light to the tissue. We want the opposite so we apply the
            //rotation matrix of 180 degrees around y axis.
            x_pos_angle = -x_pos_angle;

            // Convert the position of exiting photons in mm
            // not required for angles
            x_pos_angle.at<float>(0,0) *= _M_info_simus.unit_in_mm;
            y_pos_angle.at<float>(0,0) *= _M_info_simus.unit_in_mm;


            //Apply transfer matrix
            x_pos_angle = _M_lens_sensor.transfer_Matrix*x_pos_angle;
            y_pos_angle = _M_lens_sensor.transfer_Matrix*y_pos_angle;


            //get output position in sensor (in mm)
            float x = x_pos_angle.at<float>(0,0);
            float y = y_pos_angle.at<float>(0,0);

            //Convert positions in pixels
            x /= _M_lens_sensor.sensor_reso_x;
            y /= _M_lens_sensor.sensor_reso_y;

            //Rotation around y axis of 180 degrees (back in the mcx space)
            //x = -x;
            y = -y;

            //Get back in mcx space (space ordinate at at a corner no at the center of the surface)
            x += _M_lens_sensor.x_sensor_px/2;
            y += _M_lens_sensor.y_sensor_px/2;


             // get row and col index (binning is already take into account when defining lens and sensor)
            int row_id = floor(x)  ;
            int col_id = floor(y)  ;

            // if photon does not reach the sensor continue the for loop
            if(row_id<0 || col_id<0 || row_id>= _M_lens_sensor.x_sensor_px || col_id >= _M_lens_sensor.y_sensor_px)
                continue;

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

        qDebug()<<"finish";


    emit processing("Normalize outputs...");
    //normalize mean path length with the sum of the weights
    qDebug()<<"Normalize";
    //#pragma omp parallel
    {
    //        int nb_thread = omp_get_num_threads();
        //#pragma omp for
        for(int r=0;r<mp.rows;r++)
        {
            for(int c=0;c<dr.rows;c++)
            {
                if(sum_weights.at<float>(r,c) == 0 || isnan(sum_weights.at<float>(r,c)) || isinf(sum_weights.at<float>(r,c)))
                {
                    qDebug()<<sum_weights.at<float>(r,c);
                    continue;
                }

                mp.at<float>(r,c) /= sum_weights.at<float>(r,c);
            }
        }
    }


    //Remove first, last columns and rows
    Rect rect(1,1,mp.cols-2,mp.rows-2);



    //Write output
    qDebug()<<"Write images";
    WriteFloatImg(_M_saving_dir+"/mp_"+QString::number(w)+"_binning_"+QString::number(_M_binning)+".txt",mp(rect));
    WriteFloatImg(_M_saving_dir+"/dr_"+QString::number(w)+"_binning_"+QString::number(_M_binning)+".txt",dr(rect));
    //WriteFloatImg(_M_saving_dir+"/w_"+QString::number(w)+"_binning_"+QString::number(_M_binning)+".txt",sum_weights(rect));

    //Write for display
    WriteFloatImg(QString(PROPATH)+"/python/mp.txt",mp(rect));
    WriteFloatImg(QString(PROPATH)+"/python/dr.txt",dr(rect));

    qDebug()<<"Compute diffuse reflectance and mean path length images: "<<timer.elapsed()/1000<<"s";

}
*/
