#ifndef STOPWATCH_H
#define STOPWATCH_H

#include <QFile>
#include <QDebug>
#include <QDateTime>
#include <QTextStream>
#include <QCoreApplication>

#define SW_START(name) StopWatch ___##name##___(#name);
#define SW_STOP(name) ___##name##___.stop();
#define SW_INIT_PATH(path) StopWatch::setResultFilePath(path);
#define SW_FUNC_CHECK StopWatch ___sw_func_check___(__func__);
#define SW_BLOCK_CHECK(name, code) {StopWatch ___sw_block_check___(#name); \
                                    code \
                                    }

//TODO вынести всё использование qt в файлы реализации (чтобы не протягивать зависимость от qt)

class StopWatch
{
public:
    StopWatch(QString name = ""):
        nameStopWatch{name}, beginTime{0}, endTime{0}
    {
        beginTime = QDateTime::currentMSecsSinceEpoch();
    }

    ~StopWatch(){
        if(endTime == 0){
            _stop();
        }
    }

    StopWatch(StopWatch&&) = delete; //Делаем объекты некопируемыми и неперемещаемыми

    QTime stop(){
        if(endTime == 0){
            return _stop();
        }else{
            qWarning() << "Double stop this (" + nameStopWatch + ") stopwatch";

            const int resultMsecs = static_cast<int>(endTime - beginTime);
            return QTime::fromMSecsSinceStartOfDay(resultMsecs);
        }
    }

    const QString& getName() const &{
        return nameStopWatch;
    }

    static void setResultFilePath(QString path){
        filePath = path;
    }

private:
    QTime _stop()
    {
        endTime = QDateTime::currentMSecsSinceEpoch();

        const int resultMsecs = static_cast<int>(endTime - beginTime);

        qInfo().noquote() << QString("Execution time (%1) ms: %2").arg(nameStopWatch, QString::number(resultMsecs));

        if(!filePath.isEmpty()){
            writeResultFile(resultMsecs);
        }

        return QTime::fromMSecsSinceStartOfDay(resultMsecs);
    }

    void writeResultFile(int resultMsecs) const
    {
        const QTime resultTime = QTime::fromMSecsSinceStartOfDay(resultMsecs);
        QFile executionTimeResult(filePath);

        if(!executionTimeResult.open(QIODevice::Append)){
            qWarning() << "Error write execution time in file " + filePath;
            return;
        }

        QString message = "[App: %1] [PID: %2] [Datetime start: %3] Execution time (stopwatch: %4) = %5 (%6 ms)";
        const QString currDT = QDateTime::currentDateTime().toString("dd:MM:yyyy hh:mm:ss:zzz");
        message = message.arg(QCoreApplication::applicationName(), QString::number(QCoreApplication::applicationPid()), currDT, nameStopWatch,
                              resultTime.toString("hh:mm:ss:zzz"), QString::number(resultMsecs));

        QTextStream writeStream(&executionTimeResult);
        writeStream << message << "\n";
    }

    QString nameStopWatch;
    inline static QString filePath;
    qint64 beginTime;
    qint64 endTime;
};

#endif // STOPWATCH_H
