{ config }:

{
  fields = with config.lib.htop.fields; [
    PID
    USER
    # PRIORITY
    NICE
    IO_PRIORITY
    # IO_WRITE_RATE
    # IO_READ_RATE
    IO_RATE
    STATE
    NLWP
    PERCENT_CPU
    PERCENT_MEM
    # RCHAR
    # WCHAR
    TIME
    OOM
    COMM
  ];
  cpu_count_from_zero = true;
  header_margin = 1;
  hide_threads = true;
  hide_kernel_threads = true;
  hide_userland_threads = true;
  highlight_base_name = true;
  show_program_path = false;
  tree_view = 1;
  update_process_names = true;
  vim_mode = true;
  left_meters = [ "AllCPUs" "Blank" "CPU" "Blank" "LoadAverage" "Tasks" ];
  left_meter_modes = [ 1 2 3 2 2 2 ];
  right_meters = [ "Memory" "Memory" "Blank" "Swap" "Swap" "Blank" "Uptime" ];
  right_meter_modes = [ 3 2 2 3 2 2 2 ];
}
