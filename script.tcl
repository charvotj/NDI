# Add all signals
set nfacs [ gtkwave::getNumFacs ]
set all_facs [list]
for {set i 0} {$i < $nfacs } {incr i} {
    set facname [ gtkwave::getFacName $i ]
    lappend all_facs "$facname"
}
set num_added [ gtkwave::addSignalsFromList $all_facs ]
puts "num signals added: $num_added"

# zoom full
gtkwave::/Time/Zoom/Zoom_Full


# Pridani jenom listu 
#set sig_list [list sig_name_a, register_name\[32:0\], ... ] # note the escaping of the [,] brackets
#gtkwave::addSignalsFromList $sig_list
#--script=/home/radek/NDI/script.tcl