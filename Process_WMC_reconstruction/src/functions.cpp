#include "functions.h"



/** Get mua coefficient in mm-1
 Size Optical_changes: (QVector size Nb of class; Mat size: size Nb of chromophores; time)
 Size output mua:  (size Nb of class; time) */
Mat get_mua(QVector<Mat> &Optical_changes, float mua_W,float mua_F,float eps_HbO2,float eps_Hb,float eps_oxCCO,float eps_redCCO)
{
    //Get matrix dimension
    int T = Optical_changes[0].cols;
    int nb_class = Optical_changes.size();
    //int nb_chromophores = Optical_changes[0].rows;

    //Init output
    Mat mua = Mat::zeros(nb_class,T,CV_32FC1);

    //Loop over number of class
    for(int n=0;n<nb_class;n++)
    {
        //Loop over time
        for(int t=0;t<T;t++)
        {
            //optical changes (size nb_chromophores; T)
            float W = Optical_changes[n].at<float>(0,t);
            float F = Optical_changes[n].at<float>(1,t);
            float C_HbO2 = Optical_changes[n].at<float>(2,t);
            float C_Hb = Optical_changes[n].at<float>(3,t);
            float C_oxCCO = Optical_changes[n].at<float>(4,t);
            float C_redCCO = Optical_changes[n].at<float>(5,t);

            // Compute mua and convert it into mm-1
            mua.at<float>(n,t) = 0.1 * (W*mua_W + F*mua_F +
                                log(10)*C_Hb*eps_Hb +
                                log(10)*C_HbO2*eps_HbO2 +
                                log(10)*C_oxCCO*eps_oxCCO +
                                log(10)*C_redCCO*eps_redCCO);
        }
    }

    return mua;
}

void WriteFloatImg(const QString path,const Mat img)
{
    QFile file( path);

    //Remove file if exists
    if(file.exists())
        file.remove();

    if ( file.open(QIODevice::ReadWrite) )
    {
        QTextStream stream( &file );

        for(int row=0;row<img.rows;row++)
        {
            const float *ptr=img.ptr<float>(row);
            for(int col=0;col<img.cols;col++)
            {
                stream <<ptr[col]<<" ";
            }
            stream<<endl;
        }
    }
}
