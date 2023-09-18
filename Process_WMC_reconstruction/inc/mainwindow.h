#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QFileDialog>
#include "data.h"


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

    /** Click on directory to select optical changes  */
    void onDirOptical_changesclicked();

    /** Start process */
    void onStartProcess();

private:
    Ui::MainWindow *ui;

    /** Data class */
    Data _M_data;

};
#endif // MAINWINDOW_H
