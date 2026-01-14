#ifndef KIVK_LIB_QT_GENERATE_ENUM_H
#define KIVK_LIB_QT_GENERATE_ENUM_H

#include <QSet>
#include <QMap>
#include <QString>
#include <QRegularExpression>

#include <kivk_lib_generate_enum.h>

#define SET_ENUM_FIRST_VALUE__(START_VALUE, FIRST, ...) FIRST = START_VALUE, __VA_ARGS__

/// \brief Создать основной и вспомогательный enum и парочку методов (не стоит нумеровать элементы самостоятельно)
#define GENERATE_ENUM_QT(MODIFIER, ENUM_NAME, METHOD_NAME, START_VALUE, ...)    GENERATE_ENUM(MODIFIER, ENUM_NAME, METHOD_NAME, START_VALUE, __VA_ARGS__)\
                                                                                MODIFIER:\
                                                                                    static inline QMap<ENUM_NAME, QString> get##METHOD_NAME##Map()\
                                                                                    {\
                                                                                        constexpr const char str[] = #__VA_ARGS__;\
                                                                                        \
                                                                                        static QMap<ENUM_NAME, QString> result = kivk_lib::extractEnumStrings<ENUM_NAME>(START_VALUE, str);\
                                                                                        \
                                                                                        return result;\
                                                                                    }\
                                                                                    [[maybe_unused]] static inline QSet<int> getAll##METHOD_NAME##Values()\
                                                                                    {\
                                                                                        QSet<int> result;\
                                                                                        \
                                                                                        result.reserve(ENUM_NAME##_PRIVATE__::END__ - START_VALUE);\
                                                                                        \
                                                                                        for (int i = START_VALUE, ie = ENUM_NAME##_PRIVATE__::END__; i != ie; ++i)\
                                                                                        {\
                                                                                            result.insert(i);\
                                                                                        }\
                                                                                        \
                                                                                        return result;\
                                                                                    }

namespace kivk_lib
{

template <typename E, typename T>
auto extractEnumStrings(const T& startValue, const char* str)
{
    QMap<E, QString> result;

    // Создать очищщенную строку
    const auto enumStrings = QString{str}.simplified().trimmed().remove(QRegularExpression{"\\s+"}).split(',');

    for (int i = 0, ie = std::size(enumStrings); i != ie; ++i)
    {
        result.insert(static_cast<E>(startValue + i), enumStrings[i]);
    }
    return result;
}

}

#endif // KIVK_LIB_QT_GENERATE_ENUM_H
