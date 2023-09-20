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


/** Structure used after the acquisition of a RGB image */
typedef struct
{
    int nb_photons;
    int repetions;
    int modelled_volume_rows;
    int modelled_volume_cols;
    float unit_in_mm;

}_info_simulations;


typedef struct
{
    float working_distance_mm;
    float f0_mm;
    float distance_to_sensor;
    Mat transfer_Matrix;

    float x_sensor_mm;
    float y_sensor_mm;
    int x_sensor_px;
    int y_sensor_px;

    float sensor_reso_x;
    float sensor_reso_y;

}_lens_sensor;

Mat get_mua(QVector<Mat> &Optical_changes, float mua_W,float mua_F,float eps_HbO2,float eps_Hb,float eps_oxCCO,float eps_redCCO);


void WriteFloatImg(const QString path,const Mat img);
void WriteInfo(const QString path,QVector<QString> s);

// Get transfer matrix of a lens system
void getTransferMatrix(_lens_sensor &system);

//Get diffuse reflectance and mean path length
void get_Diffuse_reflectance_Pathlength(int binning, int nb_photons, int repetitions, const Mat &mua, int out_img_rows, int out_img_cols,
                                        float area_detector, float unit_tissue_in_mm, Mat *ppath, Mat *p, Mat &dr, Mat &mp);


#endif // FUNCTIONS_H
