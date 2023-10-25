#include "functions.h"



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

/** Write a floating point image on hardrive
@param path path for writing results
@param img image to be written to hardrive
*/
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
            stream<<Qt::endl;
        }
    }
}


/** Write information contains in a vector of string hardrive
@param path path for writing results
@param s vector of string to be written to hardrive */
void WriteInfo(const QString path,QVector<QString> s)
{
    QFile file( path);

    //Remove file if exists
    if(file.exists())
        file.remove();

    if ( file.open(QIODevice::ReadWrite) )
    {
        QTextStream stream( &file );

        for(int i=0;i<s.size();i++)
            stream <<s[i]<<Qt::endl;

    }
}


/** Get image plan position for a lens configuration
*@param system otpics system */
void getImagePlan(_lens_sensor &system)
{
    //Translation matrix before the lens
    Mat To = Mat::ones(2,2,CV_32FC1);
    To.at<float>(0,1) = system.working_distance_mm;
    To.at<float>(1,0) = 0;

    //Lens matrix
    Mat Lf = Mat::ones(2,2,CV_32FC1);
    Lf.at<float>(0,1) = 0;
    Lf.at<float>(1,0) = -1/system.f0_mm;

    //Ray at optical center
    Mat ro = Mat::zeros(2,1,CV_32FC1);
    ro.at<float>(1,0) = 1;


    //Distance to sensor
    vector<float> Z;
    //Coordinate of ray
    vector<float> R;

    float dz=0.1;

    for(int i=0;i<2000;i++)
    {
        float z = i*dz;
        Z.push_back(z);

        //Translation matrix to sensor
        Mat Ti = Mat::ones(2,2,CV_32FC1);
        Ti.at<float>(0,1) = z;
        Ti.at<float>(1,0) = 0;

        //Transfer matrix
        Mat S = Ti*Lf*To;

        //"image" ray coordinate is ri
        Mat ri=S*ro;
        R.push_back(abs(ri.at<float>(0,0)));
    }

    //Find min pos
    int N =  static_cast<int>(std::distance(R.begin(), min_element(R.begin(), R.end())));

    //get distance to sensor
    system.distance_to_sensor = Z[N];

}

/** Get transfer matrix of a lens system
*@param system otpics system */
void getTransferMatrix(_lens_sensor &system)
{
    //Get image plan
    getImagePlan(system);

    //Translation matrix before the lens
    Mat To = Mat::ones(2,2,CV_32FC1);
    To.at<float>(0,1) = system.working_distance_mm;
    To.at<float>(1,0) = 0;


    //Lens matrix
    Mat Lf = Mat::ones(2,2,CV_32FC1);
    Lf.at<float>(0,1) = 0;
    Lf.at<float>(1,0) = -1/system.f0_mm;

    //Translation matrix to sensor
    Mat Ti = Mat::ones(2,2,CV_32FC1);
    Ti.at<float>(0,1) = system.distance_to_sensor;
    Ti.at<float>(1,0) = 0;

    //Transfer matrix
    system.transfer_Matrix = Ti*Lf*To;

}


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

void get_Diffuse_reflectance_Pathlength(int binning,int nb_photons,int repetitions, const Mat &mua, int out_img_rows, int out_img_cols,
                                        float area_detector,float unit_tissue_in_mm,Mat *ppath, Mat *p,Mat &dr, Mat &mp)
{
//    qDebug()<<"Get diffuse reflectance and pathlength";
//    qDebug()<<"get_Diffuse_reflectance_Pathlength mua "<<mua.at<float>(0,0);
//    qDebug()<<"get_Diffuse_reflectance_Pathlength ppath "<<ppath->at<float>(0,0);


    //check size
    if(out_img_rows<=0 || out_img_cols<=0)
    {
        qDebug()<<"Wrong image size";
        return;
    }


//    QElapsedTimer timer;
//    timer.start();

    //Init mean path and diffuse reflectance img
    mp = Mat::zeros(out_img_rows,out_img_cols,CV_32FC1);
    dr = Mat::zeros(out_img_rows,out_img_cols,CV_32FC1);

    //sum of weights
    Mat sum_weights = Mat::zeros(mp.size(),CV_32FC1);


    //Loop over detected photons
    int Nb_detected_photons = ppath->rows;


//    #pragma omp parallel
//    {
////        int nb_thread = omp_get_num_threads();
//        #pragma omp for


        for(int i=0;i<Nb_detected_photons;i++)
        {
            //Calculate weights
            double weight = 1;
            for(int n=0;n<mua.rows;n++)
                weight *= exp(-mua.at<float>(n,0)*ppath->at<float>(i,n)*unit_tissue_in_mm);

              // get row and col index
            int row_id = floor((*p).at<float>(i,0)/binning)  ;
            int col_id = floor((*p).at<float>(i,1)/binning)  ;

            // if photon does not reach the sensor continue the for loop
            if(row_id<0 || col_id<0 || row_id>= out_img_rows || col_id >= out_img_cols)
                continue;

            //Sum weights
            sum_weights.at<float>(row_id,col_id) += weight;

            //compute diffuse reflectance
            float temp = weight/(area_detector*nb_photons*repetitions);
            temp = (isnan(temp) || isinf(temp)) ? 0 : temp;

            dr.at<float>(row_id,col_id) += temp;

            //Compute mean path length
            temp = float(sum((*ppath).row(i)*unit_tissue_in_mm*weight)[0]);
            temp = (isnan(temp) || isinf(temp)) ? 0 : temp;

            mp.at<float>(row_id,col_id) += temp;

        }
//    }


    //normalize mean path length with the sum of the weights
//    qDebug()<<"Normalize";
    #pragma omp parallel
    {
    //        int nb_thread = omp_get_num_threads();
        #pragma omp for
        for(int r=0;r<out_img_rows;r++)
        {
            for(int c=0;c<out_img_cols;c++)
                mp.at<float>(r,c) /= sum_weights.at<float>(r,c);
        }
    }

    //Remove first, last columns and rows
//    qDebug()<<"rect";
//    Rect rect(1,1,out_img_cols-2,out_img_rows-2);
//    mp = mp(rect);
//    dr = dr(rect);
}
