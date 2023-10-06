/**
 * @file functions.h
 *
 * @brief This file contains the usefull functions and structures to reconstruct diffuse reflectance and mean path length images using White Monte Carlo Simulations
 * @author Charly Caredda
 * Contact: caredda.c@gmail.com
 *
 */



#ifndef FUNCTIONS_H
#define FUNCTIONS_H

#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <math.h>
#include <QElapsedTimer>




#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/imgproc/types_c.h"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/core/core.hpp"
#include "opencv2/opencv.hpp"

using namespace cv;
using namespace std;


/** Contains the information of the simulations */
typedef struct
{
    int nb_photons;
    int repetions;
    int modelled_volume_rows;
    int modelled_volume_cols;
    float unit_in_mm;

}_info_simulations;

/** Contains the information of optics for the image reconstruction
@param working_distance_mm */
typedef struct
{
    float working_distance_mm;
    float f0_mm;
    float distance_to_sensor;
    Mat transfer_Matrix;

    float x_sensor_mm;
    float y_sensor_mm;
    float x_sensor_px;
    float y_sensor_px;

    float sensor_reso_x;
    float sensor_reso_y;

}_lens_sensor;

/** Calculate absorption coefficient (in mm-1)
 *  @param Optical_changes Vector of matrices that contains the optical changes (proportion of water and Fat (in %)
 *  and concentration changes of HbO2, Hb, oxCCO and redCCO (in mol.L-1)).
 *  Vector size: number of class (grey matter, blood vessel, capillaries, ...)
 *  Matrix size: number of chromophores x time
 *  @param mua_W Absorption coefficient of Water (in cm-1)
 *  @param mua_F Absorption coefficient of Fat (in cm-1)
 *  @param eps_HbO2 Molar extinction coefficient of HbO2 (in cm-1.mol-1.L)
 *  @param epsHb Molar extinction coefficient of Hb (in cm-1.mol-1.L)
 *  @param eps_oxCCO Molar extinction coefficient of oxCCO (in cm-1.mol-1.L)
 *  @param eps_redCCO Molar extinction coefficient of redCCO (in cm-1.mol-1.L)
 *  @returns Matrix of absorption coefficient (in mm-1) Size: number of class x time */
Mat get_mua(QVector<Mat> &Optical_changes, float mua_W,float mua_F,float eps_HbO2,float eps_Hb,float eps_oxCCO,float eps_redCCO);

/** Write a floating point image on hardrive
@param path path for writing results
@param img image to be written to hardrive
*/
void WriteFloatImg(const QString path,const Mat img);

/** Write information contains in a vector of string hardrive
@param path path for writing results
@param s vector of string to be written to hardrive */
void WriteInfo(const QString path,QVector<QString> s);

/** Get transfer matrix of a lens system
*@param system otpics system */
void getTransferMatrix(_lens_sensor &system);


/** Get image plan position for a lens configuration
*@param system otpics system */
void getImagePlan(_lens_sensor &system);

/** Get diffuse reflectance and mean path length
 *  Input:
 *  @param binning binning of the detector for image reconstruction (integer)
 *  @param nb_photons Number of photons used for the simulations
 *  @param repetitions Number of repetions used for the simulations
 *  @param mua Absorpiton coeffcient (in mm-1, calculated with get_mua function
 *  @param out_img_rows Number of rows of the reconstructed image
 *  @param out_img_cols Number of cols of the reconstructed image
 *  @param area_detector Area of the detector in mm-2
 *  @param unit_tissue_in_mm Resolution of the modelled tissue used in the simulations (in mm)
 *  @param ppath pointer on partial path length data (in mm) pointer on matrix of dimension (number of detected photons x nb of classes +1)
 *  @param p pointer on exiting photons positions (in pixel units) pointer on matrix of dimension (number of detected photons x 3 (x;y;z) positions)
 *  @returns dr output matrix that contains the reconstructed diffuse reflectance (in mm-2). Dimension out_img_rows x out_img_cols
 *  @returns mp output matrix that contains the reconstructed mean path length (in mm). Dimension out_img_rows x out_img_cols*/
void get_Diffuse_reflectance_Pathlength(int binning, int nb_photons, int repetitions, const Mat &mua, int out_img_rows, int out_img_cols,
                                        float area_detector, float unit_tissue_in_mm, Mat *ppath, Mat *p, Mat &dr, Mat &mp);


#endif // FUNCTIONS_H
