; RUN: opt < %s -basicaa -slp-vectorizer -dce -S -mtriple=x86_64-apple-macosx10.8.0 -mcpu=corei7

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.9.0"

@c = common global i32 0, align 4
@a = common global i16 0, align 2
@b = common global i16 0, align 2

; Function Attrs: nounwind ssp uwtable
define void @f() {
entry:
  %call = tail call i32 (...) @g()
  %0 = load i32, i32* @c, align 4
  %lnot = icmp eq i32 %0, 0
  %lnot.ext = zext i1 %lnot to i32
  %1 = load i16, i16* @a, align 2
  %lnot2 = icmp eq i16 %1, 0
  %lnot.ext3 = zext i1 %lnot2 to i32
  %or = or i32 %lnot.ext3, %lnot.ext
  %cmp = icmp eq i32 %call, %or
  %conv4 = zext i1 %cmp to i16
  store i16 %conv4, i16* @b, align 2
  ret void
}

declare i32 @g(...)
