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

    /** New lens design */
    void onNewLensSensorDesign();

private:
    Ui::MainWindow *ui;

    /** Data class */
    Process _M_process;

};
#endif // MAINWINDOW_H
