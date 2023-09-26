#ifndef PROCESS_H
#define PROCESS_H

#include <QObject>
#include <QThread>
#include "functions.h"
#include "LoadData.h"
#include <QDir>

#include <omp.h>
#include <QProcess>

class Process : public QThread
{
    Q_OBJECT
public:
    explicit Process(QObject *parent = nullptr);

    /** Set simulation directory */
    void setSimulationDir(QString s);

    /** New lens design */
    void newLensSensorDesign(_lens_sensor &lens);

    /** set Wavelength to analyze */
    void setWavelength(int);



protected:
    /** Call process in parallel thread */
  void run();


signals:
    void processing(QString);


public slots:

    /** Binning of output images */
    void onBinningChanged(int v);


    /** Request lens modeling */
    void requestLensSensorModeling(bool v);

    /** Request processing on only one wavelength */
    void onrequestSingleLambda(bool v);

private slots:
    /** On data finished loaded */
    void on_ppath_data_Loaded(bool);
    void on_p_data_Loaded(bool);
    void on_v_data_Loaded(bool);


    /** on new wavelength processing requested */
    void onNewWavelengthProcessingRequested();


private:


    /** Reconstruction processing */
    bool _Process(int w);


    /** Display results */
    void _Display_Results();


      /** Set Wavelength (in nm) */
      void _setWavelength(int);

    /** Load data at selected wavelength */
    void _Load_Simulation_Data(int);

    /** Set optical changes directory */
    void _getOpticalChanges();

    /** Get epsilon and mua coefficients */
    void _get_mua_epsilon();





    /** calculate diffuse reflectance pathlength img */
    void _Create_Diffuse_reflectance_Pathlength_Img(const Mat &mua, int w);

    void _Create_Diffuse_reflectance_Pathlength_Img_With_Lens(const Mat &mua, int w);


    /** get output pos on sensor after lens */
    void _get_photon_pos_after_lens(Mat *p);

    //Wavelength to process
    QVector<float> _M_wavelength_to_process;
    int _M_id_wavelength_to_process;

    //Wavelength
    QVector<float> _M_wavelength;
    int _M_id_w;


    //extinction coefficent in (Mol.cm-1)
    QVector<float> _M_eps_HbO2;
    QVector<float> _M_eps_Hb;
    QVector<float> _M_eps_oxCCO;
    QVector<float> _M_eps_redCCO;



    //Aborption coefficient (in cm-1)
    QVector<float> _M_mua_Fat;
    QVector<float> _M_mua_H2O;




    //simulations (Size: detected photons, nb of class)
//    Mat _M_ppath;
//    Mat _M_p;
//    Mat _M_v;
    LoadData _M_ppath;
    LoadData _M_p;
    LoadData _M_v;



    //Simulation directory
    QString _M_simu_dir;


    //Optical changes over time (size Nb of class; Nb of chromophores; time)
//    QVector<QVector<QVector<float> > > _M_optical_changes;

    //Optical changes over time (QVector size Nb of class; Mat size: size Nb of chromophores; time)
    QVector<Mat> _M_optical_changes;

    //Name of the classes
    QStringList _M_class_names;



    //Flag for controlling if process can be done
    bool _M_simu_data_ready;
    bool _M_optical_changes_data_ready;
    bool _M_mua_eps_data_ready;


    //Binning for reconstuction the images
    int _M_binning;

    //info simulation
    _info_simulations _M_info_simus;

    //Load data class
    LoadData        _M_loadData;

    //Saving directory
    QString         _M_saving_dir;

    //Study only one wavelength
    bool            _M_study_one_lambda;


    //Lens and camera modeling
    bool            _M_model_lens_sensor;
    _lens_sensor    _M_lens_sensor;


};

#endif // PROCESS_H
