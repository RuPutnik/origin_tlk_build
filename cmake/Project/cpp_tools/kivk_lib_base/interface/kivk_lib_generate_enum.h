#ifndef KIVK_LIB_GENERATE_ENUM_H
#define KIVK_LIB_GENERATE_ENUM_H

#define SET_ENUM_FIRST_VALUE__(START_VALUE, FIRST, ...) FIRST = START_VALUE, __VA_ARGS__

/// \brief Создать основной и вспомогательный enum и парочку методов (не стоит нумеровать элементы самостоятельно)
#define GENERATE_ENUM(MODIFIER, ENUM_NAME, METHOD_NAME, START_VALUE, ...)   private:\
                                                                                enum ENUM_NAME##_PRIVATE__ : int\
                                                                                {\
                                                                                    BEGIN__ = START_VALUE - 1,\
                                                                                    __VA_ARGS__,\
                                                                                    END__\
                                                                                };\
                                                                            public:\
                                                                                enum class ENUM_NAME : int\
                                                                                {\
                                                                                    SET_ENUM_FIRST_VALUE__(START_VALUE, __VA_ARGS__)\
                                                                                };\
                                                                            MODIFIER:\
                                                                                [[maybe_unused]] static inline constexpr bool isLegal##METHOD_NAME(int value)\
                                                                                {\
                                                                                    return static_cast<int>(value) > ENUM_NAME##_PRIVATE__::BEGIN__ &&\
                                                                                           static_cast<int>(value) < ENUM_NAME##_PRIVATE__::END__;\
                                                                                }\
                                                                                [[maybe_unused]] static inline constexpr ENUM_NAME first##METHOD_NAME()\
                                                                                {\
                                                                                    return static_cast<ENUM_NAME>(ENUM_NAME##_PRIVATE__::BEGIN__ + 1);\
                                                                                }\
                                                                                [[maybe_unused]] static inline constexpr ENUM_NAME last##METHOD_NAME()\
                                                                                {\
                                                                                    return static_cast<ENUM_NAME>(ENUM_NAME##_PRIVATE__::END__ - 1);\
                                                                                }\
                                                                                [[maybe_unused]] static inline constexpr int getEnumValue(ENUM_NAME enumValue)\
                                                                                {\
                                                                                    return static_cast<int>(enumValue);\
                                                                                }

namespace kivk_lib
{

}

#endif // KIVK_LIB_GENERATE_ENUM_H
