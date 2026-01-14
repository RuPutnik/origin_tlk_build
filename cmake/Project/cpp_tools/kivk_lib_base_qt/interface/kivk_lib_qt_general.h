#ifndef KIVK_LIB_QT_GENERAL_H
#define KIVK_LIB_QT_GENERAL_H

#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>

#include <kivk_lib_general.h>

namespace kivk_lib
{
/// \brief Преобразовать любой контейнер в QSet
template <typename Container>
[[maybe_unused]] static QSet<typename std::iterator_traits<typename Container::iterator>::value_type> convertToSet(const Container& container)
{
    return {container.cbegin(), container.cend()};
}

/// \brief Преобразовать любой контейнер в QStringList из номеров
template <typename Container>
[[maybe_unused]] static QStringList convertToIntStringList(const Container& container)
{
    QStringList result;
    result.reserve(container.size());
    for (const auto & num : container)
    {
        result.append(QString::number(num));
    }
    return result;
}

/// \brief Преобразовать любой контейнер в QJsonArray строку
template <typename Container>
[[maybe_unused]] static QString convertJsonArrayToString(const Container& container)
{
    QJsonArray result;
    for (const auto & value : container)
    {
        result.append(value);
    }
    return QString::fromUtf8(QJsonDocument{result}.toJson(QJsonDocument::Compact));
}

/// \brief Преобразовать QByteArray в QSet указанного типа
template <typename T>
[[maybe_unused]] static QSet<T> convertJsonArrayToSet(const QByteArray& jsonArray);

template <>
[[maybe_unused]] QSet<int> convertJsonArrayToSet(const QByteArray& jsonArray)
{
    // Искомые числа
    QSet<int> result;
    const auto nubersArray = QJsonDocument::fromJson(jsonArray).array();
    for (const auto & jsonNumber : nubersArray)
    {
        result.insert(jsonNumber.toInt());
    }
    return result;
}

template <typename T>
[[maybe_unused]] static inline QJsonObject toJsonObject(const T& object);

template <>
[[maybe_unused]] inline QJsonObject toJsonObject(const QJsonObject& object)
{
    return object;
}

template <>
[[maybe_unused]] inline QJsonObject toJsonObject(const QVariantMap& map)
{
    return QJsonObject::fromVariantMap(map);
}

template <>
[[maybe_unused]] inline QJsonObject toJsonObject(const QString& object)
{
    return QJsonDocument::fromJson(object.toUtf8()).object();
}

template <typename T>
[[maybe_unused]] static inline QJsonArray toJsonArray(const T& array);

template <>
[[maybe_unused]] inline QJsonArray toJsonArray(const QJsonArray& array)
{
    return array;
}

template <>
[[maybe_unused]] inline QJsonArray toJsonArray(const QString& array)
{
    return QJsonDocument::fromJson(array.toUtf8()).array();
}


/// \brief Соединить два QJsonObject без перетерания информации
template <typename T1, typename T2>
[[maybe_unused]] static QJsonObject concatJsonObjects(const T1& first, const T2& second)
{
    const auto jFirst = toJsonObject(first);
    const auto jSecond = toJsonObject(second);

    // Первый параметр более приоритетный
    QJsonObject result{jFirst};
    for (auto it = jSecond.constBegin(), ite = jSecond.constEnd(); it != ite; ++it)
    {
        if (result.contains(it.key()))
        {
            // Если есть такой элемент, модифицировать ключ и повторить попытку
            result = concatJsonObjects(result, QJsonObject{{it.key() + "_", *it}});
        }
        else
        {
            // Если нет -> просто добавить
            result.insert(it.key(), *it);
        }
    }
    return result;
}

}

#endif // KIVK_LIB_QT_GENERAL_H
