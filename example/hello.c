#include <janet.h>

static Janet myfun(int32_t argc, Janet *argv) {
    janet_fixarity(argc, 0);
    (void)argv;
    printf("hello from a module!\n");
    return janet_wrap_nil();
}

static const JanetReg cfuns[] = {
    {"myfun", myfun, "(hello/myfun)\n\nPrints a hello message."},
    {NULL, NULL, NULL}
};

JANET_MODULE_ENTRY(JanetTable *env) {
    janet_cfuns(env, "hello", cfuns);
}