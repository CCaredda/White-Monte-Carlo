/**
 * @file mainwindow.h
 *
 * @brief This class contains the graphical elements to reconstruct the images.
 * Contact: caredda.c@gmail.com
 *
 */

#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QFileDialog>
#include "process.h"


QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:

    /** Click on directory to select simulations output */
    void onDirSimuclicked();

    /** Click to select directory that contains optical changes */
    void onDirOpticalChangesClicked();

    /** New lens design */
    void onNewLensSensorDesign();

    /** New Wavelength */
    void onNewWavelength();

    /** New wavelength range (for multiple wavelength processing */
    void onNewWavelengthRange();

    /** CLick on display reconstruction (process 1 wavlength or several ones)*/
    void on_processSingleLambdaClicked(bool);


private:
    Ui::MainWindow *ui;

    /** Data class */
    Process _M_process;

};
#endif // MAINWINDOW_H
