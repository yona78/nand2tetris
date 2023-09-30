#yona orunov 328178165
#Yakov Yedidya Ben Shaul 215702473

global arthJumpFlag
global arthJumpTrue
global arthJumpFalse
global labelCnt 
set arthJumpFlag  0
set labelCnt 0
set arthJumpFalse 0
set arthJumpTrue 0
set labelReg {^[^0-9][0-9A-Za-z\_\\:\\.\$]+}

proc pushf {} {
    return "A=D+A\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
}

proc popf {} {
    return "D=D+A\n@R13\nM=D\n@SP\nA=M-1\nD=M\n@R13\nA=M\nM=D\n@SP\nM=M-1\n"
}

proc WritePushPop {command segment index filehandle_asm file_name} {
    if { $command eq "push" } {
        if {$segment eq "constant"} {
            set ph "@$index\nD=A\n@SP\nA=M\nM=D\n@SP\nM=M+1\n" 
            puts $filehandle_asm $ph
        } elseif {$segment eq "local"} {
            set se [pushf]
            set res "@LCL\nD=M\n@$index\n$se"
            puts $filehandle_asm $res
        } elseif {$segment eq "argument"} {
            set se [pushf]
            set res "@ARG\nD=M\n@$index\n$se"
            puts $filehandle_asm $res
        } elseif {$segment eq "this"} {
            set se [pushf]
            set res "@THIS\nD=M\n@$index\n$se"
            puts $filehandle_asm $res
        } elseif {$segment eq "that"} {
            set se [pushf]
            set res "@THAT\nD=M\n@$index\n$se"
            puts $filehandle_asm $res
        } elseif {$segment eq "temp"} {
            set se [pushf]
            set res "@5\nD=A\n@$index\n$se"
            puts $filehandle_asm $res
        } elseif {$segment eq "pointer"} {
            set se [pushf]
            puts $filehandle_asm "@3\nD=A\n@$index\n$se"
        } elseif {$segment eq "static"} {
            set se [pushf]
            puts $filehandle_asm "@$file_name.static.$index\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
        }
    } elseif {$command eq "pop"} {
        if {$segment eq "local"} {
            set se [popf]
            set res "@LCL\nD=M\n@$index\n$se"
            puts $filehandle_asm $res	
        } elseif {$segment eq "argument"} {
            set se [popf]
            set res "@ARG\nD=M\n@$index\n$se"
            puts $filehandle_asm $res	 
        } elseif {$segment eq "this"} {
            set se [popf]
            set res "@THIS\nD=M\n@$index\n$se"
            puts $filehandle_asm $res	
        } elseif {$segment eq "that"} {
            set se [popf]
            set res "@THAT\nD=M\n@$index\n$se"
            puts $filehandle_asm $res	
        } elseif {$segment eq "temp"} {
            set se [popf]
            puts $filehandle_asm "@5\nD=A\n@$index\n$se"
        } elseif {$segment eq "pointer"} {
            set se [popf]
            puts $filehandle_asm "@3\nD=A\n@$index\n$se"
        } elseif {$segment eq "static"} {
            puts $filehandle_asm "@SP\nA=M-1\nD=M\n@$file_name.static.$index\nM=D\n@SP\nM=M-1\n"
        }   
    }
}

proc writeInit { file_o } {
    set res "@256\nD=A\n@SP\nM=D\n"
    puts $file_o $res
    set se "Sys.init"
    set se1 0
    writeCall $se $se1 $file_o
}

proc writeCall {functionName numArgs file_o} {
    global labelCnt
    puts $file_o "@RETURN_LABEL$labelCnt\nD=A\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    puts $file_o "@LCL\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    puts $file_o "@ARG\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    puts $file_o "@THIS\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    puts $file_o "@THAT\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    puts $file_o "@5\nD=A\n@$numArgs\nD=D+A\n@SP\nD=M-D\n@ARG\nM=D\n@SP\nD=M\n@LCL\nM=D\n@$functionName\n0;JMP\n(RETURN_LABEL$labelCnt)\n"
    incr labelCnt
}


proc trnslate {fileP lineR file_name} {
    global arthJumpFalse
    global arthJumpTrue
    global arthJumpFlag
    global labelReg
    set splitL [split $lineR " "]
    set command [lindex $splitL 0]
    if {$command == "push" || $command == "pop"} {
        set ar1 [lindex $splitL 1]
        set ar2 [lindex $splitL 2]
        WritePushPop $command $ar1 $ar2 $fileP $file_name
    } elseif {$command == "add"} {
        puts $fileP "@SP\nA=M-1\nD=M\n@R13\nM=D\n@SP\nM=M-1\n@SP\nA=M-1\nD=M\n@R13\nD=D+M\n@SP\nA=M-1\nM=D\n"
    } elseif {$command == "sub"} {
        puts $fileP "@SP\nA=M-1\nD=M\n@R13\nM=D\n@SP\nM=M-1\n@SP\nA=M-1\nD=M\n@R13\nD=D-M\n@SP\nA=M-1\nM=D\n"
    } elseif {$command == "neg"} {
        set NEG "@SP\nA=M-1\nM=-M\n"
        puts $fileP $NEG
    } elseif {$command == "eq"} {
        set se "$file_name.EQ.true.$arthJumpFlag"
        set se1 "$file_name.EQ.end.$arthJumpFlag"
        incr arthJumpFlag
        puts $fileP "@SP\nA=M-1\nD=M\n@R13\nM=D\n@SP\nM=M-1\n@SP\nA=M-1\nD=M\n@R13\nD=D-M\n@$se\nD;JEQ\n@SP\nA=M-1\nM=0\n@$se1\n0;JMP\n($se)\n@SP\nA=M-1\nM=-1\n($se1)\n"
    } elseif {$command == "gt"} {
        set se "$file_name.GT.true.$arthJumpTrue"
        set se1 "$file_name.GT.end.$arthJumpTrue"
        incr arthJumpTrue 
        puts $fileP "@SP\nA=M-1\nD=M\n@R13\nM=D\n@SP\nM=M-1\n@SP\nA=M-1\nD=M\n@R13\nD=D-M\n@$se\nD;JGT\n@SP\nA=M-1\nM=0\n@$se1\n0;JMP\n($se)\n@SP\nA=M-1\nM=-1\n($se1)\n"
    } elseif {$command == "lt"} {
        set se "$file_name.LT.true.$arthJumpFalse"
        set se1 "$file_name.LT.end.$arthJumpFalse"
        incr arthJumpFalse 
        puts $fileP "@SP\nA=M-1\nD=M\n@R13\nM=D\n@SP\nM=M-1\n@SP\nA=M-1\nD=M\n@R13\nD=D-M\n@$se\nD;JLT\n@SP\nA=M-1\nM=0\n@$se1\n0;JMP\n($se)\n@SP\nA=M-1\nM=-1\n($se1)\n"
    } elseif {$command == "and"} {
        puts $fileP "@SP\nA=M-1\nD=M\n@R13\nM=D\n@SP\nM=M-1\n@SP\nA=M-1\nD=M\n@R13\nD=D&M\n@SP\nA=M-1\nM=D\n"
    } elseif {$command == "or"} {
        puts $fileP "@SP\nA=M-1\nD=M\n@R13\nM=D\n@SP\nM=M-1\n@SP\nA=M-1\nD=M\n@R13\nD=D|M\n@SP\nA=M-1\nM=D\n"
    } elseif {$command == "not"} {
        set NOT "//not\n@SP\nA=M-1\nM=!M\n"
        puts $fileP $NOT
    } elseif {$command == "label"} {
        set ar1 [lindex $splitL 1]
        if {[regexp $labelReg $ar1]} {
            set res "($ar1)\n"
            puts $fileP $res
        } else {
            puts "Wrong label format!"
        }    
    } elseif {$command == "goto"} {
        set ar1 [lindex $splitL 1]
        if {[regexp $labelReg $ar1]} {
            set res "@$ar1\n0;JMP\n"
            puts $fileP $res
        } else {
            puts "Wrong label format!"
        }
    } elseif {$command == "if-goto"} {
        set ar1 [lindex $splitL 1]
        if {[regexp $labelReg $ar1]} {
            set res "@SP\nAM=M-1\nD=M\n"
            append res "@$ar1\nD;JNE\n"
            puts $fileP $res
        } else {
            puts "Wrong label format!"
        }
    } elseif {$command == "function"} {
        set ar1 [lindex $splitL 1]
        set ar2 [lindex $splitL 2]
        set funN "($ar1)\n"
        puts $fileP $funN
        for {set i 0} {$i < $ar2} {incr i} {
            puts $fileP "@SP\nA=M\nM=0\n@SP\nM=M+1\n"
        } 
    } elseif {$command == "call"} {
        set ar1 [lindex $splitL 1]
        set ar2 [lindex $splitL 2]
        writeCall $ar1 $ar2 $fileP
        
    } elseif {$command == "return"} {
        set ret "@LCL\nD=M\n@R13\nM=D\n@R13\nD=M\n@5\nA=D-A\nD=M\n@R14\nM=D\n@SP\nA=M-1\nD=M\n@ARG\nA=M\nM=D\n@ARG\nD=M+1\n@SP\nM=D\n@R13\nA=M-1\nD=M\n@THAT\nM=D\n@R13\nD=M\n@2\nA=D-A\nD=M\n@THIS\nM=D\n@R13\nD=M\n@3\nA=D-A\nD=M\n@ARG\nM=D\n@R13\nD=M\n@4\nA=D-A\nD=M\n@LCL\nM=D\n@R14\nA=M\n0;JMP\n"
        puts $fileP $ret
    } 
}



set userInput "" ;
puts "Enter a file or path:"
gets stdin userInput
set inp ""
if {[file exists $userInput]} {
    if {[file isdirectory $userInput]} {
        puts "$userInput is a directory"
        append inp "dir"
    } elseif {[file extension $userInput] eq ".vm"} {
        puts "$userInput is a .vm file"
        append inp "file"
    } else {
        puts "$userInput is not a .vm file"
        return ;# End the program if it's not a .vm file
    }
} else {
    puts "$userInput does not exist"
    return ;# End the program if the input doesn't exist
}
set fa ""
if {$inp == "file"} {
    set f [split $userInput "."]
    append fa [lindex $f 0]
} else {
    set f [split $userInput "\\"]
    set helper1 $userInput
    append helper1 "\\"
    append helper1 [lindex $f end]
    append fa $helper1
}
set usInp "$fa.asm"
set fileOut [open $usInp w]
if {$inp == "file"} {
    set fileIn [open $userInput r]
    set f1 [split $userInput "\\"]
    set f2 [lindex $f1 end]
    set f3 [split $f2 "/"]
    set file_name [lindex $f3 end]
    while {[gets $fileIn line] !=-1} {
        if {[regexp {^(\\|[\t ]*$)} $line]} {
            puts $fileOut $line
            continue
        }
        puts $line
        trnslate $fileOut $line $file_name
    }
    close $fileIn
} else {
    set amount 0
    foreach fileD [glob -directory $userInput *] {
        set extension [file extension $fileD]
        if {$extension eq ".vm"} {
            incr amount
        }
    }
    if {$amount > 1} {
        writeInit $fileOut
    }
    #writeInit $fileOut
    foreach fileD [glob -directory $userInput *] {
        set extension [file extension $fileD]
        if {$extension eq ".vm"} {
            set f1 [split $fileD "\\"]
            set f2 [lindex $f1 end]
            set f3 [split $f2 "/"]
            set file_name [lindex $f3 end]
            set fileDO [open $fileD r]
            while {[gets $fileDO line] !=-1} {
                if {[regexp {^(\\|[\t ]*$)} $line]} {
                    puts $fileOut $line
                    continue
                }
                puts $line
                trnslate $fileOut $line $file_name
            }
            close $fileDO
        }
    }
}
close $fileOut
