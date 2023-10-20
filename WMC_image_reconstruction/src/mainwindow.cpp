#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QDebug>


MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    //Open directory that contains results
    connect(ui->_dir_simu,SIGNAL(pressed()),this,SLOT(onDirSimuclicked()));
    //Disable button to be sure that optical changes are loaded first
    ui->_dir_simu->setEnabled(false);

    //Open directory that contains optical changes files
    connect(ui->_dir_optical_changes,SIGNAL(pressed()),this,SLOT(onDirOpticalChangesClicked()));


    //progressBar
    connect(&_M_process,SIGNAL(processing(QString)),ui->_progress,SLOT(setText(QString)));

    //Binning
    ui->_binning->setValue(1);
    ui->_binning->setMinimum(1);
    connect(ui->_binning,SIGNAL(valueChanged(int)),&_M_process,SLOT(onBinningChanged(int)));


    //Process single wavelength
    ui->_process_single_lambda->setChecked(true);
    connect(ui->_process_single_lambda,SIGNAL(clicked(bool)),&_M_process,SLOT(onrequestSingleLambda(bool)));
    //wavelength
    ui->_wavelength->setText("500");
    connect(ui->_wavelength,SIGNAL(returnPressed()),this,SLOT(onNewWavelength()));

    //Lens system
    ui->_model_lens->setChecked(false);
    connect(ui->_model_lens,SIGNAL(clicked(bool)),&_M_process,SLOT(requestLensSensorModeling(bool)));

    //f0
    ui->_f0->setText("30");
    connect(ui->_f0,SIGNAL(returnPressed()),this,SLOT(onNewLensSensorDesign()));

    //Working distance
    ui->_working_distance->setText("400");
    connect(ui->_working_distance,SIGNAL(returnPressed()),this,SLOT(onNewLensSensorDesign()));

    //sensor width (mm)
    ui->_sensor_width_mm->setText("6");
    ui->_sensor_height_mm->setText(QString::number(6*0.8));
    connect(ui->_sensor_width_mm,SIGNAL(returnPressed()),this,SLOT(onNewLensSensorDesign()));

    ui->_sensor_width_px->setText("100");
    ui->_sensor_height_px->setText(QString::number(6*0.8));
    connect(ui->_sensor_width_px,SIGNAL(returnPressed()),this,SLOT(onNewLensSensorDesign()));


}

MainWindow::~MainWindow()
{
    delete ui;
}


//Dir clicked
void MainWindow::onDirSimuclicked()
{
    // get directory
    QString dir = QFileDialog::getExistingDirectory(this, tr("Open Directory"),
                                                 PROPATH,
                                                 QFileDialog::ShowDirsOnly
                                                 | QFileDialog::DontResolveSymlinks);

    // Check if directory is not empty
    if (dir == "")
        return;

    ui->_dir_simu_path->setText(dir);
    _M_process.setSimulationDir(dir);




    //qDebug()<<ui->_mua_GM->get_mua(_M_data.get_mua_W(),_M_data.get_mua_F(),_M_data.get_eps_HbO2(),_M_data.get_eps_Hb(),_M_data.get_eps_oxCCO(),_M_data.get_eps_redCCO());
}


/** Click to select directory that contains optical changes */
void MainWindow::onDirOpticalChangesClicked()
{
    // get directory
    QString dir = QFileDialog::getExistingDirectory(this, tr("Open Directory"),
                                                 PROPATH,
                                                 QFileDialog::ShowDirsOnly
                                                 | QFileDialog::DontResolveSymlinks);

    // Check if directory is not empty
    if (dir == "")
        return;

    ui->_dir_simu->setEnabled(true);
    ui->_dir_optical_changes_path->setText(dir);
    _M_process.ReadOpticalChanges(dir);
}



/** New focal length */
void MainWindow::onNewLensSensorDesign()
{
    _lens_sensor system;
    system.f0_mm = ui->_f0->text().toFloat();;
    system.working_distance_mm = ui->_working_distance->text().toFloat();

    system.y_sensor_mm =ui->_sensor_width_mm->text().toFloat();
    system.x_sensor_mm =system.y_sensor_mm*0.8;

    system.y_sensor_px = floor(ui->_sensor_width_px->text().toFloat());
    system.x_sensor_px = floor(system.y_sensor_px*0.8);


    ui->_sensor_height_mm->setText(QString::number(system.x_sensor_mm));
    ui->_sensor_height_px->setText(QString::number(system.x_sensor_px));


    _M_process.newLensSensorDesign(system);
}

void MainWindow::onNewWavelength()
{
    int w =ui->_wavelength->text().toInt();
    _M_process.setWavelength(w);
}
