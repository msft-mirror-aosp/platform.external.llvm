target datalayout = "e-m:e-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

$c2 = comdat any

define linkonce_odr i32 @f(i8*) unnamed_addr comdat($c2) {
    ret i32 41
}

define i32 @g() {
    %i = call i32 @f(i8* null)
    ret i32 %i
}
