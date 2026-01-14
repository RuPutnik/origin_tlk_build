#ifndef KIVK_LIB_GENERAL
#define KIVK_LIB_GENERAL

#include <type_traits>

namespace kivk_lib
{

/// @brief Определить является ли Derived наслледником Base
template <template<typename...> class Base, typename Derived>
struct is_variadic_base_of
{
    ~is_variadic_base_of() = delete;

private:
    template<typename... Args>
    static std::true_type trySubstitute_(const Base<Args...>&);

    static std::false_type trySubstitute_(...);

public:
    // Вычислить тип Derived через попытку подстановки
    static constexpr bool value = decltype(trySubstitute_(std::declval<Derived&>()))::value;
};

/// @brief Определить является ли Derived наслледником Base
template <template<typename...> class Base, typename Derived>
    inline constexpr bool is_variadic_base_of_v = is_variadic_base_of<Base, Derived>::value;

}

#endif // KIVK_LIB_GENERAL
