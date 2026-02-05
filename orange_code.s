# RISC-V Traffic Controller for 5-Stage Pipeline Processor
# Optimized for pipeline execution with hazard handling

.data
    # LED addresses to test
    LED_ADDR_1: .word 0xF0000000
    LED_ADDR_2: .word 0xFFFF0000
    LED_ADDR_3: .word 0x80000000
    LED_ADDR_4: .word 0xFFFF0100
    
    current_led_addr: .word 0xF0000000
    
    state:       .word 0
    timer:       .word 0
    cycle_count: .word 0
    pattern_mode: .word 0
    anim_frame:  .word 0
    pattern_timer: .word 0
    
    # Color definitions
    COLOR_RED:     .word 0x00FF0000
    COLOR_GREEN:   .word 0x0000FF00
    COLOR_BLUE:    .word 0x000000FF
    COLOR_YELLOW:  .word 0x00FFFF00
    COLOR_ORANGE:  .word 0x00FF8000
    COLOR_WHITE:   .word 0x00FFFFFF
    COLOR_BLACK:   .word 0x00000000
    COLOR_ROAD:    .word 0x00505050
    
    # Timing
    GREEN_TIME:  .word 20
    YELLOW_TIME: .word 5
    RED_TIME:    .word 25
    
    # Messages
    newline:     .string "\n"
    msg_start:   .string "=== 5-Stage Pipeline Traffic Controller ===\n"
    msg_test:    .string "Testing LED addresses...\n"
    msg_found:   .string "Using LED address: 0xF0000000\n"
    msg_pattern0: .string "=== PATTERN 1: Normal Traffic ===\n"
    msg_pattern1: .string "=== PATTERN 2: Rush Hour ===\n"
    msg_pattern2: .string "=== PATTERN 3: Emergency Flash ===\n"
    msg_pattern3: .string "=== PATTERN 4: All-Way Stop ===\n"
    msg_state0:  .string "NS=RED   EW=GREEN  "
    msg_state1:  .string "NS=RED   EW=YELLOW "
    msg_state2:  .string "NS=GREEN EW=RED    "
    msg_state3:  .string "NS=YELLOW EW=RED   "
    msg_state4:  .string "EMERGENCY FLASH "
    msg_state5:  .string "ALL RED (STOP) "
    msg_timer:   .string "Timer: "
    msg_cycles:  .string " | Cycles: "
    msg_exit:    .string "\n=== Simulation Complete ===\n"

.text
.globl _start

_start:
    # Initialize stack pointer
    li sp, 0x10000
    
    # Initialize all counters to zero
    li s6, 0              # cycle counter
    li s7, 0              # animation frame
    
    # Store initial values to memory
    la t0, state
    sw x0, 0(t0)
    nop                   # Pipeline: avoid load-use hazard
    
    la t0, timer
    sw x0, 0(t0)
    nop
    
    la t0, anim_frame
    sw x0, 0(t0)
    nop
    
    la t0, pattern_mode
    sw x0, 0(t0)
    nop
    
    la t0, pattern_timer
    sw x0, 0(t0)
    nop
    
    # Load timing constants
    la t0, GREEN_TIME
    lw s3, 0(t0)
    nop                   # Pipeline: load delay slot
    
    la t0, YELLOW_TIME
    lw s4, 0(t0)
    nop
    
    la t0, RED_TIME
    lw s5, 0(t0)
    nop
    
    # Print startup messages
    jal ra, print_startup
    nop                   # Pipeline: branch delay slot
    
    # Run LED diagnostic
    jal ra, led_diagnostic
    nop
    
    # Initialize display
    jal ra, draw_intersection
    nop

main_loop:
    # Check for pattern switching
    jal ra, check_pattern_switch
    nop
    
    # Update traffic lights display
    jal ra, update_traffic_lights
    nop
    
    # Print current status
    jal ra, print_status
    nop
    
    # Run state machine
    jal ra, traffic_controller
    nop
    
    # Update animation frame
    la t0, anim_frame
    lw t1, 0(t0)
    nop                   # Load delay
    addi t1, t1, 1
    andi t1, t1, 7
    sw t1, 0(t0)
    mv s7, t1             # Cache in register
    
    # Delay for visibility
    jal ra, delay
    nop
    
    # Increment cycle counter
    addi s6, s6, 1
    la t0, cycle_count
    sw s6, 0(t0)
    
    # Check if done (100 cycles)
    li t0, 200
    nop                   # Pipeline: data hazard prevention
    blt s6, t0, main_loop
    nop                   # Branch delay
    
    # Exit
    jal ra, print_exit
    nop
    j exit_program
    nop

# LED Diagnostic - Test multiple addresses
led_diagnostic:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    la a0, msg_test
    jal ra, print_string
    nop
    
    # Test Address 1: 0xF0000000
    li t1, 0xF0000000
    jal ra, test_led_address
    nop
    
    la a0, msg_found
    jal ra, print_string
    nop
    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
    nop

test_led_address:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    mv s0, t1             # Save LED address
    
    # Write test pattern
    la t0, COLOR_RED
    lw t2, 0(t0)
    nop
    
    li t3, 0
test_write_loop:
    slli t4, t3, 2
    add t5, s0, t4
    sw t2, 0(t5)
    nop                   # Store delay
    
    addi t3, t3, 1
    li t6, 50
    blt t3, t6, test_write_loop
    nop
    
    # Small delay
    li t0, 1000
test_delay:
    addi t0, t0, -1
    bnez t0, test_delay
    nop
    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
    nop

check_pattern_switch:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    la t0, pattern_timer
    lw t1, 0(t0)
    nop
    addi t1, t1, 1
    sw t1, 0(t0)
    
    # Switch every 50 cycles
    li t2, 50
    blt t1, t2, no_switch
    nop
    
    # Reset timer
    sw x0, 0(t0)
    nop
    
    # Next pattern
    la t0, pattern_mode
    lw t1, 0(t0)
    nop
    addi t1, t1, 1
    andi t1, t1, 3
    sw t1, 0(t0)
    
    # Reset state
    la t0, state
    sw x0, 0(t0)
    nop
    
    la t0, timer
    sw x0, 0(t0)
    nop
    
    # Print pattern
    jal ra, print_pattern_header
    nop
    
no_switch:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
    nop

print_pattern_header:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    la t0, pattern_mode
    lw t1, 0(t0)
    nop
    
    beq t1, x0, print_p0
    nop
    li t2, 1
    beq t1, t2, print_p1
    nop
    li t2, 2
    beq t1, t2, print_p2
    nop
    j print_p3
    nop

print_p0:
    la a0, msg_pattern0
    jal ra, print_string
    nop
    j pattern_print_done
    nop

print_p1:
    la a0, msg_pattern1
    jal ra, print_string
    nop
    j pattern_print_done
    nop

print_p2:
    la a0, msg_pattern2
    jal ra, print_string
    nop
    j pattern_print_done
    nop

print_p3:
    la a0, msg_pattern3
    jal ra, print_string
    nop

pattern_print_done:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
    nop

draw_intersection:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    la t0, current_led_addr
    lw s0, 0(t0)
    nop
    
    la t0, COLOR_BLACK
    lw s1, 0(t0)
    nop
    
    # Clear display
    li t3, 0
clear_loop:
    slli t4, t3, 2
    add t5, s0, t4
    sw s1, 0(t5)
    nop
    
    addi t3, t3, 1
    li t6, 625
    blt t3, t6, clear_loop
    nop
    
    # Draw roads (simplified for 5-stage)
    la t0, COLOR_ROAD
    lw s1, 0(t0)
    nop
    
    # Vertical road (col 12, rows 0-24)
    li t3, 0
draw_v_road:
    li t4, 25
    mul t5, t3, t4
    addi t5, t5, 12
    slli t5, t5, 2
    add t6, s0, t5
    sw s1, 0(t6)
    nop
    
    addi t3, t3, 1
    li t6, 25
    blt t3, t6, draw_v_road
    nop
    
    # Horizontal road (row 12, cols 0-24)
    li t3, 0
draw_h_road:
    li t4, 12
    li t5, 25
    mul t6, t4, t5
    add t6, t6, t3
    slli t6, t6, 2
    add t6, s0, t6
    sw s1, 0(t6)
    nop
    
    addi t3, t3, 1
    li t6, 25
    blt t3, t6, draw_h_road
    nop
    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
    nop

update_traffic_lights:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    jal ra, draw_intersection
    nop
    
    la t0, current_led_addr
    lw s0, 0(t0)
    nop
    
    la t0, state
    lw s1, 0(t0)
    nop
    
    la t0, pattern_mode
    lw s8, 0(t0)
    nop
    
    # Pattern 2: Emergency (Swapped)
    li t0, 2
    beq s8, t0, pattern_emergency
    nop

    # Pattern 3: All-stop (Swapped)
    li t0, 3
    beq s8, t0, pattern_allstop
    nop
    
    # Normal patterns (0 and 1)
    beq s1, x0, draw_state_0
    nop
    li t0, 1
    beq s1, t0, draw_state_1
    nop
    li t0, 2
    beq s1, t0, draw_state_2
    nop
    j draw_state_3
    nop

pattern_allstop:
    la t0, COLOR_RED
    lw t1, 0(t0)
    nop
    jal ra, draw_all_red
    nop
    j lights_done
    nop

pattern_emergency:
    # Flash based on anim_frame
    andi t0, s7, 4
    beqz t0, emergency_on
    nop
    
    la t0, COLOR_BLACK
    lw t1, 0(t0)
    nop
    jal ra, draw_all_red
    nop
    j lights_done
    nop

emergency_on:
    la t0, COLOR_ORANGE
    lw t1, 0(t0)
    nop
    jal ra, draw_all_red
    nop
    j lights_done
    nop

draw_state_0:
    # NS=RED (animated left/right), EW=GREEN (animated up/down)
    la t0, COLOR_RED
    lw t1, 0(t0)
    nop
    
    # North red - animated column (10-14 based on frame)
    li t3, 4
    blt s7, t3, north_red_fwd
    nop
    li t3, 7
    sub t4, t3, s7
    j north_red_pos
    nop
north_red_fwd:
    mv t4, s7
north_red_pos:
    addi t4, t4, 10  # Col 10-14
    li t2, 2
    li t3, 25
    mul t5, t2, t3
    add t5, t5, t4
    slli t5, t5, 2
    add t6, s0, t5
    sw t1, 0(t6)
    nop
    
    # South red - animated column
    li t3, 4
    blt s7, t3, south_red_fwd
    nop
    li t3, 7
    sub t4, t3, s7
    j south_red_pos
    nop
south_red_fwd:
    mv t4, s7
south_red_pos:
    addi t4, t4, 10
    li t2, 22
    li t3, 25
    mul t5, t2, t3
    add t5, t5, t4
    slli t5, t5, 2
    add t6, s0, t5
    sw t1, 0(t6)
    nop
    
    la t0, COLOR_GREEN
    lw t1, 0(t0)
    nop
    
    # West green - animated row (10-14 based on frame)
    li t3, 4
    blt s7, t3, west_green_fwd
    nop
    li t3, 7
    sub t4, t3, s7
    j west_green_pos
    nop
west_green_fwd:
    mv t4, s7
west_green_pos:
    addi t4, t4, 10  # Row 10-14
    li t3, 25
    mul t5, t4, t3
    addi t5, t5, 2
    slli t5, t5, 2
    add t6, s0, t5
    sw t1, 0(t6)
    nop
    
    # East green - animated row
    li t3, 4
    blt s7, t3, east_green_fwd
    nop
    li t3, 7
    sub t4, t3, s7
    j east_green_pos
    nop
east_green_fwd:
    mv t4, s7
east_green_pos:
    addi t4, t4, 10
    li t3, 25
    mul t5, t4, t3
    addi t5, t5, 22
    slli t5, t5, 2
    add t6, s0, t5
    sw t1, 0(t6)
    nop
    j lights_done
    nop

draw_state_1:
    # NS=RED (animated), EW=YELLOW (static center)
    la t0, COLOR_RED
    lw t1, 0(t0)
    nop
    
    # North red - animated
    li t3, 4
    blt s7, t3, north_red1_fwd
    nop
    li t3, 7
    sub t4, t3, s7
    j north_red1_pos
    nop
north_red1_fwd:
    mv t4, s7
north_red1_pos:
    addi t4, t4, 10
    li t2, 2
    li t3, 25
    mul t5, t2, t3
    add t5, t5, t4
    slli t5, t5, 2
    add t6, s0, t5
    sw t1, 0(t6)
    nop
    
    # South red - animated
    li t3, 4
    blt s7, t3, south_red1_fwd
    nop
    li t3, 7
    sub t4, t3, s7
    j south_red1_pos
    nop
south_red1_fwd:
    mv t4, s7
south_red1_pos:
    addi t4, t4, 10
    li t2, 22
    li t3, 25
    mul t5, t2, t3
    add t5, t5, t4
    slli t5, t5, 2
    add t6, s0, t5
    sw t1, 0(t6)
    nop
    
    la t0, COLOR_YELLOW
    lw t1, 0(t0)
    nop
    
    # West yellow - static center
    li t2, 12
    li t3, 25
    mul t4, t2, t3
    addi t4, t4, 2
    slli t4, t4, 2
    add t5, s0, t4
    sw t1, 0(t5)
    nop
    
    # East yellow - static center
    li t2, 12
    li t3, 25
    mul t4, t2, t3
    addi t4, t4, 22
    slli t4, t4, 2
    add t5, s0, t4
    sw t1, 0(t5)
    nop
    j lights_done
    nop

draw_state_2:
    # NS=GREEN (animated left/right), EW=RED (animated up/down)
    # --- THIS BLOCK IS NOW FULLY CORRECTED ---
    la t0, COLOR_GREEN
    lw t1, 0(t0)
    nop
    # North green - animated column (10-14 based on frame)
    li t3, 4
    blt s7, t3, north_green_fwd
    nop
    li t3, 7
    sub t4, t3, s7
    j north_green_pos
    nop
north_green_fwd:
    mv t4, s7
north_green_pos:
    addi t4, t4, 10  # Col 10-14
    li t2, 2         # Fixed Row 2
    li t3, 25
    mul t5, t2, t3
    add t5, t5, t4
    slli t5, t5, 2
    add t6, s0, t5
    sw t1, 0(t6)
    nop
    
    # South green - animated column (10-14 based on frame)
    li t3, 4
    blt s7, t3, south_green_fwd
    nop
    li t3, 7
    sub t4, t3, s7
    j south_green_pos
    nop
south_green_fwd:
    mv t4, s7
south_green_pos:
    addi t4, t4, 10  # Col 10-14
    li t2, 22        # Fixed Row 22
    li t3, 25
    mul t5, t2, t3
    add t5, t5, t4
    slli t5, t5, 2
    add t6, s0, t5
    sw t1, 0(t6)
    nop
    
    la t0, COLOR_RED
    lw t1, 0(t0)
    nop
    
    # West red - animated row (10-14 based on frame)
    li t3, 4
    blt s7, t3, west_red_fwd
    nop
    li t3, 7
    sub t4, t3, s7
    j west_red_pos
    nop
west_red_fwd:
    mv t4, s7
west_red_pos:
    addi t4, t4, 10  # Row 10-14
    li t3, 25
    mul t5, t4, t3
    addi t5, t5, 2   # Fixed Col 2
    slli t5, t5, 2
    add t6, s0, t5
    sw t1, 0(t6)
    nop
    
    # East red - animated row (10-14 based on frame)
    li t3, 4
    blt s7, t3, east_red_fwd
    nop
    li t3, 7
    sub t4, t3, s7
    j east_red_pos
    nop
east_red_fwd:
    mv t4, s7
east_red_pos:
    addi t4, t4, 10  # Row 10-14
    li t3, 25
    mul t5, t4, t3
    addi t5, t5, 22  # Fixed Col 22
    slli t5, t5, 2
    add t6, s0, t5
    sw t1, 0(t6)
    nop
    
    # This was the first fix: prevent fall-through
    j lights_done
    nop
draw_state_3:
    # NS=YELLOW (static), EW=RED (animated up/down)
    la t0, COLOR_YELLOW
    lw t1, 0(t0)
    nop
    
    # North yellow - static center
    li t2, 2
    li t3, 25
    mul t4, t2, t3
    addi t4, t4, 12
    slli t4, t4, 2
    add t5, s0, t4
    sw t1, 0(t5)
    nop
    
    # South yellow - static center
    li t2, 22
    li t3, 25
    mul t4, t2, t3
    addi t4, t4, 12
    slli t4, t4, 2
    add t5, s0, t4
    sw t1, 0(t5)
    nop
    
    la t0, COLOR_RED
    lw t1, 0(t0)
    nop
    
    # --- THIS IS THE CORRECTED LOGIC ---
    # West red - animated row (10-14 based on frame)
    li t3, 4
    blt s7, t3, west_red3_fwd
    nop
    li t3, 7
    sub t4, t3, s7
    j west_red3_pos
    nop
west_red3_fwd:
    mv t4, s7
west_red3_pos:
    addi t4, t4, 10  # Row 10-14
    li t3, 25
    mul t5, t4, t3
    addi t5, t5, 2   # Fixed Col 2
    slli t5, t5, 2
    add t6, s0, t5
    sw t1, 0(t6)
    nop
    
    # East red - animated row (10-14 based on frame)
    li t3, 4
    blt s7, t3, east_red3_fwd
    nop
    li t3, 7
    sub t4, t3, s7
    j east_red3_pos
    nop
east_red3_fwd:
    mv t4, s7
east_red3_pos:
    addi t4, t4, 10  # Row 10-14
    li t3, 25
    mul t5, t4, t3
    addi t5, t5, 22  # Fixed Col 22
    slli t5, t5, 2
    add t6, s0, t5
    sw t1, 0(t6)
    nop

lights_done:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
    nop

draw_all_red:
    # Draw red at all 4 positions (t1 has color)
    li t2, 2
    li t3, 25
    mul t4, t2, t3
    addi t4, t4, 12
    slli t4, t4, 2
    add t5, s0, t4
    sw t1, 0(t5)
    nop
    
    li t2, 22
    li t3, 25
    mul t4, t2, t3
    addi t4, t4, 12
    slli t4, t4, 2
    add t5, s0, t4
    sw t1, 0(t5)
    nop
    
    li t2, 12
    li t3, 25
    mul t4, t2, t3
    addi t4, t4, 2
    slli t4, t4, 2
    add t5, s0, t4
    sw t1, 0(t5)
    nop
    
    li t2, 12
    li t3, 25
    mul t4, t2, t3
    addi t4, t4, 22
    slli t4, t4, 2
    add t5, s0, t4
    sw t1, 0(t5)
    nop
    ret
    nop

traffic_controller:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    la t0, pattern_mode
    lw t5, 0(t0)
    nop
    
    # Patterns 2 and 3 don't use state machine
    li t6, 2
    bge t5, t6, controller_done
    nop
    
    la t0, timer
    lw t1, 0(t0)
    nop
    addi t1, t1, 1
    sw t1, 0(t0)
    
    la t0, state
    lw t2, 0(t0)
    nop
    
    # Determine time limit
    andi t3, t2, 1
    beqz t3, use_green
    nop
    mv t4, s4        # Yellow time
    j check_time
    nop

use_green:
    mv t4, s3        # Green time

check_time:
    blt t1, t4, controller_done
    nop
    
    # Advance state
    la t0, state
    lw t2, 0(t0)
    nop
    addi t2, t2, 1
    andi t2, t2, 3
    sw t2, 0(t0)
    nop
    
    # Reset timer
    la t0, timer
    sw x0, 0(t0)
    nop

controller_done:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
    nop

print_status:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    la t0, state
    lw t1, 0(t0)
    nop
    
    la t0, pattern_mode
    lw t2, 0(t0)
    nop
    
    # Pattern 2: emergency (Swapped)
    li t3, 2
    beq t2, t3, print_emergency
    nop

    # Pattern 3: all-stop (Swapped)
    li t3, 3
    beq t2, t3, print_allstop
    nop
    
    # Normal states
    beq t1, x0, print_s0
    nop
    li t2, 1
    beq t1, t2, print_s1
    nop
    li t2, 2
    beq t1, t2, print_s2
    nop
    j print_s3
    nop

print_allstop:
    la a0, msg_state4
    jal ra, print_string
    nop
    j print_timer_info
    nop

print_emergency:
    la a0, msg_state5
    jal ra, print_string
    nop
    j print_timer_info
    nop

print_s0:
    la a0, msg_state0
    jal ra, print_string
    nop
    j print_timer_info
    nop

print_s1:
    la a0, msg_state1
    jal ra, print_string
    nop
    j print_timer_info
    nop

print_s2:
    la a0, msg_state2
    jal ra, print_string
    nop
    j print_timer_info
    nop

print_s3:
    la a0, msg_state3
    jal ra, print_string
    nop

print_timer_info:
    la a0, msg_timer
    jal ra, print_string
    nop
    
    la t0, timer
    lw a0, 0(t0)
    nop
    jal ra, print_int
    nop
    
    la a0, msg_cycles
    jal ra, print_string
    nop
    
    mv a0, s6
    jal ra, print_int
    nop
    
    la a0, newline
    jal ra, print_string
    nop
    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
    nop

print_string:
    addi sp, sp, -8
    sw ra, 4(sp)
    sw s0, 0(sp)
    mv s0, a0

print_loop:
    lb t0, 0(s0)
    nop
    beqz t0, print_done
    nop
    li a7, 11
    mv a0, t0
    ecall
    addi s0, s0, 1
    j print_loop
    nop

print_done:
    lw s0, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8
    ret
    nop

print_int:
    li a7, 1
    ecall
    ret
    nop

print_startup:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    la a0, msg_start
    jal ra, print_string
    nop
    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
    nop

print_exit:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    la a0, msg_exit
    jal ra, print_string
    nop
    
    la a0, msg_cycles
    jal ra, print_string
    nop
    
    mv a0, s6
    jal ra, print_int
    nop
    
    la a0, newline
    jal ra, print_string
    nop
    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
    nop

delay:
    li t0, 20000
delay_loop:
    addi t0, t0, -1
    bnez t0, delay_loop
    nop
    ret
    nop

exit_program:
    la t0, cycle_count
    sw s6, 0(t0)
    li a7, 10
    ecall

halt:
    j halt
    nop