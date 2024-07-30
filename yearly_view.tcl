proc update_yearly_view {config year} {
    set name [dict get $config name]
    set yearly_events [dict get $config yearly_events]
    
    wm title . "My Life - $name - Year $year"
    
    # Clear existing content
    foreach widget [winfo children .frame] {
        destroy $widget
    }
    
    # Days in the year (accounting for leap years)
    set days_in_year 365
    if {[clock format [clock scan "$year-12-31" -format "%Y-%m-%d"] -format "%j"] == 366} {
        set days_in_year 366
    }
    
    # Sort events by start date
    if {[dict exists $yearly_events $year]} {
        set year_events [lsort -command compare_events [dict get $yearly_events $year]]
    } else {
        set year_events {}
    }
    
    set num_events [llength $year_events]
    set today [clock seconds]
    set year_start [clock scan "$year-01-01" -format "%Y-%m-%d"]
    
    # Create a grid of 13 rows, each with 28 days
    for {set row 0} {$row < 13} {incr row} {
        for {set col 0} {$col < 28} {incr col} {
            set day_of_year [expr {$row * 28 + $col + 1}]
            if {$day_of_year <= $days_in_year} {
                set current_date [clock add $year_start [expr {$day_of_year - 1}] days]
                set color "white"
                
                # Find the current event
                for {set i 0} {$i < $num_events} {incr i} {
                    set event [lindex $year_events $i]
                    set event_start [dict get $event start]
                    
                    if {$i == ($num_events - 1)} {
                        set event_end $today
                    } else {
                        set next_event [lindex $year_events [expr {$i + 1}]]
                        set event_end [dict get $next_event start]
                    }
                    
                    if {$current_date >= $event_start && $current_date < $event_end} {
                        set color [dict get $event color]
                        break
                    }
                }
                
                label .frame.cell$row-$col -width 2 -height 1 -bg $color -relief solid
                grid .frame.cell$row-$col -row $row -column $col -padx 0 -pady 0
            } else {
                # Empty cell for days beyond the year
                label .frame.cell$row-$col -width 2 -height 1 -bg "gray" -relief solid
                grid .frame.cell$row-$col -row $row -column $col -padx 0 -pady 0
            }
        }
    }
    
    # Create a legend
    set legend_row 13
    if {$year_events ne {}} {
        for {set i 0} {$i < $num_events} {incr i} {
            set event [lindex $year_events $i]
            set name [dict get $event name]
            set color [dict get $event color]
            set start [clock format [dict get $event start] -format "%Y-%m-%d"]
            
            if {$i == ($num_events - 1)} {
                set end_text "ongoing"
            } else {
                set next_event [lindex $year_events [expr {$i + 1}]]
                set end [clock format [dict get $next_event start] -format "%Y-%m-%d"]
                set end_text "to $end"
            }
            
            label .frame.legend$legend_row -text "$name" -bg $color -fg white -relief solid
            grid .frame.legend$legend_row -row $legend_row -column 0 -columnspan 28 -sticky "ew"
            incr legend_row
        }
    }
}
proc compare_events {a b} {
    set date_a [dict get $a start]
    set date_b [dict get $b start]
    return [expr {$date_a - $date_b}]
}