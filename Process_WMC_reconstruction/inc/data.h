#ifndef DATA_H
#define DATA_H

#include <QObject>
#include <QThread>
#include "functions.h"
#include "LoadData.h"
#include <QDir>

#include <omp.h>

class Data : public QThread
{
    Q_OBJECT
public:
    explicit Data(QObject *parent = nullptr);



    /** Set simulation directory */
    void setSimulationDir(QString s);

    /** Set optical changes directory */
    void setOpticalChangesDir(QString s);

    /** Launch reconstruction */
    void Launch_reconstruction();

protected:
    /** Call process in parallel thread */
  void run();


signals:
    void processing(QString);




private:

      /** Set Wavelength (in nm) */
      void _setWavelength(int);

    /** Load data at selected wavelength */
    void _Load_Simulation_Data(int);


    /** calculate diffuse reflectance pathlength img */
    void _Create_Diffuse_reflectance_Pathlength_Img(const Mat &mua, int w);


    //Wavelength to process
    QVector<float> _M_wavelength_to_process;



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
    Mat _M_ppath;
    Mat _M_p;

    //Simulation directory
    QString _M_simu_dir;
    QString _M_optical_changes_dir;

    //Absorption changes over time (size Nb of class; time)
    //QVector<QVector<float> > _M_mua;
    Mat _M_mua; // in mm-1

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
    //output image rows
    int _M_out_img_rows;
    //output image cols
    int _M_out_img_cols;



    //info simulation
    _info_simulations _M_info_simus;

    //Load data class
    LoadData        _M_loadData;

    //Saving directory
    QString         _M_saving_dir;


};

#endif // DATA_H
