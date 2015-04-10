; RUN: llc -march=x86-64 -mtriple=x86_64-linux < %s | FileCheck %s
; RUN: opt -strip-debug < %s | llc -march=x86-64 -mtriple=x86_64-linux | FileCheck %s
; http://llvm.org/PR19051. Minor code-motion difference with -g.
; Presence of debug info shouldn't affect the codegen. Make sure that
; we generated the same code sequence with and without debug info. 
;
; CHECK:      callq   _Z3fooPcjPKc
; CHECK:      callq   _Z3fooPcjPKc
; CHECK:      leaq    (%rsp), %rdi
; CHECK:      movl    $4, %esi
; CHECK:      testl   {{%[a-z]+}}, {{%[a-z]+}}
; CHECK:      je     .LBB0_4

; Regenerate test with this command: 
;   clang -emit-llvm -S -O2 -g
; from this source:
;
; extern void foo(char *dst,unsigned siz,const char *src);
; extern const char * i2str(int);
;
; struct AAA3 {
;  AAA3(const char *value) { foo(text,sizeof(text),value);}
;  void operator=(const char *value) { foo(text,sizeof(text),value);}
;  operator const char*() const { return text;}
;  char text[4];
; };
;
; void bar (int param1,int param2)  {
;   const char * temp(0);
;
;   if (param2) {
;     temp = i2str(param2);
;   }
;   AAA3 var1("");
;   AAA3 var2("");
;
;   if (param1)
;     var2 = "+";
;   else
;     var2 = "-";
;   var1 = "";
; }

%struct.AAA3 = type { [4 x i8] }

@.str = private unnamed_addr constant [1 x i8] zeroinitializer, align 1
@.str1 = private unnamed_addr constant [2 x i8] c"+\00", align 1
@.str2 = private unnamed_addr constant [2 x i8] c"-\00", align 1

; Function Attrs: uwtable
define void @_Z3barii(i32 %param1, i32 %param2) #0 {
entry:
  %var1 = alloca %struct.AAA3, align 1
  %var2 = alloca %struct.AAA3, align 1
  tail call void @llvm.dbg.value(metadata i32 %param1, i64 0, metadata !30, metadata !MDExpression()), !dbg !47
  tail call void @llvm.dbg.value(metadata i32 %param2, i64 0, metadata !31, metadata !MDExpression()), !dbg !47
  tail call void @llvm.dbg.value(metadata i8* null, i64 0, metadata !32, metadata !MDExpression()), !dbg !49
  %tobool = icmp eq i32 %param2, 0, !dbg !50
  br i1 %tobool, label %if.end, label %if.then, !dbg !50

if.then:                                          ; preds = %entry
  %call = tail call i8* @_Z5i2stri(i32 %param2), !dbg !52
  tail call void @llvm.dbg.value(metadata i8* %call, i64 0, metadata !32, metadata !MDExpression()), !dbg !49
  br label %if.end, !dbg !54

if.end:                                           ; preds = %entry, %if.then
  tail call void @llvm.dbg.value(metadata %struct.AAA3* %var1, i64 0, metadata !33, metadata !MDExpression()), !dbg !55
  tail call void @llvm.dbg.value(metadata %struct.AAA3* %var1, i64 0, metadata !56, metadata !MDExpression()), !dbg !57
  tail call void @llvm.dbg.value(metadata !58, i64 0, metadata !59, metadata !MDExpression()), !dbg !60
  %arraydecay.i = getelementptr inbounds %struct.AAA3, %struct.AAA3* %var1, i64 0, i32 0, i64 0, !dbg !61
  call void @_Z3fooPcjPKc(i8* %arraydecay.i, i32 4, i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str, i64 0, i64 0)), !dbg !61
  call void @llvm.dbg.value(metadata %struct.AAA3* %var2, i64 0, metadata !34, metadata !MDExpression()), !dbg !63
  call void @llvm.dbg.value(metadata %struct.AAA3* %var2, i64 0, metadata !64, metadata !MDExpression()), !dbg !65
  call void @llvm.dbg.value(metadata !58, i64 0, metadata !66, metadata !MDExpression()), !dbg !67
  %arraydecay.i5 = getelementptr inbounds %struct.AAA3, %struct.AAA3* %var2, i64 0, i32 0, i64 0, !dbg !68
  call void @_Z3fooPcjPKc(i8* %arraydecay.i5, i32 4, i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str, i64 0, i64 0)), !dbg !68
  %tobool1 = icmp eq i32 %param1, 0, !dbg !69
  call void @llvm.dbg.value(metadata %struct.AAA3* %var2, i64 0, metadata !34, metadata !MDExpression()), !dbg !63
  br i1 %tobool1, label %if.else, label %if.then2, !dbg !69

if.then2:                                         ; preds = %if.end
  call void @llvm.dbg.value(metadata %struct.AAA3* %var2, i64 0, metadata !71, metadata !MDExpression()), !dbg !73
  call void @llvm.dbg.value(metadata !74, i64 0, metadata !75, metadata !MDExpression()), !dbg !76
  call void @_Z3fooPcjPKc(i8* %arraydecay.i5, i32 4, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str1, i64 0, i64 0)), !dbg !76
  br label %if.end3, !dbg !72

if.else:                                          ; preds = %if.end
  call void @llvm.dbg.value(metadata %struct.AAA3* %var2, i64 0, metadata !77, metadata !MDExpression()), !dbg !79
  call void @llvm.dbg.value(metadata !80, i64 0, metadata !81, metadata !MDExpression()), !dbg !82
  call void @_Z3fooPcjPKc(i8* %arraydecay.i5, i32 4, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str2, i64 0, i64 0)), !dbg !82
  br label %if.end3

if.end3:                                          ; preds = %if.else, %if.then2
  call void @llvm.dbg.value(metadata %struct.AAA3* %var1, i64 0, metadata !33, metadata !MDExpression()), !dbg !55
  call void @llvm.dbg.value(metadata %struct.AAA3* %var1, i64 0, metadata !83, metadata !MDExpression()), !dbg !85
  call void @llvm.dbg.value(metadata !58, i64 0, metadata !86, metadata !MDExpression()), !dbg !87
  call void @_Z3fooPcjPKc(i8* %arraydecay.i, i32 4, i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str, i64 0, i64 0)), !dbg !87
  ret void, !dbg !88
}

declare i8* @_Z5i2stri(i32) #1

declare void @_Z3fooPcjPKc(i8*, i32, i8*) #1

; Function Attrs: nounwind readnone
declare void @llvm.dbg.value(metadata, i64, metadata, metadata) #2

attributes #0 = { uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!44, !45}
!llvm.ident = !{!46}

!0 = !MDCompileUnit(language: DW_LANG_C_plus_plus, producer: "clang version 3.5.0 ", isOptimized: true, emissionKind: 1, file: !1, enums: !2, retainedTypes: !3, subprograms: !23, globals: !2, imports: !2)
!1 = !MDFile(filename: "dbg-changes-codegen-branch-folding.cpp", directory: "/tmp/dbginfo")
!2 = !{}
!3 = !{!4}
!4 = !MDCompositeType(tag: DW_TAG_structure_type, name: "AAA3", line: 4, size: 32, align: 8, file: !1, elements: !5, identifier: "_ZTS4AAA3")
!5 = !{!6, !11, !17, !18}
!6 = !MDDerivedType(tag: DW_TAG_member, name: "text", line: 8, size: 32, align: 8, file: !1, scope: !"_ZTS4AAA3", baseType: !7)
!7 = !MDCompositeType(tag: DW_TAG_array_type, size: 32, align: 8, baseType: !8, elements: !9)
!8 = !MDBasicType(tag: DW_TAG_base_type, name: "char", size: 8, align: 8, encoding: DW_ATE_signed_char)
!9 = !{!10}
!10 = !MDSubrange(count: 4)
!11 = !MDSubprogram(name: "AAA3", line: 5, isLocal: false, isDefinition: false, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: true, scopeLine: 5, file: !1, scope: !"_ZTS4AAA3", type: !12)
!12 = !MDSubroutineType(types: !13)
!13 = !{null, !14, !15}
!14 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, flags: DIFlagArtificial | DIFlagObjectPointer, baseType: !"_ZTS4AAA3")
!15 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, baseType: !16)
!16 = !MDDerivedType(tag: DW_TAG_const_type, baseType: !8)
!17 = !MDSubprogram(name: "operator=", linkageName: "_ZN4AAA3aSEPKc", line: 6, isLocal: false, isDefinition: false, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: true, scopeLine: 6, file: !1, scope: !"_ZTS4AAA3", type: !12)
!18 = !MDSubprogram(name: "operator const char *", linkageName: "_ZNK4AAA3cvPKcEv", line: 7, isLocal: false, isDefinition: false, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: true, scopeLine: 7, file: !1, scope: !"_ZTS4AAA3", type: !19)
!19 = !MDSubroutineType(types: !20)
!20 = !{!15, !21}
!21 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, flags: DIFlagArtificial | DIFlagObjectPointer, baseType: !22)
!22 = !MDDerivedType(tag: DW_TAG_const_type, baseType: !"_ZTS4AAA3")
!23 = !{!24, !35, !40}
!24 = !MDSubprogram(name: "bar", linkageName: "_Z3barii", line: 11, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: true, scopeLine: 11, file: !1, scope: !25, type: !26, function: void (i32, i32)* @_Z3barii, variables: !29)
!25 = !MDFile(filename: "dbg-changes-codegen-branch-folding.cpp", directory: "/tmp/dbginfo")
!26 = !MDSubroutineType(types: !27)
!27 = !{null, !28, !28}
!28 = !MDBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!29 = !{!30, !31, !32, !33, !34}
!30 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "param1", line: 11, arg: 1, scope: !24, file: !25, type: !28)
!31 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "param2", line: 11, arg: 2, scope: !24, file: !25, type: !28)
!32 = !MDLocalVariable(tag: DW_TAG_auto_variable, name: "temp", line: 12, scope: !24, file: !25, type: !15)
!33 = !MDLocalVariable(tag: DW_TAG_auto_variable, name: "var1", line: 17, scope: !24, file: !25, type: !"_ZTS4AAA3")
!34 = !MDLocalVariable(tag: DW_TAG_auto_variable, name: "var2", line: 18, scope: !24, file: !25, type: !"_ZTS4AAA3")
!35 = !MDSubprogram(name: "operator=", linkageName: "_ZN4AAA3aSEPKc", line: 6, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: true, scopeLine: 6, file: !1, scope: !"_ZTS4AAA3", type: !12, declaration: !17, variables: !36)
!36 = !{!37, !39}
!37 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "this", arg: 1, flags: DIFlagArtificial | DIFlagObjectPointer, scope: !35, type: !38)
!38 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, baseType: !"_ZTS4AAA3")
!39 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "value", line: 6, arg: 2, scope: !35, file: !25, type: !15)
!40 = !MDSubprogram(name: "AAA3", linkageName: "_ZN4AAA3C2EPKc", line: 5, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: true, scopeLine: 5, file: !1, scope: !"_ZTS4AAA3", type: !12, declaration: !11, variables: !41)
!41 = !{!42, !43}
!42 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "this", arg: 1, flags: DIFlagArtificial | DIFlagObjectPointer, scope: !40, type: !38)
!43 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "value", line: 5, arg: 2, scope: !40, file: !25, type: !15)
!44 = !{i32 2, !"Dwarf Version", i32 4}
!45 = !{i32 2, !"Debug Info Version", i32 3}
!46 = !{!"clang version 3.5.0 "}
!47 = !MDLocation(line: 11, scope: !24)
!48 = !{i8* null}
!49 = !MDLocation(line: 12, scope: !24)
!50 = !MDLocation(line: 14, scope: !51)
!51 = distinct !MDLexicalBlock(line: 14, column: 0, file: !1, scope: !24)
!52 = !MDLocation(line: 15, scope: !53)
!53 = distinct !MDLexicalBlock(line: 14, column: 0, file: !1, scope: !51)
!54 = !MDLocation(line: 16, scope: !53)
!55 = !MDLocation(line: 17, scope: !24)
!56 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "this", arg: 1, flags: DIFlagArtificial | DIFlagObjectPointer, scope: !40, type: !38, inlinedAt: !55)
!57 = !MDLocation(line: 0, scope: !40, inlinedAt: !55)
!58 = !{i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str, i64 0, i64 0)}
!59 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "value", line: 5, arg: 2, scope: !40, file: !25, type: !15, inlinedAt: !55)
!60 = !MDLocation(line: 5, scope: !40, inlinedAt: !55)
!61 = !MDLocation(line: 5, scope: !62, inlinedAt: !55)
!62 = distinct !MDLexicalBlock(line: 5, column: 0, file: !1, scope: !40)
!63 = !MDLocation(line: 18, scope: !24)
!64 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "this", arg: 1, flags: DIFlagArtificial | DIFlagObjectPointer, scope: !40, type: !38, inlinedAt: !63)
!65 = !MDLocation(line: 0, scope: !40, inlinedAt: !63)
!66 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "value", line: 5, arg: 2, scope: !40, file: !25, type: !15, inlinedAt: !63)
!67 = !MDLocation(line: 5, scope: !40, inlinedAt: !63)
!68 = !MDLocation(line: 5, scope: !62, inlinedAt: !63)
!69 = !MDLocation(line: 20, scope: !70)
!70 = distinct !MDLexicalBlock(line: 20, column: 0, file: !1, scope: !24)
!71 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "this", arg: 1, flags: DIFlagArtificial | DIFlagObjectPointer, scope: !35, type: !38, inlinedAt: !72)
!72 = !MDLocation(line: 21, scope: !70)
!73 = !MDLocation(line: 0, scope: !35, inlinedAt: !72)
!74 = !{i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str1, i64 0, i64 0)}
!75 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "value", line: 6, arg: 2, scope: !35, file: !25, type: !15, inlinedAt: !72)
!76 = !MDLocation(line: 6, scope: !35, inlinedAt: !72)
!77 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "this", arg: 1, flags: DIFlagArtificial | DIFlagObjectPointer, scope: !35, type: !38, inlinedAt: !78)
!78 = !MDLocation(line: 23, scope: !70)
!79 = !MDLocation(line: 0, scope: !35, inlinedAt: !78)
!80 = !{i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str2, i64 0, i64 0)}
!81 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "value", line: 6, arg: 2, scope: !35, file: !25, type: !15, inlinedAt: !78)
!82 = !MDLocation(line: 6, scope: !35, inlinedAt: !78)
!83 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "this", arg: 1, flags: DIFlagArtificial | DIFlagObjectPointer, scope: !35, type: !38, inlinedAt: !84)
!84 = !MDLocation(line: 24, scope: !24)
!85 = !MDLocation(line: 0, scope: !35, inlinedAt: !84)
!86 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "value", line: 6, arg: 2, scope: !35, file: !25, type: !15, inlinedAt: !84)
!87 = !MDLocation(line: 6, scope: !35, inlinedAt: !84)
!88 = !MDLocation(line: 25, scope: !24)
