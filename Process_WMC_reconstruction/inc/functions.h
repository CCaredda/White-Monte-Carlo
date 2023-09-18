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

Mat get_mua(QVector<Mat> &Optical_changes, float mua_W,float mua_F,float eps_HbO2,float eps_Hb,float eps_oxCCO,float eps_redCCO);


void WriteFloatImg(const QString path,const Mat img);

#endif // FUNCTIONS_H
