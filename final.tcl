#yona orunov 328178165
#Yakov Yedidya Ben Shaul 215702473

global arthJumpFlag
set arthJumpFlag  0

proc com1 {} {
    set ret "@SP\nAM=M-1\nD=M\nA=A-1\n"
    return $ret
}


proc com2 {ProductName} {
    global arthJumpFlag
    set ret "@SP\nAM=M-1\nD=M\nA=A-1\nD=M-D\n@FALSE$arthJumpFlag\nD;$ProductName\n@SP\nA=M-1\nM=-1\n@CONTINUE$arthJumpFlag\n0;JMP\n(FALSE$arthJumpFlag)\n@SP\nA=M-1\nM=0\n(CONTINUE$arthJumpFlag)\n"
    return $ret
}

proc pushF {segment index isDirect}  {
    set helper ""
    if {$isDirect eq "true"} {
        append helper ""
    } elseif {$isDirect eq "false"} {
        append helper "@$index\nA=D+A\nD=M\n"
    }
    set re "@$segment\nD=M\n$helper@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    return $re
}

proc popF {segment index isDirect}  {
    set helper ""
    if {$isDirect eq "true"} {
        append helper "D=A\n"
    } elseif {$isDirect eq "false"} {
        append helper "D=M\n@$index\nD=D+A\n"
    }
    set re "@$segment\n$helper@R13\nM=D\n@SP\nAM=M-1\nD=M\n@R13\nA=M\nM=D\n"
    return $re
}

proc WritePushPop {command segment index filehandle_asm} {
    if { $command eq "push" } {
        if {$segment eq "constant"} {
            set ph "@$index\nD=A\n@SP\nA=M\nM=D\n@SP\nM=M+1\n" 
            puts $filehandle_asm $ph
        } elseif {$segment eq "local"} {
            set se "LCL"
            set se1 "false"
            set res [pushF $se $index $se1]
            puts $filehandle_asm $res
        } elseif {$segment eq "argument"} {
            set se "ARG"
            set se1 "false"
            set res [pushF $se $index $se1]
            puts $filehandle_asm $res
        } elseif {$segment eq "this"} {
            set se "THIS"
            set se1 "false"
            set res [pushF $se $index $se1]
            puts $filehandle_asm $res
        } elseif {$segment eq "that"} {
            set se "THAT"
            set se1 "false"
            set res [pushF $se $index $se1]
            puts $filehandle_asm $res
        } elseif {$segment eq "temp"} {
            set se "R5"
            set se1 "false"
            set indexer $index
            incr indexer 5
            set res [pushF $se $indexer $se1]
            puts $filehandle_asm $res
        } elseif {$segment eq "pointer"} {
            set se ""
            if {$index eq 0} {
                append se "THIS"
                set se1 "true"
                set res [pushF $se $index $se1]
                puts $filehandle_asm $res
            } elseif {$index eq 1} {
                set se "THAT"
                set se1 "true"
                set res [pushF $se $index $se1]
                puts $filehandle_asm $res
            }
        } elseif {$segment eq "static"} {
            set se1 "true"
            set indexer $index
            incr indexer 16
            set se "$indexer"
            set res [pushF $se $index $se1]
            puts $filehandle_asm $res
        }
    } elseif {$command eq "pop"} {
        if {$segment eq "local"} {
            set se "LCL"
            set se1 "false"
            set res [popF $se $index $se1]
            puts $filehandle_asm $res	
        } elseif {$segment eq "argument"} {
            set se "ARG"
            set se1 "false"
            set res [popF $se $index $se1]
            puts $filehandle_asm $res	 
        } elseif {$segment eq "this"} {
            set se "THIS"
            set se1 "false"
            set res [popF $se $index $se1]
            puts $filehandle_asm $res	
        } elseif {$segment eq "that"} {
            set se "THAT"
            set se1 "false"
            set res [popF $se $index $se1]
            puts $filehandle_asm $res	
        } elseif {$segment eq "temp"} {
            set se "R5"
            set se1 "false"
            set indexer $index
            incr indexer 5
            set res [popF $se $indexer $se1]
            puts $filehandle_asm $res
        } elseif {$segment eq "pointer"} {
            if {$index eq 0 } {
                set se "THIS"
                set se1 "true"
                set res [popF $se $index $se1]
                puts $filehandle_asm $res
            } else {
                set se "THAT"
                set se1 "true"
                set res [popF $se $index $se1]
                puts $filehandle_asm $res
            }
        } elseif {$segment eq "static"} {
            set se1 "true"
            set indexer $index
            incr indexer 16
            set se "$indexer"
            set res [popF $se $index $se1]
            puts $filehandle_asm $res
        }   
    }
}


proc trnslate {fileP lineR} {
    global arthJumpFlag
    set splitL [split $lineR " "]
    set command [lindex $splitL 0]
    if {$command == "push" || $command == "pop"} {
        set ar1 [lindex $splitL 1]
        set ar2 [lindex $splitL 2]
        WritePushPop $command $ar1 $ar2 $fileP
    } elseif {$command == "add"} {
        set ADD "// add\n"
        append ADD [com1]
        append ADD "M=M+D\n"
        puts $fileP $ADD
    } elseif {$command == "sub"} {
        set SUB "// sub\n"
        append SUB [com1]
        append SUB "M=M-D\n"
        puts $fileP $SUB
    } elseif {$command == "neg"} {
        set NEG "D=0\n@SP\nA=M-1\nM=D-M\n"
        puts $fileP $NEG
    } elseif {$command == "eq"} {
        set se "JNE"
        set EQ [com2 $se] 
        puts $fileP $EQ
        incr arthJumpFlag
    } elseif {$command == "gt"} {
        set se "JLE"
        set GT [com2 $se] 
        puts $fileP $GT
        incr arthJumpFlag
    } elseif {$command == "lt"} {
        set se "JGE"
        set LT [com2 $se] 
        puts $fileP $LT
        incr arthJumpFlag 
    } elseif {$command == "and"} {
        set AND "// and\n"
        append AND [com1]
        append AND "M=M&D\n"
        puts $fileP $AND
    } elseif {$command == "or"} {
        set OR "// or\n"
        append OR [com1]
        append OR "M=M|D\n"
        puts $fileP $OR
    } elseif {$command == "not"} {
        set NOT "//not\n@SP\nA=M-1\nM=!M\n"
        puts $fileP $NOT
    }
}



set userInput "" ;
puts "Enter a file or path:"
gets stdin userInput
if {[file exists $userInput]} {
    if {[file isdirectory $userInput]} {
        puts "$userInput is a directory"
        return
    } elseif {[file extension $userInput] eq ".vm"} {
        puts "$userInput is a .vm file"
    } else {
        puts "$userInput is not a .vm file"
        return ;# End the program if it's not a .vm file
    }
} else {
    puts "$userInput does not exist"
    return ;# End the program if the input doesn't exist
}
set f [split $userInput "."]
set fa [lindex $f 0]
set usInp "$fa.asm"
set fileOut [open $usInp w]
set fileIn [open $userInput r]
while {[gets $fileIn line] !=-1} {
     if {[regexp {^(\\|[\t ]*$)} $line]} {
        puts $fileOut $line
        continue
     }
     puts $line
     trnslate $fileOut $line
}
close $fileIn
close $fileOut