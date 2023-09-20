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

    //progressBar
    connect(&_M_process,SIGNAL(processing(QString)),ui->_progress,SLOT(setText(QString)));

    //Binning
    ui->_binning->setValue(1);
    ui->_binning->setMinimum(1);
    connect(ui->_binning,SIGNAL(valueChanged(int)),&_M_process,SLOT(onBinningChanged(int)));


    //Process single wavelength
    ui->_process_single_lambda->setChecked(true);
    connect(ui->_process_single_lambda,SIGNAL(clicked(bool)),&_M_process,SLOT(onrequestSingleLambda(bool)));


    //Lens system
    ui->_model_lens->setChecked(false);
    connect(ui->_model_lens,SIGNAL(clicked(bool)),&_M_process,SLOT(requestLensSensorModeling(bool)));

    //f0
    ui->_f0->setText("30");
    connect(ui->_f0,SIGNAL(textEdited(QString)),this,SLOT(onNewLensSensorDesign()));
    //Working distance
    ui->_working_distance->setText("400");
    connect(ui->_working_distance,SIGNAL(textEdited(QString)),this,SLOT(onNewLensSensorDesign()));

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



/** New focal length */
void MainWindow::onNewLensSensorDesign()
{
    float f0 = ui->_f0->text().toFloat();
    float wd = ui->_working_distance->text().toFloat();

    qDebug()<<"f0: "<<f0;
    qDebug()<<"wd: "<<wd;

    _lens_sensor system;
    system.f0_mm = f0;
    system.working_distance_mm = wd;

    _M_process.newLensSensorDesign(system);

}
