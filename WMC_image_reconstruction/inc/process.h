/**
 * @file process.h
 *
 * @brief This class is used to reconstruct images of diffuse reflectance and mean path length.
 * Images can be reconstructed at the surface of the tissue or on a sensor used a lens.
 * @author Charly Caredda
 * Contact: caredda.c@gmail.com
 */

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
    /** Constructor of the class */
    explicit Process(QObject *parent = nullptr);

    /** Set simulation directory
     *  @param s directory that contains the simulation files */
    void setSimulationDir(QString s);

    /** New lens design defined for the GUI
     *  @param lens structure that contains the optics device definition */
    void newLensSensorDesign(_lens_sensor &lens);

    /** set Wavelength to analyze
     *  @param w wavelength that is required to be anlyzed (in nm) */
    void setWavelength(int w);

    /** Set wavelength range (for multi wavelength reconstruction)
     *  within the range [start:stop] by steps of step. */
    void setWavelengthRange(int start,int end, int step);

    /** Read optical changes */
    void ReadOpticalChanges(QString dir);


protected:
    /** Call process in parallel thread */
  void run();


signals:
  /** Emit signal to infotm the GUI the processing status
   *  @param msg string that contains the status */
    void processing(QString msg);


public slots:

    /** Binning of output images */
    void onBinningChanged(int v);


    /** Request lens modeling */
    void requestLensSensorModeling(bool v);

    /** Request processing on only one wavelength */
    void onrequestSingleLambda(bool v);

private slots:
    /** On ppath data finished loaded
     *  SLOT called when data finished loaded. Once data is loaded start reconstruction */
    void on_ppath_data_Loaded(bool);

    /** On exiting photons positions finished loaded
     *  SLOT called when data finished loaded. Once data is loaded start reconstruction */
    void on_p_data_Loaded(bool);

     /** On exiting photons angles finished loaded
      *  SLOT called when data finished loaded. Once data is loaded start reconstruction */
    void on_v_data_Loaded(bool);


    /** on new wavelength processing requested */
    void onNewWavelengthProcessingRequested();


private:


    /** Reconstruction processing
     *  @param w: Wavelength to process (in nm) */
    bool _Process(int w);


    /** Display results */
    void _Display_Results();


      /** Set Wavelength (in nm) */
      void _setWavelength(int w);

    /** Load data at selected wavelength */
    void _Load_Simulation_Data(int w);

    /** Get epsilon and mua coefficients */
    void _get_mua_epsilon();





    /** calculate diffuse reflectance pathlength img without lens and sensor optics.
     *  Images are reconstructed at the tissue surface
     *  @param mua matrix of absorption changes (in mm-1). Size: number of class x time
     *  @param w wavelength (in nm)
     *  @param t temporal index */
    void _Create_Diffuse_reflectance_Pathlength_Img(const Mat &mua, int w, int t);

    /** calculate diffuse reflectance pathlength img with lens and sensor modelling.
     *  @param mua matrix of absorption changes (in mm-1). Size: number of class x time
     *  @param w wavelength (in nm) */
    void _Create_Diffuse_reflectance_Pathlength_Img_With_Lens(const Mat &mua, int w);


    /** get output pos on sensor after lens
     *  @param[out] p pointer on matrix that contanins the position of exiting photons after the lens */
    void _get_photon_pos_after_lens(Mat *p);

    /** Wavelength for which simulations have been done (in nm) */
    QVector<float> _M_wavelength_to_process;

    /** Id of the wavelength for which simulations have been done */
    int _M_id_wavelength_to_process;

    /** Wavelength that can be used to define mua coefficients (in nm) */
    QVector<float> _M_wavelength;
    /**  Id of the wavelength that can be used to define mua coefficients (in nm) */
    int _M_id_w;


    /** Molar extinction coefficent of HbO2 in (mol-1.L.cm-1) */
    QVector<float> _M_eps_HbO2;

    /** Molar extinction coefficent of Hb in (mol-1.L.cm-1) */
    QVector<float> _M_eps_Hb;

    /** Molar extinction coefficent of oxCCO in (mol-1.L.cm-1) */
    QVector<float> _M_eps_oxCCO;

    /** Molar extinction coefficent of redCO in (mol-1.L.cm-1) */
    QVector<float> _M_eps_redCCO;

    /** Molar extinction coefficent of oxCytc in (mol-1.L.cm-1) */
    QVector<float> _M_eps_oxCytc;

    /** Molar extinction coefficent of redCytc in (mol-1.L.cm-1) */
    QVector<float> _M_eps_redCytc;

    /** Molar extinction coefficent of oxCytb in (mol-1.L.cm-1) */
    QVector<float> _M_eps_oxCytb;

    /** Molar extinction coefficent of redCytb in (mol-1.L.cm-1) */
    QVector<float> _M_eps_redCytb;

    /** Aborption coefficient of Fat (in cm-1) */
    QVector<float> _M_mua_Fat;

    /** Aborption coefficient of Water (in cm-1) */
    QVector<float> _M_mua_H2O;




    /** Class used to read and sotre partial path length data */
    LoadData _M_ppath;

    /** Class used to read and sotre exiting photons positions data */
    LoadData _M_p;

    /** Class used to read and sotre exiting photons angles data */
    LoadData _M_v;


    /** Simulation directory */
    QString _M_simu_dir;


    /** Optical changes over time (QVector size Nb of class; Mat size: size Nb of chromophores; time) */
    QVector<Mat> _M_optical_changes;

    /** Name of the classes */
    QStringList _M_class_names;



    /** Flag for controlling if process can be done */
    bool _M_simu_data_ready;
    /** Flag for controlling if process can be done */
    bool _M_optical_changes_data_ready;
    /** Flag for controlling if process can be done */
    bool _M_mua_eps_data_ready;


    /** Binning for reconstuction the images */
    int _M_binning;

    /** Structure that contains the information of the simulation */
    _info_simulations _M_info_simus;

    /** Load data class */
    LoadData        _M_loadData;

    /** Saving directory */
    QString         _M_saving_dir;

    /** Study only one wavelength */
    bool            _M_study_one_lambda;


    /** Enable lens and camera modeling */
    bool            _M_model_lens_sensor;

    /** Structure that contains lens and sensor parameters */
    _lens_sensor    _M_lens_sensor;


};

#endif // PROCESS_H
