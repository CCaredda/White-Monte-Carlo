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

    //Open directory that contains optical properties changs
    connect(ui->_dir_optical_changes,SIGNAL(pressed()),this,SLOT(onDirOptical_changesclicked()));

    //Start process
    connect(ui->_start_process,SIGNAL(pressed()),this,SLOT(onStartProcess()));

    //progressBar
    connect(&_M_data,SIGNAL(processing(QString)),ui->_progress,SLOT(setText(QString)));

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
    _M_data.setSimulationDir(dir);




    //qDebug()<<ui->_mua_GM->get_mua(_M_data.get_mua_W(),_M_data.get_mua_F(),_M_data.get_eps_HbO2(),_M_data.get_eps_Hb(),_M_data.get_eps_oxCCO(),_M_data.get_eps_redCCO());
}

void MainWindow::onDirOptical_changesclicked()
{
    QString dir = QFileDialog::getExistingDirectory(this, tr("Open Directory"),
                                                 PROPATH,
                                                 QFileDialog::ShowDirsOnly
                                                 | QFileDialog::DontResolveSymlinks);

    // Check if directory is not empty
    if (dir == "")
        return;

    ui->_dir_optical_changes_path->setText(dir);
    _M_data.setOpticalChangesDir(dir);

}

void MainWindow::onStartProcess()
{
    //set wavelength
    _M_data.Launch_reconstruction();
}
